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

contract GHOTunesTest is Test {
    uint256 mainnetFork;
    GHOTunes public tunes;
    AccountRegistry public accountRegistry;
    GHOTunesAccount public implementation;

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
        uint256 ethRequired = tunes.calculateETHRequired(1);
        console2.log("ETH Required: ", ethRequired);

        GHOTunes.Signature memory wETHPermit =
            generatePermitSignature(vWETH, user1.addr, address(AaveV3Sepolia.WETH_GATEWAY), ethRequired);

        (,, uint256 amount) = tunes.tiers(1);
        console2.log("Amount: ", amount);
        GHOTunes.Signature memory ghoPermit =
            generatePermitSignature(vGHO, user1.addr, address(tunes), amount * DURATION_IN_MONTHS);

        tunes.subscribeWithETH{ value: ethRequired }(user1.addr, 1, DURATION_IN_MONTHS, wETHPermit, ghoPermit);

        (uint8 c, uint8 n, address a, uint256 v, IGhoTunes.UpkeepDetails memory details) = tunes.accounts(user1.addr);

        console2.log("CurrentTier: ", c);
        console2.log("NextTier: ", n);
        console2.log("AccountAddress: ", a);
        console2.log("ValidUntil: ", v);
        console2.log("");
        console2.log("UpkeepAddress: ", details.upkeepAddress);
        console2.log("ForwarderAddress: ", details.forwarderAddress);
        console2.log("UpkeepId: ", details.upkeepId);

        vm.stopPrank();
    }

    function test_subscribe() external {
        vm.startPrank(user1.addr);
        tunes.subscribe(user1.addr, 0);
        vm.stopPrank();
    }

    function test_subscribeWithGHO() external {
        vm.startPrank(user1.addr);
        tunes.subscribeWithGHO(user1.addr, 0);
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
