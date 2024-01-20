// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/src/Script.sol";

import { GHOTunes } from "../src/GHOTunes.sol";
import { AccountRegistry } from "../src/accounts/AccountRegistry.sol";
import { GHOTunesAccount } from "../src/accounts/Account.sol";
import { Token } from "../src/token/Token.sol";
import "../src/interfaces/IGhoTunes.sol";

contract Deploy is Script {
    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("PK");
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        address owner = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        console.log("Deploying GHOTunes with account", owner);

        AccountRegistry accountRegistry = new AccountRegistry();
        GHOTunesAccount implementation = new GHOTunesAccount();
        Token token = new Token(owner);

        // TODO: Update Images
        TIER[] memory tiers = new TIER[](3);
        tiers[0] = TIER({ name: "Free", image: "bronze.png", price: 0 ether }); // Free
        tiers[1] = TIER({ name: "Silver", image: "silverImage.png", price: 5 ether }); // 5 GHO
        tiers[2] = TIER({ name: "Gold", image: "goldImage.png", price: 10 ether }); // 10 GHO

        GHOTunes tunes = new GHOTunes(address(accountRegistry), address(implementation), tiers, address(token));

        token.setTunes(address(tunes));

        console.log("AccountRegistry deployed at", address(accountRegistry));
        console.log("GHOTunesAccount deployed at", address(implementation));
        console.log("GHOTunes deployed at", address(tunes));

        vm.stopBroadcast();
    }
}
