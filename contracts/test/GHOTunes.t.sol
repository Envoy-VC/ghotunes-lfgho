// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

// Testing
import { Test } from "forge-std/src/Test.sol";
import { VmSafe } from "forge-std/src/Vm.sol";
import { console2 as console } from "forge-std/src/console2.sol";

// Contracts
import { GHOTunes } from "../src/GHOTunes.sol";
import "../src/interfaces/IGhoTunes.sol";

import { SigUtils } from "../src/utils/SigUtils.sol";
import { AccountRegistry } from "../src/accounts/AccountRegistry.sol";
import { GHOTunesAccount } from "../src/accounts/Account.sol";
import { Token } from "../src/token/Token.sol";

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
    Token public token;

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

        TIER[] memory tiers = new TIER[](3);
        tiers[0] = TIER({ name: "Free", image: "bronze.png", price: 0 ether }); // Free
        tiers[1] = TIER({ name: "Silver", image: "silverImage.png", price: 5 ether }); // 5 GHO
        tiers[2] = TIER({ name: "Gold", image: "goldImage.png", price: 10 ether }); // 10 GHO

        token = new Token(owner.addr);
        tunes = new GHOTunes(address(accountRegistry), address(implementation), tiers, address(token));
        token.setTunes(address(tunes));
        vm.stopPrank();

        // Send Some LINK Tokens to Tunes
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

        console.log("Deployed Tunes: ", address(tunes));
        console.log("");
        console.log("Free:   0 GHO");
        console.log("Silver: 5 GHO");
        console.log("Gold:   10 GHO");
        console.log("");

        uint256 DURATION_IN_MONTHS = 12;
        // uint256 ethRequired = tunes.calculateETHRequired(1);

        // Get Signatures
        Signature memory wETHPermit =
            generatePermitSignature(vWETH, user1.addr, address(AaveV3Sepolia.WETH_GATEWAY), 1 ether);

        (,, uint256 amount) = tunes.tiers(1);
        Signature memory ghoPermit =
            generatePermitSignature(vGHO, user1.addr, address(tunes), amount * DURATION_IN_MONTHS);

        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");

        tunes.subscribeWithETH{ value: 1 ether }(user1.addr, 1, DURATION_IN_MONTHS, wETHPermit, ghoPermit);

        (uint8 c,, address a, uint256 v, UpkeepDetails memory details) = tunes.accounts(user1.addr);
        console.log("");
        console.log("========= Subscribing =========");
        console.log("");
        console.log("Mint NFT with tokenId: ", token._nextTokenId() - 1);
        console.log("Created ERC-6551 Account: ", a);
        (string memory cName,,) = tunes.tiers(c);
        console.log("Current Tier: ", cName);
        console.log("Valid Until: ", v);
        console.log("Upkeep Address: ", details.upkeepAddress);
        console.log("Upkeep Forwarder: ", details.forwarderAddress);
        console.log("Upkeep ID: ", details.upkeepId);
        console.log("");
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console.log("");
        console.log("========= Forwarding 1 month =========");

        vm.warp(block.timestamp + 30 days);
        vm.stopPrank();

        console.log("Chainlink Upkeep Calling renew on ERC-6551 Account...");
        console.log("");

        vm.startPrank(details.forwarderAddress);
        IAccount account = IAccount(a);
        account.performUpkeep();
        (uint8 newC,,, uint256 newV,) = tunes.accounts(user1.addr);
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console.log("");
        (string memory newCName,,) = tunes.tiers(newC);
        console.log("Updated Tier: ", newCName);
        console.log("Updated Valid Until: ", newV);
        vm.stopPrank();

        vm.startPrank(user1.addr);
        console.log("");
        console.log("========= Tier Change =========");
        console.log("");
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        tunes.changeTier(0, 2);
        (string memory n,,) = tunes.tiers(2);
        console.log("User Changed Tier to: ", n);
        vm.warp(block.timestamp + 30 days);
        console.log("");
        console.log("========= Forwarding 1 month =========");
        console.log("Chainlink Upkeep Calling renew on ERC-6551 Account...");
        console.log("");
        vm.stopPrank();

        vm.startPrank(details.forwarderAddress);
        account.performUpkeep();
        (uint8 nc,,, uint256 nv,) = tunes.accounts(user1.addr);
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console.log("");
        (string memory ncc,,) = tunes.tiers(nc);
        console.log("Updated Tier: ", ncc);
        console.log("Updated Valid Until: ", nv);
        vm.stopPrank();

        vm.startPrank(user1.addr);
        console.log("");
        console.log("========= Migrate to Base Tier =========");
        console.log("");
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        tunes.changeTier(0, 0);
        (string memory nn,,) = tunes.tiers(0);
        console.log("User Changed Tier to: ", nn);
        console.log("Tier change will happen on next billing");
        vm.warp(block.timestamp + 30 days);
        console.log("");
        console.log("========= Forwarding 1 month =========");

        console.log("Chainlink Upkeep Calling renew on ERC-6551 Account...");
        console.log("");
        vm.stopPrank();

        vm.startPrank(details.forwarderAddress);
        account.performUpkeep();
        (uint8 nnc,,, uint256 nnv,) = tunes.accounts(user1.addr);
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console.log("");
        (string memory nccc,,) = tunes.tiers(nnc);
        console.log("Updated Tier: ", nccc);
        console.log("Updated Valid Until: ", nnv);
        vm.stopPrank();

        vm.startPrank(user1.addr);
        console.log("");
        console.log("========= Promote to Silver Again =========");
        console.log("");
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        tunes.changeTier(0, 1);
        (string memory nn1,,) = tunes.tiers(1);
        console.log("User Changed Tier to: ", nn1);
        console.log("User has to call renew function as there is no upkeep running");
        console.log("");
        tunes.renew(0);
        (uint8 nnc1,,, uint256 nnv1,) = tunes.accounts(user1.addr);
        console.log("GHO Balance of Contract: ", ghoToken.balanceOf(address(tunes)) / 1e18, "GHO");
        console.log("");
        (string memory nccc1,,) = tunes.tiers(nnc1);
        console.log("Updated Tier: ", nccc1);
        console.log("Updated Valid Until: ", nnv1);
        vm.stopPrank();
    }

    function generatePermitSignature(
        DebtTokenBase _token,
        address delegator,
        address delegatee,
        uint256 value
    )
        public
        returns (Signature memory)
    {
        SigUtils sigUtils = new SigUtils(_token.DOMAIN_SEPARATOR(), _token.DELEGATION_WITH_SIG_TYPEHASH());
        uint256 nonce = _token.nonces(delegator);
        uint256 deadline = block.timestamp + 1 days;

        SigUtils.Permit memory permit =
            SigUtils.Permit({ owner: delegator, spender: delegatee, value: value, nonce: nonce, deadline: deadline });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1.privateKey, digest);
        Signature memory sig = Signature({ deadline: deadline, v: v, r: r, s: s });

        return sig;
    }
}
