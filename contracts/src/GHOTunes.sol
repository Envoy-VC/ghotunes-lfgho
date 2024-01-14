// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// ERC-6551 Token Bound Accounts
import { AccountRegistry } from "./accounts/AccountRegistry.sol";
import { Account } from "./accounts/Account.sol";

// Aave V3 Contracts
import { AaveV3Sepolia } from "aave-address-book/AaveV3Sepolia.sol";

contract GHOTunes is ERC721, ERC721URIStorage, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    AccountRegistry public accountRegistry;
    address public implementation;

    mapping(address => address) public accounts;

    constructor(
        address initialOwner,
        address _accountRegistry,
        address _implementation
    )
        ERC721("GHO Tunes", "TUNES")
        Ownable(initialOwner)
    {
        accountRegistry = AccountRegistry(_accountRegistry);
        implementation = _implementation;
    }

    function depositAndSubscribe(address to) public payable {
        require(accounts[to] == address(0), "GHOTunes: Account already exists");
        // TODO: Add checks

        // Mint NFT to user.
        uint256 tokenId = _nextTokenId++;
        string memory uri = _buildURI(tokenId);
        uint256 salt = 1;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        // Create ERC6551 Account
        accountRegistry.createAccount(implementation, block.chainid, address(this), tokenId, salt, "");
        address accountAddress = accountRegistry.account(implementation, block.chainid, address(this), tokenId, salt);
        accounts[to] = accountAddress;

        // send ether to account
        (bool success,) = accountAddress.call{ value: msg.value }("");
        require(success, "GHOTunes: Failed to send ether to account");

        // TODO: Deposit Ether to Aave and credit delegate GHO Tokens.
    }

    function _buildURI(uint256 tokenId) internal view returns (string memory) {
        return string(abi.encodePacked("{" "name: GHO Tunes ", tokenId, ",", "description: GHO Tunes"));
    }

    // The following functions are overrides required by Solidity.

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
