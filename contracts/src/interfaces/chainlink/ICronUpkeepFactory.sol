// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICronUpkeepFactory {
    function newCronUpkeepWithJob(bytes memory encodedJob) external;

    function encodeCronJob(
        address target,
        bytes memory handler,
        string memory cronString
    )
        external
        pure
        returns (bytes memory);
}
