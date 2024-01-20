// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICronUpkeep {
    function pause() external;
    function unpause() external;
}
