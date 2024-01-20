// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin Contracts
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// Interfaces
import "../interfaces/IGhoTunes.sol";

library URILibrary {
    using Strings for uint256;
    using Strings for uint8;

    function _buildURI(uint256 tokenId, TIER memory tier) internal view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "GHO Tunes #',
            tokenId.toString(),
            '", ',
            '"description": "Recurring Payments based on Aave V3 GHO Token",',
            '"image": "',
            tier.image,
            '", ',
            '"attributes": [',
            '{"trait_type": "Tier", "value": "',
            tier.name,
            '"},',
            '{"trait_type": "Price", "value": "',
            (tier.price / 1e18).toString(),
            ' GHO"},',
            '{"trait_type": "Expires", "display_type": "date", "value": "',
            (block.timestamp + 30 days).toString(),
            '"}',
            "]",
            "}"
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }
}
