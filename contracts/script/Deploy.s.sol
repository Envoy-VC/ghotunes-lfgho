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
        uint256 deployerPrivateKey = vm.envUint("PK");
        address owner = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        console.log("Deploying GHOTunes with account", owner);

        AccountRegistry accountRegistry = new AccountRegistry();
        GHOTunesAccount implementation = new GHOTunesAccount();
        Token token = new Token(owner);

        // TODO: Update Images
        TIER[] memory tiers = new TIER[](3);

        // Free Tier 0 GHO
        tiers[0] = TIER({
            name: "Free",
            image: "ipfs://bafybeid5lejwicuka3mi7ly3dj4lfggzzxrvxdvkxsuqszqvqzex7sf7iy",
            price: 0 ether
        });

        // Silver Tier 5 GHO
        tiers[1] = TIER({
            name: "Silver",
            image: "ipfs://bafybeibzjt66ujqta3sz35bk5zzfmva5jy4ans6h2tqwypgqkrtf5ufd6u",
            price: 5 ether
        });

        // Gold Tier 10 GHO
        tiers[2] = TIER({
            name: "Gold",
            image: "ipfs://bafybeih622mxsboh7tauupuj6snvemxszpx3cuy2dblvvy5gzrnuv7gzte",
            price: 10 ether
        });

        GHOTunes tunes = new GHOTunes(owner, address(accountRegistry), address(implementation), tiers, address(token));

        token.setTunes(address(tunes));

        console.log("AccountRegistry deployed at", address(accountRegistry));
        console.log("GHOTunesAccount deployed at", address(implementation));
        console.log("GHOTunes deployed at", address(tunes));

        vm.stopBroadcast();
    }
}
