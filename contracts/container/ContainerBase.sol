// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../interfaces/IContainerCounterFactory.sol";
import "../interfaces/IContainerProxyManager.sol";
import "../interfaces/IContainerProxyFactory.sol";
import "../ContextB.sol";

import "hardhat/console.sol";

/// @author Simon Tian
/// @title A board base contract
abstract contract ContainerBase is ContextB {
    /**
     * @dev Returns the id of this board.
     */
    function _containerId() internal returns (uint256) {
        return _IESA().getContainerIdByAddr(address(this));
    }

    /**
     * @dev Returns the boardInfo struct of this board.
     */
    function _ICCF() internal view returns (IContainerCounterFactory) {
        return IContainerCounterFactory(_IESA().getContractAddr("ContainerCounterFactory"));
    }

    /**
     * @dev Returns the boardInfo struct of this board.
     */
    function _ICPM() internal view returns (IContainerProxyManager) {
        return IContainerProxyManager(_IESA().getContractAddr("ContainerProxyManager"));
    }

    /**
     * @dev Returns the boardInfo struct of this board.
     */
    function _ICPF() internal view returns (IContainerProxyFactory) {
        return IContainerProxyFactory(_IESA().getContractAddr("ContainerProxyFactory"));
    }

    /**
     * @dev Returns if a container has the next container.
     */
    function _hasNext() internal returns (bool) {
        return _IESA().getNextAddr(_containerId()) != address(0);
    }

    /**
     * @dev Returns the successor contract address of this contract.
     */
    function _getNextAddr() internal returns (address) {
        return _IESA().getNextAddr(_containerId());
    }

    /**
     * @dev Returns if this container is activated
     */
    function _isActivated() internal returns (bool) {
        return _IESA().isActivated(_containerId());
    }
}
