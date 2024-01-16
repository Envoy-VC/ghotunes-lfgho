// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGhoTunes {
    struct User {
        uint8 currentTier;
        uint8 nextTier;
        address accountAddress;
        uint256 validUntil;
    }

    struct TIER {
        string name;
        string image;
        uint256 price;
    }

    struct Signature {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function subscribeWithETH(
        address user,
        uint8 tier,
        uint256 durationInMonths,
        Signature memory wETHPermit,
        Signature memory ghoPermit
    )
        external
        payable;
}
