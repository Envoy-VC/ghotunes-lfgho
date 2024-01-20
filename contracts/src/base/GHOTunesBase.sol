// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC-6551 Token Bound Accounts
import { IERC6551Registry } from "../interfaces/IERC6551Registry.sol";

// Aave V3 Contracts
import { AaveV3Sepolia, AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";

// Chainlink Imports
import { IAutomationRegistrar } from "../interfaces/chainlink/IAutomationRegistrar.sol";
import { CronUpkeep } from "@chainlink/contracts/src/v0.8/automation/upkeeps/CronUpkeep.sol";

// Library Imports
import { TunesLibrary } from "../lib/Tunes.sol";

// Interfaces
import { IToken } from "../token/Token.sol";
import "../interfaces/IGhoTunes.sol";

// Utils
import { TimestampConverter } from "../utils/TimeStamp.sol";

abstract contract GHOTunesBase {
    address public owner;
    // ERC-6551 Token Bound Account Implementation
    address public implementation;

    // GHO Price in USD
    uint256 public constant GHO_PRICE_USD = 1e8;

    // ERC-6551 Token Bound Account Registry
    IERC6551Registry public accountRegistry;

    // Mapping of Token ID to Account Address
    mapping(address => User) public accounts;

    // Tiers of GHO Tunes
    uint256 public totalTiers;
    mapping(uint256 => TIER) public tiers;
    IToken public token;

    function calculateETHRequired(uint256 _tier) public view returns (uint256) {
        TIER memory tier = tiers[_tier];
        uint256 tierPrice = tier.price;
        uint256 assetPrice = TunesLibrary.priceOracle.getAssetPrice(AaveV3SepoliaAssets.WETH_UNDERLYING);
        (, uint256 ltv,,,,,,,,) =
            TunesLibrary.poolDataProvider.getReserveConfigurationData(AaveV3SepoliaAssets.WETH_UNDERLYING);
        uint256 ethRequired = (tierPrice * GHO_PRICE_USD * 1e4) / (ltv * assetPrice);
        return ethRequired;
    }

    function createCronUpkeep(address _for) public returns (UpkeepDetails memory) {
        string memory cronString = TimestampConverter.getCronString();
        bytes memory trigger = abi.encodeWithSignature("performUpkeep()");
        bytes memory encodedJob = TunesLibrary.cronUpkeepFactory.encodeCronJob(_for, trigger, cronString);

        CronUpkeep cronUpkeep = new CronUpkeep(address(this), 0x22b880E90Ced10d1ddc6Bb6d1a87Ef1Cf9A8E2c2, 5, encodedJob);

        IAutomationRegistrar.RegistrationParams memory registrationParams = IAutomationRegistrar.RegistrationParams({
            name: "GHO Tunes Subscription",
            encryptedEmail: "0x",
            upkeepContract: address(cronUpkeep),
            gasLimit: 500_000,
            adminAddress: address(this),
            triggerType: 0,
            checkData: "0x",
            triggerConfig: "0x",
            offchainConfig: "0x",
            amount: 1 ether
        });
        (bool success,) = address(TunesLibrary.linkToken).call(
            abi.encodeWithSignature("approve(address,uint256)", address(TunesLibrary.automationRegistrar), 1 ether)
        );
        require(success, "GHOTunes: Failed to approve LINK");

        uint256 upkeepId = TunesLibrary.automationRegistrar.registerUpkeep(registrationParams);

        UpkeepDetails memory upkeepDetails = UpkeepDetails({
            upkeepAddress: address(cronUpkeep),
            forwarderAddress: address(TunesLibrary.keeperRegistry.getForwarder(upkeepId)),
            upkeepId: upkeepId
        });

        return upkeepDetails;
    }

    function updateCronUpkeep(address _for) internal {
        User storage user = accounts[_for];
        address upkeepAddress = user.upkeepDetails.upkeepAddress;
        CronUpkeep upkeep = CronUpkeep(payable(upkeepAddress));
        string memory cronString = TimestampConverter.getCronString();
        bytes memory trigger = abi.encodeWithSignature("performUpkeep()");
        bytes memory encodedJob = TunesLibrary.cronUpkeepFactory.encodeCronJob(user.accountAddress, trigger, cronString);

        (address target, bytes memory handler, Spec memory spec) = abi.decode(encodedJob, (address, bytes, Spec));

        upkeep.updateCronJob(1, target, handler, abi.encode(spec));
    }

    function borrowGHO(address onBehalfOf, uint256 amount) internal {
        if (amount == 0) return;
        require(
            TunesLibrary.vGHO.borrowAllowance(onBehalfOf, address(this)) >= amount,
            "GHOTunes: Insufficient GHO Delegated"
        );
        TunesLibrary.aavePool.borrow(address(TunesLibrary.ghoToken), amount, 2, 0, onBehalfOf);
    }
}
