// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IExternalStorageAccess {
    /**
     * @dev Emits when the contract `contractName` is set with an address
     * `contractAddr`.
     */
    event SetContractAddr(string indexed contractName, address contractAddr);

    function getOwner() external view returns (address);

    function setContractAddr(string memory contractName, address contractAddr) external;
    function getContractAddr(string memory contractName) external view returns (address);
    function delContractAddr(string memory contractName) external;

    function setContractPermission(address contractAddr, address caller) external;

    function setContainerAddr(uint256 containerId, address containerAddr) external;
    function getContainerAddrById(uint256 containerId) external returns (address);
    function setContainerId(uint256 containerId, address containerAddr) external;
    function getContainerIdByAddr(address containerAddr) external returns (uint256);

    // startingIndex
    function setStartingIndex(uint256 startingIndex) external;
    function getStartingIndex() external returns (uint256);

    function setNextAddr(uint256 containerId, address successorAddr) external;
    function getNextAddr(uint256 containerId) external view returns (address);

    function activate(uint256 containerId) external;
    function deactivate(uint256 containerId) external;
    function isActivated(uint256 containerId) external view returns (bool);

    /* System-level parameters */
    function setMaxNumOfContainers(uint256 nContainers) external;
    function getMaxNumOfContainers() external view returns (uint256);
    function setMaxNumOfActiveContainers(uint256 nContainers) external;
    function getMaxNumOfActiveContainers() external view returns (uint256);
    function setNumOfZombiesPerContainer(uint256 nZombies) external;
    function getNumOfZombiesPerContainer() external view returns (uint256);
    function setOpeningThreshhold(uint256 nZombies) external;
    function getOpeningThreshhold() external view returns (uint256);
}
