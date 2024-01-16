// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITypeAndVersion {
    function typeAndVersion() external pure returns (string memory);
}

interface IAutomationRegistryConsumer {
    function getBalance(uint256 id) external view returns (uint96 balance);

    function getMinBalance(uint256 id) external view returns (uint96 minBalance);

    function cancelUpkeep(uint256 id) external;

    function pauseUpkeep(uint256 id) external;

    function unpauseUpkeep(uint256 id) external;

    function addFunds(uint256 id, uint96 amount) external;

    function withdrawFunds(uint256 id, address to) external;
}

interface IAutomationForwarder is ITypeAndVersion {
    function forward(uint256 gasAmount, bytes memory data) external returns (bool success, uint256 gasUsed);

    function updateRegistry(address newRegistry) external;

    function getRegistry() external view returns (IAutomationRegistryConsumer);

    function getTarget() external view returns (address);
}

interface IKeeperRegistry {
    function getForwarder(uint256 upkeepID) external view returns (IAutomationForwarder);
}
