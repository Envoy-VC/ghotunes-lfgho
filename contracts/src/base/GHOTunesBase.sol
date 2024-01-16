// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin Contracts
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// ERC-6551 Token Bound Accounts
import { AccountRegistry } from "../accounts/AccountRegistry.sol";

// Aave V3 Contracts
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { IAToken } from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import { IWrappedTokenGatewayV3 } from "../interfaces/IWrappedTokenGatewayV3.sol";
import { IPriceOracle } from "@aave/core-v3/contracts/interfaces/IPriceOracle.sol";
import { AaveV3Sepolia, AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";
import { IPoolDataProvider } from "@aave/core-v3/contracts/interfaces/IPoolDataProvider.sol";
import { DebtTokenBase } from "@aave/core-v3/contracts/protocol/tokenization/base/DebtTokenBase.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

// Interfaces
import { IGhoToken } from "../interfaces/IGhoToken.sol";
import { IGhoTunes } from "../interfaces/IGhoTunes.sol";

abstract contract GHOTunesBase is IGhoTunes {
    using Strings for uint256;

    // Aave V3 Address Provider
    IPoolAddressesProvider public aaveAddressesProvider =
        IPoolAddressesProvider(address(AaveV3Sepolia.POOL_ADDRESSES_PROVIDER));

    // Aave V3 Price Oracle
    IPriceOracle public priceOracle = IPriceOracle(aaveAddressesProvider.getPriceOracle());

    // Aave V3 Data Provider
    IPoolDataProvider public poolDataProvider = IPoolDataProvider(aaveAddressesProvider.getPoolDataProvider());

    // Aave V3 Pool Contract
    IPool public aavePool = IPool(address(AaveV3Sepolia.POOL));

    // Aave V3 wETH Gateway
    IWrappedTokenGatewayV3 public wEthGateway = IWrappedTokenGatewayV3(AaveV3Sepolia.WETH_GATEWAY);

    // Aave V3 aWETH Token
    IAToken public aWETH = IAToken(address(AaveV3SepoliaAssets.WETH_A_TOKEN));

    DebtTokenBase public vWETH = DebtTokenBase(AaveV3SepoliaAssets.WETH_V_TOKEN);

    // Aave V3 GHO Token
    IGhoToken public ghoToken = IGhoToken(address(AaveV3SepoliaAssets.GHO_UNDERLYING));

    DebtTokenBase public vGHO = DebtTokenBase(AaveV3SepoliaAssets.GHO_V_TOKEN);

    // ERC-6551 Token Bound Account Implementation
    address public implementation;

    // GHO Price in USD
    uint256 public constant GHO_PRICE_USD = 1e8;

    // ERC-6551 Token Bound Account Registry
    AccountRegistry public accountRegistry;

    // Mapping of Token ID to Account Address
    mapping(address => User) public accounts;

    // Tiers of GHO Tunes
    uint256 public totalTiers;
    mapping(uint256 => TIER) public tiers;

    function calculateETHRequired(uint256 _tier) public view returns (uint256) {
        TIER memory tier = tiers[_tier];
        uint256 tierPrice = tier.price;
        uint256 assetPrice = priceOracle.getAssetPrice(AaveV3SepoliaAssets.WETH_UNDERLYING);
        (, uint256 ltv,,,,,,,,) = poolDataProvider.getReserveConfigurationData(AaveV3SepoliaAssets.WETH_UNDERLYING);
        uint256 ethRequired = (tierPrice * GHO_PRICE_USD * 1e4) / (ltv * assetPrice);
        return ethRequired;
    }

    function _buildURI(uint256 tokenId, uint8 tier) internal view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "GHO Tunes #',
            tokenId.toString(),
            '", ',
            '"description": "Recurring Payments based on Aave V3 GHO Token",',
            '"image": "',
            tiers[tier].image,
            '", ',
            '"attributes": [',
            '{"trait_type": "Tier", "value": "',
            tiers[tier].name,
            '"},',
            '{"trait_type": "Price", "value": "',
            (tiers[tier].price / 1e18).toString(),
            ' GHO"},',
            '{"trait_type": "Expires", "display_type": "date", "value": "',
            (block.timestamp + 30 days).toString(),
            '"}',
            "]",
            "}"
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function borrowGHO(address onBehalfOf, uint256 amount) internal {
        if (amount == 0) return;
        require(vGHO.borrowAllowance(onBehalfOf, address(this)) >= amount, "GHOTunes: Insufficient GHO Delegated");
        aavePool.borrow(address(ghoToken), amount, 2, 0, onBehalfOf);
    }
}
