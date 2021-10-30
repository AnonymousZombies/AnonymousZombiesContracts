// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../ContextB.sol";
import "../interfaces/IContainerProxyFactory.sol";

import "hardhat/console.sol";

interface IZombie {
    function mint(address to) external;
    function mintLeader(address to, uint256 containerId) external;
}

contract ContainerProxyManager is Ownable, ContextB {
    address private _factory;
    address private _zombie;

    constructor(address externalStorageAccessAddr_)
        ContextB(externalStorageAccessAddr_) {
        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("ContainerProxyManager", address(this));

        _factory = _IESA().getContractAddr("ContainerProxyFactory");
        _zombie = _IESA().getContractAddr("Zombies");
    }

    function openNext(uint256 containerId, address containerAddr) public {
        require(_msgSender() == containerAddr, "Access not allowed");
        uint256 _nOpenedContainers = IContainerProxyFactory(_factory).getContainerId();
        
        if (_nOpenedContainers <= 400) { //400
            address nextAddr = IContainerProxyFactory(_factory).createContainerProxy();
            _IESA().setNextAddr(containerId, nextAddr);
        }
    }

    function activate(uint256 containerId, address containerAddr) public {
        require(_msgSender() == containerAddr ||
                _getNextContainerAddr() == containerAddr,
                "Access not allowed");
        _IESA().activate(containerId);
    }

    function deactivate(uint256 containerId, address containerAddr) public {
        require(_msgSender() == containerAddr, "Access not allowed");
        _IESA().deactivate(containerId);
    }

    function mint(address to, address containerAddr) public {
        require(_msgSender() == containerAddr, "Access not allowed");
        IZombie(_zombie).mint(to);
    }

    function mintLeader(address to, address containerAddr) public {
        require(_msgSender() == containerAddr, "Access not allowed");
        IZombie(_zombie).mintLeader(to, _IESA().getContainerIdByAddr(containerAddr));
    }

    function ownerKill() public onlyOwner {
        _IESA().delContractAddr("ContainerProxyManager");
        selfdestruct(payable(owner()));
    }

    function _getNextContainerAddr() private returns (address) {
        return _IESA().getNextAddr(_IESA().getContainerIdByAddr(_msgSender()));
    }
}
