// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IContainerCounterFactory {
    function createCounter(address, uint256) external;
    function current(address account) external view returns (uint256);
    function increment(address account) external;
    function exists(address boardAddr) external view returns (bool);
    function isMaxed(address account) external view returns (bool);
}
