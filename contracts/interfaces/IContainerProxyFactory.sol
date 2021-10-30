// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IContainerProxyFactory {
    function createContainerProxy() external returns (address);
    function getContainerId() external view returns (uint256);
}
