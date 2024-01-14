// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { console2 } from "forge-std/src/console2.sol";

// ERC-6551 Token Bound Accounts
import { AccountRegistry } from "./accounts/AccountRegistry.sol";
import { GHOTunesAccount } from "./accounts/Account.sol";

// Aave V3 Contracts
import { AaveV3Sepolia, AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import { IPriceOracle } from "@aave/core-v3/contracts/interfaces/IPriceOracle.sol";
import { IPoolDataProvider } from "@aave/core-v3/contracts/interfaces/IPoolDataProvider.sol";

contract GHOTunes is ERC721, ERC721URIStorage, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    AccountRegistry public accountRegistry;
    IPoolAddressesProvider public aaveAddressesProvider;
    IPriceOracle public priceOracle;
    IPoolDataProvider public poolDataProvider;
    address public implementation;
    address public constant GHO_TOKEN = 0xc4bF5CbDaBE595361438F8c6a187bDc330539c60;

    uint256 public constant GHO_PRICE_USD = 1e8;
    uint256 public constant PRICE = 1e18 * 10; // 10 GHO

    mapping(address => address) public accounts;
    uint256 public totalTiers;
    mapping(uint256 => TIER) public tiers;

    struct TIER {
        // Price in GHO Token
        uint256 price;
    }

    constructor(
        address initialOwner,
        address _accountRegistry,
        address _implementation,
        TIER[] memory _tiers
    )
        ERC721("GHO Tunes", "TUNES")
        Ownable(initialOwner)
    {
        aaveAddressesProvider = IPoolAddressesProvider(address(AaveV3Sepolia.POOL_ADDRESSES_PROVIDER));
        priceOracle = IPriceOracle(aaveAddressesProvider.getPriceOracle());
        poolDataProvider = IPoolDataProvider(aaveAddressesProvider.getPoolDataProvider());
        accountRegistry = AccountRegistry(_accountRegistry);
        implementation = _implementation;

        uint256 len = _tiers.length;
        totalTiers = len;
        for (uint256 i = 0; i < len;) {
            tiers[i] = _tiers[i];
            unchecked {
                ++i;
            }
        }
    }

    function calculateETHRequired(uint256 _tier) public view returns (uint256) {
        TIER memory tier = tiers[_tier];
        uint256 tierPrice = tier.price;
        address asset = address(AaveV3SepoliaAssets.WETH_UNDERLYING);
        uint256 assetPrice = priceOracle.getAssetPrice(asset);
        (, uint256 ltv,,,,,,,,) = poolDataProvider.getReserveConfigurationData(asset);
        uint256 ethRequired = (tierPrice * GHO_PRICE_USD * 1e4) / (ltv * assetPrice);
        return ethRequired;
    }

    function depositAndSubscribe(address user, uint256 tier) public payable {
        require(accounts[user] == address(0), "GHOTunes: Account already exists");
        require(tier <= totalTiers, "GHOTunes: Invalid Tier");
        require(msg.value >= calculateETHRequired(tier), "GHOTunes: Insufficient ETH");

        // Mint NFT to user.
        uint256 tokenId = _nextTokenId++;
        string memory uri = _buildURI(tokenId);
        uint256 salt = 1;
        _safeMint(user, tokenId);
        _setTokenURI(tokenId, uri);
        console2.log("Minted NFT: ", tokenId);

        // Create ERC6551 Account
        accountRegistry.createAccount(implementation, block.chainid, address(this), tokenId, salt, "");
        address accountAddress = accountRegistry.account(implementation, block.chainid, address(this), tokenId, salt);
        console2.log("Created ERC-6551 Account: ", accountAddress);
        accounts[user] = accountAddress;

        // send ether to account
        (bool success,) = accountAddress.call{ value: msg.value }("");
        require(success, "GHOTunes: Failed to send ether to account");

        // get balance of accountAddress
        uint256 balance = address(accountAddress).balance;
        console2.log("Account Balance: ", balance / 1e18, "ETH");

        // TODO: Deposit Ether to Aave and credit delegate GHO Tokens.
    }

    function _buildURI(uint256 tokenId) internal pure returns (string memory) {
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
