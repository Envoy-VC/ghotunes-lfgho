// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

// Testing
import { Test } from "forge-std/src/Test.sol";
import { VmSafe } from "forge-std/src/Vm.sol";
import { console2 } from "forge-std/src/console2.sol";

// Contracts
import { GHOTunes } from "../src/GHOTunes.sol";
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
    SigUtils internal sigUtils;
    SigUtils internal sigUtils2;

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

        GHOTunes.TIER[] memory tiers = new GHOTunes.TIER[](3);
        tiers[0] = GHOTunes.TIER({ price: 0 ether }); // Free
        tiers[1] = GHOTunes.TIER({ price: 5 ether }); // 5 GHO
        tiers[2] = GHOTunes.TIER({ price: 10 ether }); // 10 GHO

        tunes = new GHOTunes(owner.addr, address(accountRegistry), address(implementation), tiers);

        sigUtils = new SigUtils(vWETH.DOMAIN_SEPARATOR());
        sigUtils2 = new SigUtils(vGHO.DOMAIN_SEPARATOR());

        vm.stopPrank();
    }

    function test_depositAndSubscribe() external {
        vm.startPrank(user1.addr);
        vm.deal(user1.addr, 100 ether);

        uint256 ethRequired = tunes.calculateETHRequired(1);
        console2.log("ETH Required: ", ethRequired);

        // Generate Permit
        address spender = address(AaveV3Sepolia.WETH_GATEWAY);
        uint256 nonce = vWETH.nonces(user1.addr);
        uint256 deadline = block.timestamp + 1 days;
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: user1.addr,
            spender: spender,
            value: ethRequired,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1.privateKey, digest);

        uint256 amount = 5 ether;

        // Generate Permit 2
        address spender1 = address(tunes);
        uint256 nonce1 = vGHO.nonces(user1.addr);
        SigUtils.Permit memory permit1 =
            SigUtils.Permit({ owner: user1.addr, spender: spender1, value: amount, nonce: nonce1, deadline: deadline });

        bytes32 digest1 = sigUtils2.getTypedDataHash(permit1);

        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(user1.privateKey, digest1);

        tunes.depositAndSubscribe{ value: ethRequired }(user1.addr, 1, deadline, v, r, s, v1, r1, s1);
        vm.stopPrank();
    }
}
