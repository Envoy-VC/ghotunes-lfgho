// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

// Testing
import { Test } from "forge-std/src/Test.sol";
import { VmSafe } from "forge-std/src/Vm.sol";
import { console2 } from "forge-std/src/console2.sol";

// Contracts
import { GHOTunes } from "../src/GHOTunes.sol";
import { IGhoTunes } from "../src/interfaces/IGhoTunes.sol";

import { SigUtils } from "../src/utils/SigUtils.sol";
import { AccountRegistry } from "../src/accounts/AccountRegistry.sol";
import { GHOTunesAccount } from "../src/accounts/Account.sol";

// Aave V3 Contracts
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { AaveV3Sepolia, AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";
import { DebtTokenBase } from "@aave/core-v3/contracts/protocol/tokenization/base/DebtTokenBase.sol";

import { IAccount } from "../src/accounts/Account.sol";
import { IGhoToken } from "../src/interfaces/IGhoToken.sol";

contract GHOTunesTest is Test {
    uint256 mainnetFork;
    GHOTunes public tunes;
    AccountRegistry public accountRegistry;
    GHOTunesAccount public implementation;
    IGhoToken public ghoToken = IGhoToken(address(AaveV3SepoliaAssets.GHO_UNDERLYING));

    DebtTokenBase public vWETH;
    DebtTokenBase public vGHO;
    IPool public aavePool = IPool(address(AaveV3Sepolia.POOL));

    VmSafe.Wallet public owner;
    VmSafe.Wallet public user1;

    function setUp() public virtual {
        // Create Wallets
        owner = vm.createWallet("owner");
        user1 = vm.createWallet("user1");
        vm.allowCheatcodes(owner.addr);

        vm.startPrank(owner.addr);

        // Create a fork for the mainnet.
        string memory MAINNET_RPC_URL = vm.envString("ETH_SEPOLIA");
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        // Deploy Contracts
        accountRegistry = new AccountRegistry();
        implementation = new GHOTunesAccount();
        vWETH = DebtTokenBase(AaveV3SepoliaAssets.WETH_V_TOKEN);
        vGHO = DebtTokenBase(AaveV3SepoliaAssets.GHO_V_TOKEN);

        IGhoTunes.TIER[] memory tiers = new GHOTunes.TIER[](3);
        tiers[0] = IGhoTunes.TIER({ name: "Free", image: "bronze.png", price: 0 ether }); // Free
        tiers[1] = IGhoTunes.TIER({ name: "Silver", image: "silverImage.png", price: 5 ether }); // 5 GHO
        tiers[2] = IGhoTunes.TIER({ name: "Gold", image: "goldImage.png", price: 10 ether }); // 10 GHO

        tunes = new GHOTunes(owner.addr, address(accountRegistry), address(implementation), tiers);

        vm.stopPrank();
        vm.startPrank(0xBF4979305B43B0eB5Bb6a5C67ffB89408803d3e1);
        (bool success,) = address(0x779877A7B0D9E8603169DdbD7836e478b4624789).call(
            abi.encodeWithSignature("transfer(address,uint256)", address(tunes), 10 ether)
        );
        require(success, "Transfer failed");
        vm.stopPrank();
    }

    function test_depositAndSubscribe() external {
        vm.startPrank(user1.addr);
        vm.deal(user1.addr, 100 ether);

        uint256 DURATION_IN_MONTHS = 12;
        //uint256 ethRequired = tunes.calculateETHRequired(1);

        // Get Signatures
        GHOTunes.Signature memory wETHPermit =
            generatePermitSignature(vWETH, user1.addr, address(AaveV3Sepolia.WETH_GATEWAY), 1 ether);

        (,, uint256 amount) = tunes.tiers(1);
        GHOTunes.Signature memory ghoPermit =
            generatePermitSignature(vGHO, user1.addr, address(tunes), amount * DURATION_IN_MONTHS);

        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");

        tunes.subscribeWithETH{ value: 1 ether }(user1.addr, 1, DURATION_IN_MONTHS, wETHPermit, ghoPermit);

        (uint8 c,, address a, uint256 v, IGhoTunes.UpkeepDetails memory details) = tunes.accounts(user1.addr);
        console2.log("");
        console2.log("========= Subscribing =========");
        console2.log("");
        console2.log("Mint NFT with tokenId: ", tunes._nextTokenId() - 1);
        console2.log("Created ERC-6551 Account: ", a);
        (string memory cName,,) = tunes.tiers(c);
        console2.log("Current Tier: ", cName);
        console2.log("Valid Until: ", v);
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console2.log("");
        console2.log("========= Forwarding 1 month =========");

        vm.warp(block.timestamp + 30 days);
        vm.stopPrank();

        console2.log("Chainlink Upkeep Calling renew on ERC-6551 Account...");
        console2.log("");

        vm.startPrank(details.forwarderAddress);
        IAccount account = IAccount(a);
        account.performUpkeep();
        (uint8 newC,,, uint256 newV,) = tunes.accounts(user1.addr);
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console2.log("");
        (string memory newCName,,) = tunes.tiers(newC);
        console2.log("Updated Tier: ", newCName);
        console2.log("Updated Valid Until: ", newV);
        vm.stopPrank();

        vm.startPrank(user1.addr);
        console2.log("");
        console2.log("========= Tier Change =========");
        console2.log("");
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        tunes.changeTier(0, 2);
        (string memory n,,) = tunes.tiers(2);
        console2.log("User Changed Tier to: ", n);
        vm.warp(block.timestamp + 30 days);
        console2.log("");
        console2.log("========= Forwarding 1 month =========");
        console2.log("Chainlink Upkeep Calling renew on ERC-6551 Account...");
        console2.log("");
        vm.stopPrank();

        vm.startPrank(details.forwarderAddress);
        account.performUpkeep();
        (uint8 nc,,, uint256 nv,) = tunes.accounts(user1.addr);
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console2.log("");
        (string memory ncc,,) = tunes.tiers(nc);
        console2.log("Updated Tier: ", ncc);
        console2.log("Updated Valid Until: ", nv);
        vm.stopPrank();

        vm.startPrank(user1.addr);
        console2.log("");
        console2.log("========= Migrate to Base Tier =========");
        console2.log("");
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        tunes.changeTier(0, 0);
        (string memory nn,,) = tunes.tiers(0);
        console2.log("User Changed Tier to: ", nn);
        console2.log("Tier change will happen on next billing");
        vm.warp(block.timestamp + 30 days);
        console2.log("");
        console2.log("========= Forwarding 1 month =========");

        console2.log("Chainlink Upkeep Calling renew on ERC-6551 Account...");
        console2.log("");
        vm.stopPrank();

        vm.startPrank(details.forwarderAddress);
        account.performUpkeep();
        (uint8 nnc,,, uint256 nnv,) = tunes.accounts(user1.addr);
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console2.log("");
        (string memory nccc,,) = tunes.tiers(nnc);
        console2.log("Updated Tier: ", nccc);
        console2.log("Updated Valid Until: ", nnv);
        vm.stopPrank();

        vm.startPrank(user1.addr);
        console2.log("");
        console2.log("========= Promote to Silver Again =========");
        console2.log("");
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        tunes.changeTier(0, 1);
        (string memory nn1,,) = tunes.tiers(1);
        console2.log("User Changed Tier to: ", nn1);
        console2.log("Tier change will happen on next billing");
        vm.warp(block.timestamp + 30 days);
        console2.log("");
        console2.log("========= Forwarding 1 month =========");

        console2.log("Chainlink Upkeep Calling renew on ERC-6551 Account...");
        console2.log("");
        vm.stopPrank();

        vm.startPrank(details.forwarderAddress);
        account.performUpkeep();
        (uint8 nnc1,,, uint256 nnv1,) = tunes.accounts(user1.addr);
        console2.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console2.log("");
        (string memory nccc1,,) = tunes.tiers(nnc1);
        console2.log("Updated Tier: ", nccc1);
        console2.log("Updated Valid Until: ", nnv1);
        vm.stopPrank();
    }

    function generatePermitSignature(
        DebtTokenBase token,
        address delegator,
        address delegatee,
        uint256 value
    )
        public
        returns (GHOTunes.Signature memory)
    {
        SigUtils sigUtils = new SigUtils(token.DOMAIN_SEPARATOR(), token.DELEGATION_WITH_SIG_TYPEHASH());
        uint256 nonce = token.nonces(delegator);
        uint256 deadline = block.timestamp + 1 days;

        SigUtils.Permit memory permit =
            SigUtils.Permit({ owner: delegator, spender: delegatee, value: value, nonce: nonce, deadline: deadline });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1.privateKey, digest);
        GHOTunes.Signature memory sig = IGhoTunes.Signature({ deadline: deadline, v: v, r: r, s: s });

        return sig;
    }
}
