// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TimestampConverter {
    function isLeapYear(uint16 year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        } else if (year % 100 != 0) {
            return true;
        } else {
            return year % 400 == 0;
        }
    }

    function getDayOfMonth(uint256 timestamp) public pure returns (uint8) {
        uint256 secondsInDay = 24 * 60 * 60;
        uint256 secondsInYear = 365 * secondsInDay;

        // Leap year has one extra day
        uint256 daysInYear = 365;
        if (isLeapYear(uint16(1970 + (timestamp / secondsInYear)))) {
            daysInYear++;
        }

        uint256 daysSinceEpoch = timestamp / secondsInDay;
        uint256 year;
        uint256 daysLeft = daysSinceEpoch;

        // Calculate the year
        while (daysLeft >= daysInYear) {
            if (isLeapYear(uint16(year))) {
                daysLeft -= daysInYear;
            } else {
                daysLeft -= daysInYear - 1;
            }
            year++;
        }

        // Calculate the month
        uint8 month = 1;
        uint256 daysInMonth;
        while (daysLeft >= (daysInMonth = getDaysInMonth(year, month))) {
            daysLeft -= daysInMonth;
            month++;
        }

        // Calculate the day of the month
        uint8 dayOfMonth = uint8(daysLeft + 1);

        return dayOfMonth;
    }

    function getDaysInMonth(uint256 year, uint8 month) internal pure returns (uint256) {
        if (month == 2) {
            return isLeapYear(uint16(year)) ? 29 : 28;
        } else if (month <= 7) {
            return month % 2 == 0 ? 30 : 31;
        } else {
            return month % 2 == 0 ? 31 : 30;
        }
    }
}
