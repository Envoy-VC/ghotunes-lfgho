// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// library
import { URILibrary } from "../lib/URI.sol";

// Interfaces
import "../interfaces/IGhoTunes.sol";

interface IToken is IERC721 {
    function mint(address to, TIER memory tier) external returns (uint256);
    function setTokenURI(uint256 tokenId, string memory uri) external;
}

contract Token is IToken, ERC721, ERC721URIStorage, Ownable {
    uint256 public _nextTokenId;
    address public tunes;

    constructor(address initialOwner) ERC721("GHO Tunes", "TUNES") Ownable(initialOwner) { }

    modifier onlyTunes() {
        require(msg.sender == tunes, "Token: Only Tunes");
        _;
    }

    function setTunes(address _tunes) external onlyOwner {
        tunes = _tunes;
    }

    function setTokenURI(uint256 tokenId, string memory uri) external onlyTunes {
        _setTokenURI(tokenId, uri);
    }

    function mint(address to, TIER memory tier) external onlyTunes returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        string memory uri = URILibrary._buildURI(tokenId, tier);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
