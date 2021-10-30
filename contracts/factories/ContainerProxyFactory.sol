// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IContainerCounterFactory.sol";
import "../factories/ContainerCounterFactory.sol";
import "../container/ContainerProxy.sol";
import "../ContextB.sol";

import "hardhat/console.sol";

contract ContainerProxyFactory is ContextB, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _containerId;

    address private _beacon;
    address private _externalStorageAccessAddr;
    uint256 private constant MAX_NUM_CONTAINERS = 400; // 400
    uint256 private constant MAX_NUM_ACTIVE_CONTAINERS = 15; //15
    uint256 private constant MAX_NUM_ZOMBIES = 24;

    constructor(address externalStorageAccessAddr_, address beacon_)
        ContextB(externalStorageAccessAddr_) {
        require(beacon_ != address(0), "Invalid beacon");
        require(IBeacon(beacon_).implementation() != address(0), "Invalid implementation");

        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("ContainerProxyFactory", address(this));

        _beacon = beacon_;
        _externalStorageAccessAddr = externalStorageAccessAddr_;

        _containerId.increment();  // Skip 0
        _init();
    }

    modifier onlyOwnerOrContracts(string memory contractName1, string memory contractName2) {
        require(_msgSender() == owner() ||
                _msgSender() == _IESA().getContractAddr(contractName1) ||
                _msgSender() == _IESA().getContractAddr(contractName2),
                "Not allowed"
            );
        _;
    }

    function createContainerProxy()
        public
        onlyOwnerOrContracts("ContainerProxyManager", "ContainerImplementation")
        returns (address)
    {
        require(_getContainerId() <= MAX_NUM_CONTAINERS, "Max num reached");

        return _createContainerProxy();
    }

    function getContainerId() public view returns (uint256) {
        return _getContainerId();
    }

    function _createContainerProxy() private returns (address) {
        ContainerProxy newContainer = new ContainerProxy(
            _beacon,
            _externalStorageAccessAddr
        );

        uint256 containerId = _getContainerId();
        _IESA().setContainerAddr(containerId, address(newContainer));
        _IESA().setContainerId(containerId, address(newContainer));

        _containerIdIncrement();

        IContainerCounterFactory(_IESA().getContractAddr("ContainerCounterFactory")).createCounter(address(newContainer), MAX_NUM_ZOMBIES);

        return address(newContainer);
    }

    // TODO: initialize variables in ContainerProxyManager
    function _init() private {
        address addr;
        uint256 containerId;
        for (uint256 i = 0; i < MAX_NUM_ACTIVE_CONTAINERS; i++) {
            addr = _createContainerProxy();
            containerId = _IESA().getContainerIdByAddr(addr);
            _IESA().activate(containerId);
        }
    }

    function _getContainerId() internal view returns (uint256) {
        return _containerId.current();
    }

    function _containerIdIncrement() internal {
        require(_getContainerId() <= MAX_NUM_CONTAINERS, "Max number reached");
        _containerId.increment();
    }

    function ownerKill() public onlyOwner {
        _IESA().delContractAddr("ContainerProxyFactory");
        selfdestruct(payable(owner()));
    }
}
