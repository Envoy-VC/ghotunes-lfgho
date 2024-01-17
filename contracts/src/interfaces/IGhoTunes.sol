// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGhoTunes {
    struct UpkeepDetails {
        address upkeepAddress;
        address forwarderAddress;
        uint256 upkeepId;
    }

    struct User {
        uint8 currentTier;
        uint8 nextTier;
        address accountAddress;
        uint256 validUntil;
        UpkeepDetails upkeepDetails;
    }

    struct TIER {
        string name;
        string image;
        uint256 price;
    }

    struct Signature {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    enum FieldType {
        WILD,
        EXACT,
        INTERVAL,
        RANGE,
        LIST
    }

    // A spec represents a cron job by decomposing it into 5 fields
    struct Spec {
        Field minute;
        Field hour;
        Field day;
        Field month;
        Field dayOfWeek;
    }

    // A field represents a single element in a cron spec. There are 5 types
    // of fields (see above). Not all properties of this struct are present at once.
    struct Field {
        FieldType fieldType;
        uint8 singleValue;
        uint8 interval;
        uint8 rangeStart;
        uint8 rangeEnd;
        uint8 listLength;
        uint8[26] list;
    }

    function subscribeWithETH(
        address user,
        uint8 tier,
        uint256 durationInMonths,
        Signature memory wETHPermit,
        Signature memory ghoPermit
    )
        external
        payable;

    function renew(uint256 tokenId) external;

    function handleRenewFail(uint256 tokenId) external;
}
