// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IContainerProxyManager {
    function openNext(uint256 containerId, address containerAddr) external;
    function activate(uint256 containerId, address containerAddr) external;
    function deactivate(uint256 containerId, address containerAddr) external;
    function mint(address to, address containerAddr) external;
    function mintLeader(address to, address containerAddr) external;
}
