// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Aave V3 Contracts
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { IAToken } from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import { IWrappedTokenGatewayV3 } from "../interfaces/IWrappedTokenGatewayV3.sol";
import { IPriceOracle } from "@aave/core-v3/contracts/interfaces/IPriceOracle.sol";
import { AaveV3Sepolia, AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";
import { IPoolDataProvider } from "@aave/core-v3/contracts/interfaces/IPoolDataProvider.sol";
import { DebtTokenBase } from "@aave/core-v3/contracts/protocol/tokenization/base/DebtTokenBase.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import { IGhoToken } from "../interfaces/IGhoToken.sol";

import { ICronUpkeepFactory } from "../interfaces/chainlink/ICronUpkeepFactory.sol";
import { IAutomationRegistrar } from "../interfaces/chainlink/IAutomationRegistrar.sol";
import { CronUpkeep } from "@chainlink/contracts/src/v0.8/automation/upkeeps/CronUpkeep.sol";
import { IERC677 } from "@chainlink/contracts/src/v0.8/shared/token/ERC677/IERC677.sol";
import {
    IKeeperRegistry,
    IAutomationForwarder,
    IAutomationRegistryConsumer
} from "../interfaces/chainlink/IKeeperRegistry.sol";

// Interfaces
import { IToken } from "../token/Token.sol";
import "../interfaces/IGhoTunes.sol";

interface ILink is IERC20, IERC677 { }

library TunesLibrary {
    // Aave V3 Address Provider
    IPoolAddressesProvider public constant aaveAddressesProvider =
        IPoolAddressesProvider(address(AaveV3Sepolia.POOL_ADDRESSES_PROVIDER));

    // Aave V3 Data Provider
    IPoolDataProvider public constant poolDataProvider =
        IPoolDataProvider(address(AaveV3Sepolia.AAVE_PROTOCOL_DATA_PROVIDER));

    IPriceOracle public constant priceOracle = IPriceOracle(0x2da88497588bf89281816106C7259e31AF45a663);

    // Aave V3 Pool Contract
    IPool public constant aavePool = IPool(address(AaveV3Sepolia.POOL));

    // Aave V3 wETH Gateway
    IWrappedTokenGatewayV3 public constant wEthGateway = IWrappedTokenGatewayV3(AaveV3Sepolia.WETH_GATEWAY);

    // Aave V3 aWETH Token
    IAToken public constant aWETH = IAToken(address(AaveV3SepoliaAssets.WETH_A_TOKEN));

    DebtTokenBase public constant vWETH = DebtTokenBase(AaveV3SepoliaAssets.WETH_V_TOKEN);

    // Aave V3 GHO Token
    IGhoToken public constant ghoToken = IGhoToken(address(AaveV3SepoliaAssets.GHO_UNDERLYING));

    DebtTokenBase public constant vGHO = DebtTokenBase(AaveV3SepoliaAssets.GHO_V_TOKEN);

    // Chainlink Tokens
    address constant CRON_UPKEEP_FACTORY_SEPOLIA = 0x282CC3d6041f567d129214FfC9dd3FB57076e3b8;
    address constant AUTOMATION_REGISTRAR_SEPOLIA = 0xb0E49c5D0d05cbc241d68c05BC5BA1d1B7B72976;
    address constant LINK_TOKEN_SEPOLIA = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address constant KeeperRegistrySepolia = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;

    // Chainlink Contracts
    ICronUpkeepFactory public constant cronUpkeepFactory = ICronUpkeepFactory(CRON_UPKEEP_FACTORY_SEPOLIA);
    IKeeperRegistry constant keeperRegistry = IKeeperRegistry(KeeperRegistrySepolia);
    IAutomationRegistrar public constant automationRegistrar = IAutomationRegistrar(AUTOMATION_REGISTRAR_SEPOLIA);
    ILink public constant linkToken = ILink(LINK_TOKEN_SEPOLIA);
}
