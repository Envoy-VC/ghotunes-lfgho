// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Base
import { GHOTunesBase } from "./base/GHOTunesBase.sol";

// ERC-6551 Token Bound Accounts
import { IERC6551Registry } from "./interfaces/IERC6551Registry.sol";
import { IAccount } from "./accounts/Account.sol";

// Aave V3 Contracts
import { AaveV3SepoliaAssets } from "aave-address-book/AaveV3Sepolia.sol";
import { DebtTokenBase } from "@aave/core-v3/contracts/protocol/tokenization/base/DebtTokenBase.sol";

// Chainlink Imports
import { ICronUpkeep } from "./interfaces/chainlink/ICronUpkeep.sol";

// Library Imports
import { URILibrary } from "./lib/URI.sol";
import { TunesLibrary } from "./lib/Tunes.sol";

// Interfaces
import { IGhoToken } from "./interfaces/IGhoToken.sol";
import { IToken } from "./token/Token.sol";
import "./interfaces/IGhoTunes.sol";

contract GHOTunes is IGhoTunes, GHOTunesBase {
    constructor(
        address _owner,
        address _accountRegistry,
        address _implementation,
        TIER[] memory _tiers,
        address _token
    ) {
        owner = _owner;
        accountRegistry = IERC6551Registry(_accountRegistry);
        implementation = _implementation;
        token = IToken(_token);

        uint256 len = _tiers.length;
        totalTiers = len;
        for (uint256 i = 0; i < len;) {
            tiers[i] = _tiers[i];
            unchecked {
                ++i;
            }
        }
    }

    function createAccount(address user, uint8 tier) internal {
        require(accounts[user].accountAddress == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");

        // Mint NFT
        uint256 tokenId = token.mint(user, tiers[tier]);

        // Create ERC6551 Account
        uint256 salt = 1;
        accountRegistry.createAccount(implementation, block.chainid, address(token), tokenId, salt, "");
        address accountAddress = accountRegistry.account(implementation, block.chainid, address(token), tokenId, salt);

        if (tiers[tier].price == 0) {
            accounts[user] = User({
                currentTier: tier,
                nextTier: tier,
                accountAddress: accountAddress,
                validUntil: block.timestamp + 30 days,
                upkeepDetails: UpkeepDetails({ upkeepAddress: address(0), forwarderAddress: address(0), upkeepId: 0 })
            });
            return;
        }

        UpkeepDetails memory upkeepDetails = createCronUpkeep(accountAddress);
        IAccount account = IAccount(accountAddress);
        account.initialize(upkeepDetails.forwarderAddress, address(this));

        accounts[user] = User({
            currentTier: tier,
            nextTier: tier,
            accountAddress: accountAddress,
            validUntil: block.timestamp + 30 days,
            upkeepDetails: upkeepDetails
        });
    }

    function delegateGHO(address user, Signature memory permit, uint8 tier, uint256 durationInMonths) public {
        uint256 amount = tiers[tier].price;
        TunesLibrary.vGHO.delegationWithSig(
            user, address(this), durationInMonths * amount, permit.deadline, permit.v, permit.r, permit.s
        );
    }

    function subscribe(address user, uint8 tier) external {
        require(accounts[user].accountAddress == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");
        uint256 amount = tiers[tier].price;
        borrowGHO(user, amount);
        createAccount(user, tier);
    }

    function subscribeWithGHO(address user, uint8 tier) external {
        uint256 amount = tiers[tier].price;
        require(TunesLibrary.ghoToken.balanceOf(user) >= amount, "GHOTunes: Insufficient GHO");
        require(TunesLibrary.ghoToken.allowance(user, address(this)) >= amount, "GHOTunes: Insufficient GHO Allowance");
        require(accounts[user].accountAddress == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");

        TunesLibrary.ghoToken.transferFrom(user, address(this), amount);
        createAccount(user, tier);
    }

    function subscribeWithETH(
        address user,
        uint8 tier,
        uint256 durationInMonths,
        Signature memory wETHPermit,
        Signature memory ghoPermit
    )
        external
        payable
    {
        require(accounts[user].accountAddress == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");
        require(msg.value >= calculateETHRequired(tier), "GHOTunes: Insufficient ETH");
        require(durationInMonths > 0, "GHOTunes: Invalid Duration");

        uint256 value = msg.value;
        uint256 amount = tiers[tier].price;

        // Supply ETH to Aave
        TunesLibrary.wEthGateway.depositETH{ value: value }(address(TunesLibrary.aavePool), user, 0);
        TunesLibrary.vWETH.delegationWithSig(
            user,
            address(TunesLibrary.wEthGateway),
            value,
            wETHPermit.deadline,
            wETHPermit.v,
            wETHPermit.r,
            wETHPermit.s
        );

        // Borrow GHO
        TunesLibrary.vGHO.delegationWithSig(
            user, address(this), durationInMonths * amount, ghoPermit.deadline, ghoPermit.v, ghoPermit.r, ghoPermit.s
        );
        borrowGHO(user, amount);
        createAccount(user, tier);
    }

    function changeTier(uint256 tokenId, uint8 nextTier) public {
        address owner = token.ownerOf(tokenId);
        require(owner == msg.sender, "GHOTunes: Only owner can change tier");
        User storage user = accounts[owner];
        user.nextTier = nextTier;
    }

    function renew(uint256 tokenId) external {
        address owner = token.ownerOf(tokenId);
        User storage user = accounts[owner];
        require(user.accountAddress != address(0), "GHOTunes: Account does not exist");
        require(msg.sender == user.accountAddress || msg.sender == owner, "GHOTunes: Only Account or Owner can renew");

        uint8 currentTier = user.currentTier;
        uint8 nextTier = user.nextTier;
        uint256 amount = tiers[nextTier].price;

        if (nextTier == currentTier) {
            require(nextTier > 0, "GHOTunes: Invalid Tier");
        } else if (nextTier > currentTier) {
            if (currentTier == 0) {
                if (user.upkeepDetails.upkeepAddress == address(0)) {
                    UpkeepDetails memory upkeepDetails = createCronUpkeep(user.accountAddress);
                    user.upkeepDetails = upkeepDetails;
                } else {
                    updateCronUpkeep(owner);
                    address upkeepAddress = user.upkeepDetails.upkeepAddress;
                    ICronUpkeep upkeep = ICronUpkeep(upkeepAddress);
                    try upkeep.unpause() { } catch { }
                }
            } else {
                if (msg.sender == user.accountAddress) {
                    updateCronUpkeep(owner);
                }
            }
        } else {
            if (msg.sender == user.accountAddress && nextTier > 0) {
                updateCronUpkeep(owner);
            }
        }
        borrowGHO(owner, amount);
        user.currentTier = nextTier;
        if (nextTier == 0) {
            user.validUntil = type(uint256).max;
        } else {
            user.validUntil = block.timestamp + 30 days;
        }
        token.setTokenURI(tokenId, URILibrary._buildURI(tokenId, tiers[nextTier]));
    }

    function handleRenewFail(uint256 tokenId) external {
        address owner = token.ownerOf(tokenId);
        User storage user = accounts[owner];
        require(user.accountAddress != address(0), "GHOTunes: Account does not exist");
        require(msg.sender == user.accountAddress || msg.sender == owner, "GHOTunes: Only Account or Owner can renew");

        address upkeepAddress = user.upkeepDetails.upkeepAddress;
        ICronUpkeep upkeep = ICronUpkeep(upkeepAddress);
        upkeep.pause();

        user.currentTier = 0;
        user.nextTier = 0;
        user.validUntil = type(uint256).max;
        token.setTokenURI(tokenId, URILibrary._buildURI(tokenId, tiers[0]));
    }

    function withdrawLink() external {
        uint256 balance = TunesLibrary.linkToken.balanceOf(address(this));
        TunesLibrary.linkToken.transfer(owner, balance);
    }
}
