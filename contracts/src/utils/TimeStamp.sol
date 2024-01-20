// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

library TimestampConverter {
    using Strings for uint256;

    function getCronString() public view returns (string memory) {
        return string.concat("0 0 ", getDayOfMonth(block.timestamp).toString(), " * *");
    }

    function getDayOfMonth(uint256 timestampInSeconds) public pure returns (uint256) {
        uint256 secondsInMinute = 60;
        uint256 secondsInHour = 60 * secondsInMinute;
        uint256 secondsInDay = 24 * secondsInHour;

        // The number of days in each month, considering leap years
        uint8[12] memory daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

        uint256 remainingSeconds = timestampInSeconds;

        // Calculate the year and remaining seconds
        uint256 year = 1970;
        while (true) {
            bool isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
            uint256 daysInYear = isLeap ? 366 : 365;

            if (remainingSeconds < daysInYear * secondsInDay) {
                break;
            }

            remainingSeconds -= daysInYear * secondsInDay;
            year++;
        }

        // Update days in February for leap years
        bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        daysInMonth[1] = isLeapYear ? 29 : 28;

        // Calculate the month and remaining seconds
        uint8 month = 0;
        while (remainingSeconds >= daysInMonth[month] * secondsInDay) {
            remainingSeconds -= daysInMonth[month] * secondsInDay;
            month++;
        }

        // if day of month is 29,30,31 return 28 due to cron not working

        // Calculate the day of the month
        uint256 dayOfMonth = (remainingSeconds / secondsInDay) + 1;

        if (dayOfMonth > 28) {
            dayOfMonth = 28;
        }

        return dayOfMonth;
    }
}
