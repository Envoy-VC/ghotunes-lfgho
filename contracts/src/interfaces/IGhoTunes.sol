// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGhoTunes {
    struct TIER {
        // Price in GHO Token
        string name;
        string image;
        uint256 price;
    }

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}
