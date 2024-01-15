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
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { IAToken } from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import { IWrappedTokenGatewayV3 } from "./interfaces/IWrappedTokenGatewayV3.sol";
import { IPriceOracle } from "@aave/core-v3/contracts/interfaces/IPriceOracle.sol";
import { AaveV3Sepolia, AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";
import { IPoolDataProvider } from "@aave/core-v3/contracts/interfaces/IPoolDataProvider.sol";
import { IVariableDebtToken } from "@aave/core-v3/contracts/interfaces/IVariableDebtToken.sol";
import { DebtTokenBase } from "@aave/core-v3/contracts/protocol/tokenization/base/DebtTokenBase.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

contract GHOTunes is ERC721, ERC721URIStorage, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    AccountRegistry public accountRegistry;
    IPoolAddressesProvider public aaveAddressesProvider;
    IPriceOracle public priceOracle;
    IPoolDataProvider public poolDataProvider;
    IPool public aavePool;
    IWrappedTokenGatewayV3 public wEthGateway;
    IAToken public aWETH;

    address public implementation;

    uint256 public constant GHO_PRICE_USD = 1e8;

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
        aavePool = IPool(address(AaveV3Sepolia.POOL));
        wEthGateway = IWrappedTokenGatewayV3(AaveV3Sepolia.WETH_GATEWAY);
        aWETH = IAToken(address(AaveV3SepoliaAssets.WETH_A_TOKEN));
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
        uint256 assetPrice = priceOracle.getAssetPrice(AaveV3SepoliaAssets.WETH_UNDERLYING);
        (, uint256 ltv,,,,,,,,) = poolDataProvider.getReserveConfigurationData(AaveV3SepoliaAssets.WETH_UNDERLYING);
        uint256 ethRequired = (tierPrice * GHO_PRICE_USD * 1e4) / (ltv * assetPrice);
        return ethRequired;
    }

    function depositAndSubscribe(
        address user,
        uint256 tier,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint8 v1,
        bytes32 r1,
        bytes32 s1
    )
        public
        payable
    {
        require(accounts[user] == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");
        require(msg.value >= calculateETHRequired(tier), "GHOTunes: Insufficient ETH");
        uint256 value = msg.value;
        uint256 amount = tiers[tier].price;

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

        // Supply Aave
        wEthGateway.depositETH{ value: value }(address(aavePool), user, 0);
        DebtTokenBase(AaveV3SepoliaAssets.WETH_V_TOKEN).delegationWithSig(
            user, address(wEthGateway), value, deadline, v, r, s
        );
        getABalance(user);
        getUserData(user);

        // Borrow GHO
        console2.log("Borrow GHO: ", amount);
        DebtTokenBase(AaveV3SepoliaAssets.GHO_V_TOKEN).delegationWithSig(
            user, address(this), amount, deadline, v1, r1, s1
        );
        aavePool.borrow(AaveV3SepoliaAssets.GHO_UNDERLYING, amount, 2, 0, user);

        // log balance of gho
        uint256 balance = IAToken(AaveV3SepoliaAssets.GHO_UNDERLYING).balanceOf(address(this));
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
