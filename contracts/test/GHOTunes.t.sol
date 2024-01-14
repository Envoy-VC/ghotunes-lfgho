// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { GHOTunes } from "../src/GHOTunes.sol";
import { AccountRegistry } from "../src/accounts/AccountRegistry.sol";
import { GHOTunesAccount } from "../src/accounts/Account.sol";

contract GHOTunesTest is Test {
    uint256 mainnetFork;
    GHOTunes public tunes;
    AccountRegistry public accountRegistry;
    GHOTunesAccount public implementation;
    address public owner = 0xBF4979305B43B0eB5Bb6a5C67ffB89408803d3e1;
    address public user1;

    function setUp() public virtual {
        vm.startPrank(owner);
        // Create a fork for the mainnet.
        string memory MAINNET_RPC_URL = vm.envString("ETH_MAINNET");
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        // Deploy Contracts
        accountRegistry = new AccountRegistry();
        implementation = new GHOTunesAccount();
        tunes = new GHOTunes(owner, address(accountRegistry), address(implementation));

        // Create a user
        user1 = address(uint160(uint256(keccak256(abi.encodePacked("user1")))));
        vm.deal(user1, 100 ether);
        vm.stopPrank();
    }

    function test_depositAndSubscribe() external {
        vm.startPrank(user1);
        tunes.depositAndSubscribe{ value: 1 ether }(user1);
        vm.stopPrank();
    }
}
