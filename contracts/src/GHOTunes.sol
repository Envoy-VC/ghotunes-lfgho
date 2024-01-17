// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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
import {
    IKeeperRegistry,
    IAutomationForwarder,
    IAutomationRegistryConsumer
} from "./interfaces/chainlink/IKeeperRegistry.sol";
import { CronUpkeep } from "@chainlink/contracts/src/v0.8/automation/upkeeps/CronUpkeep.sol";

contract GHOTunes is GHOTunesBase, ERC721, ERC721URIStorage, ERC721Pausable, Ownable {
    uint256 public _nextTokenId;

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

    function createAccount(address user, uint8 tier) internal {
        require(accounts[user].accountAddress == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");

        // Mint NFT
        uint256 tokenId = _nextTokenId++;
        string memory uri = _buildURI(tokenId, tier);
        uint256 salt = 1;
        _safeMint(user, tokenId);
        _setTokenURI(tokenId, uri);

        // Create ERC6551 Account
        accountRegistry.createAccount(implementation, block.chainid, address(this), tokenId, salt, "");
        address accountAddress = accountRegistry.account(implementation, block.chainid, address(this), tokenId, salt);

        if (tiers[tier].price == 0) {
            accounts[user] = User({
                currentTier: tier,
                nextTier: tier,
                accountAddress: accountAddress,
                validUntil: block.timestamp + 30 days,
                upkeepDetails: UpkeepDetails({
                    jobId: 0,
                    upkeepAddress: address(0),
                    forwarderAddress: address(0),
                    upkeepId: 0
                })
            });
            return;
        }

        UpkeepDetails memory upkeepDetails = createCronUpkeep(accountAddress);
        GHOTunesAccount account = GHOTunesAccount(payable(accountAddress));
        account.initialize(upkeepDetails.forwarderAddress);

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
        vGHO.delegationWithSig(
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
        require(ghoToken.balanceOf(user) >= amount, "GHOTunes: Insufficient GHO");
        require(ghoToken.allowance(user, address(this)) >= amount, "GHOTunes: Insufficient GHO Allowance");
        require(accounts[user].accountAddress == address(0), "GHOTunes: Account already exists");
        require(tier < totalTiers, "GHOTunes: Invalid Tier");

        ghoToken.transferFrom(user, address(this), amount);
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
        wEthGateway.depositETH{ value: value }(address(aavePool), user, 0);
        vWETH.delegationWithSig(
            user, address(wEthGateway), value, wETHPermit.deadline, wETHPermit.v, wETHPermit.r, wETHPermit.s
        );

        // Borrow GHO
        vGHO.delegationWithSig(
            user, address(this), durationInMonths * amount, ghoPermit.deadline, ghoPermit.v, ghoPermit.r, ghoPermit.s
        );
        borrowGHO(user, amount);
        createAccount(user, tier);
    }

    function changeTier(uint256 tokenId, uint8 nextTier) public {
        address owner = ownerOf(tokenId);
        require(owner == msg.sender, "GHOTunes: Only owner can change tier");
        User storage user = accounts[owner];
        user.nextTier = nextTier;
    }

    function renew(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        User storage user = accounts[owner];
        require(user.accountAddress != address(0), "GHOTunes: Account does not exist");
        require(msg.sender == user.accountAddress || msg.sender == owner, "GHOTunes: Only Account or Owner can renew");

        uint8 currentTier = user.currentTier;
        uint8 nextTier = user.nextTier;

        uint256 amount = tiers[nextTier].price;

        if (nextTier == currentTier) {
            if (nextTier == 0) {
                return;
            }
            borrowGHO(owner, amount);
            user.validUntil = block.timestamp + 30 days;
        } else if (nextTier > currentTier) {
            if (currentTier == 0) {
                // User subscribing to paid tier.
                if (user.upkeepDetails.upkeepAddress == address(0)) {
                    // Create Upkeep
                    UpkeepDetails memory upkeepDetails = createCronUpkeep(user.accountAddress);
                    user.upkeepDetails = upkeepDetails;
                } else {
                    // Delete previous Job
                    address upkeepAddress = user.upkeepDetails.upkeepAddress;
                    CronUpkeep upkeep = CronUpkeep(payable(upkeepAddress));
                    upkeep.deleteCronJob(user.upkeepDetails.jobId);

                    // Create new Job
                    string memory cronString = getCronString();
                    bytes memory trigger = abi.encodeWithSignature("performUpkeep()");
                    bytes memory encodedJob = cronUpkeepFactory.encodeCronJob(user.accountAddress, trigger, cronString);

                    (address target, bytes memory handler, Spec memory spec) =
                        abi.decode(encodedJob, (address, bytes, Spec));

                    upkeep.createCronJobFromEncodedSpec(target, handler, abi.encode(spec));

                    try upkeep.unpause() { } catch { }

                    user.upkeepDetails.jobId++;
                }
            } else {
                // if user is calling then create new job as cron is not valid now
                if (msg.sender == user.accountAddress) {
                    // Delete previous Job
                    address upkeepAddress = user.upkeepDetails.upkeepAddress;
                    CronUpkeep upkeep = CronUpkeep(payable(upkeepAddress));
                    upkeep.deleteCronJob(user.upkeepDetails.jobId);

                    // Create new Job
                    string memory cronString = getCronString();
                    bytes memory trigger = abi.encodeWithSignature("performUpkeep()");
                    bytes memory encodedJob = cronUpkeepFactory.encodeCronJob(user.accountAddress, trigger, cronString);

                    (address target, bytes memory handler, Spec memory spec) =
                        abi.decode(encodedJob, (address, bytes, Spec));
                    upkeep.createCronJobFromEncodedSpec(target, handler, abi.encode(spec));
                    user.upkeepDetails.jobId++;
                }
            }
            borrowGHO(owner, amount);
            user.currentTier = nextTier;
            user.validUntil = block.timestamp + 30 days;
            _setTokenURI(tokenId, _buildURI(tokenId, nextTier));
        } else {
            // user is downgrading

            // if manually then create new job if not to free tier
            if (msg.sender == user.accountAddress && nextTier > 0) {
                // Delete previous Job
                address upkeepAddress = user.upkeepDetails.upkeepAddress;
                CronUpkeep upkeep = CronUpkeep(payable(upkeepAddress));
                upkeep.deleteCronJob(user.upkeepDetails.jobId);

                // Create new Job
                string memory cronString = getCronString();
                bytes memory trigger = abi.encodeWithSignature("performUpkeep()");
                bytes memory encodedJob = cronUpkeepFactory.encodeCronJob(user.accountAddress, trigger, cronString);

                (address target, bytes memory handler, Spec memory spec) =
                    abi.decode(encodedJob, (address, bytes, Spec));
                upkeep.createCronJobFromEncodedSpec(target, handler, abi.encode(spec));
                user.upkeepDetails.jobId++;
            }
            borrowGHO(owner, amount);
            user.currentTier = nextTier;
            if (nextTier == 0) {
                user.validUntil = type(uint256).max;
            } else {
                user.validUntil = block.timestamp + 30 days;
            }
            _setTokenURI(tokenId, _buildURI(tokenId, nextTier));
        }
    }

    function handleRenewFail(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        User storage user = accounts[owner];
        require(user.accountAddress != address(0), "GHOTunes: Account does not exist");
        require(msg.sender == user.accountAddress || msg.sender == owner, "GHOTunes: Only Account or Owner can renew");

        address upkeepAddress = user.upkeepDetails.upkeepAddress;
        CronUpkeep upkeep = CronUpkeep(payable(upkeepAddress));
        upkeep.pause();

        user.currentTier = 0;
        user.nextTier = 0;
        user.validUntil = type(uint256).max;
        _setTokenURI(tokenId, _buildURI(tokenId, 0));
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
