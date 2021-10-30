// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./ContainerBase.sol";
import "hardhat/console.sol";

abstract contract ContainerImplementationBase is ContainerBase {
    function _mint() internal {
        _ICPM().mint(_msgSender(), address(this));
    }

    function _mintLeader() internal {
        _ICPM().mintLeader(_msgSender(), address(this));
    }

    function _getNumOfMintedZombies() internal view returns (uint256) {
        return _ICCF().current(address(this));
    }

    function _increment() internal {
        _ICCF().increment(address(this));  // address(this) is the address of the calling container
    }

    function _openNext() internal {
        _ICPM().openNext(_containerId(), address(this));
    }

    function _activate() internal {
        _ICPM().activate(_containerId(), address(this));
    }

    function _deactivate() internal {
        _ICPM().deactivate(_containerId(), address(this));
        _forward();
    }

    function _isMaxed() internal view returns (bool) {
        console.log(_ICPF().getContainerId(), _IESA().getMaxNumOfContainers());
        return _ICPF().getContainerId() - 1 == _IESA().getMaxNumOfContainers();
    }

    function _forward() internal {
        uint256 balance = address(this).balance;
        (bool success, ) = _IESA().getContractAddr("Treasury").call{value: balance}("");
        require(success, "Withdrawal not successul");
    }
}
