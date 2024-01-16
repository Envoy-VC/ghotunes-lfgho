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
import { IAToken } from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import { AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";
import { DebtTokenBase } from "@aave/core-v3/contracts/protocol/tokenization/base/DebtTokenBase.sol";

// Base
import { GHOTunesBase } from "./base/GHOTunesBase.sol";

// Interfaces
import { IGhoToken } from "./interfaces/IGhoToken.sol";
import { IGhoTunes } from "./interfaces/IGhoTunes.sol";

contract GHOTunes is GHOTunesBase, ERC721, ERC721URIStorage, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;

    constructor(
        address initialOwner,
        address _accountRegistry,
        address _implementation,
        TIER[] memory _tiers
    )
        ERC721("GHO Tunes", "TUNES")
        Ownable(initialOwner)
    {
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

    function depositAndSubscribe(
        address user,
        uint8 tier,
        uint256 durationInMonths,
        uint256 deadline,
        Signature memory wETHPermit,
        Signature memory ghoPermit
    )
        external
        payable
    {
        require(accounts[user] == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");
        require(msg.value >= calculateETHRequired(tier), "GHOTunes: Insufficient ETH");
        require(block.timestamp <= deadline, "GHOTunes: Invalid Expiration");
        require(durationInMonths > 0, "GHOTunes: Invalid Duration");

        uint256 value = msg.value;
        uint256 amount = tiers[tier].price;

        // Mint NFT to user.
        uint256 tokenId = _nextTokenId++;
        string memory uri = _buildURI(tokenId, tier);
        uint256 salt = 1;
        _safeMint(user, tokenId);
        _setTokenURI(tokenId, uri);
        console2.log("Minted NFT: ", tokenId);

        // Create ERC6551 Account
        accountRegistry.createAccount(implementation, block.chainid, address(this), tokenId, salt, "");
        address accountAddress = accountRegistry.account(implementation, block.chainid, address(this), tokenId, salt);
        console2.log("Created ERC-6551 Account: ", accountAddress);
        accounts[user] = accountAddress;

        // Supply Aave
        wEthGateway.depositETH{ value: value }(address(aavePool), user, 0);
        DebtTokenBase(AaveV3SepoliaAssets.WETH_V_TOKEN).delegationWithSig(
            user, address(wEthGateway), value, deadline, wETHPermit.v, wETHPermit.r, wETHPermit.s
        );
        getABalance(user);
        getUserData(user);

        // Borrow GHO
        console2.log("Borrow GHO: ", amount);
        DebtTokenBase(AaveV3SepoliaAssets.GHO_V_TOKEN).delegationWithSig(
            user, address(this), durationInMonths * amount, deadline, ghoPermit.v, ghoPermit.r, ghoPermit.s
        );
        aavePool.borrow(address(ghoToken), amount, 2, 0, user);

        // log balance of gho
        uint256 balance = ghoToken.balanceOf(address(this));
        console2.log("Balance GHO: ", balance);
    }

    function getUserData(address user) public view {
        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = aavePool.getUserAccountData(user);
        console2.log("Total Collateral Base: ", totalCollateralBase);
        console2.log("Total Debt Base: ", totalDebtBase);
        console2.log("Available Borrows Base: ", availableBorrowsBase);
        console2.log("Current Liquidation Threshold: ", currentLiquidationThreshold);
        console2.log("LTV: ", ltv);
        console2.log("Health Factor: ", healthFactor);
    }

    function getABalance(address user) public view returns (uint256) {
        uint256 balance = IAToken(AaveV3SepoliaAssets.WETH_A_TOKEN).balanceOf(user);
        console2.log("Balance aWETH: ", balance);
        return balance;
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
