// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../ContextB.sol";

import "hardhat/console.sol";

/// @author Simon Tian
/// @title Counter factory for container counters
contract ContainerCounterFactory is ContextB, Ownable {

    mapping(address => ContainerCounterContract) _counters;

    constructor(address externalStorageAccessAddr_)
        ContextB(externalStorageAccessAddr_)
    {
        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("ContainerCounterFactory", address(this));
    }

    modifier onlyCounterExist(address containerAddr) {
        require(_counters[containerAddr] != ContainerCounterContract(address(0)), "Non-Existing Counter");
        _;
    }

    modifier onlyCounterNotExist(address containerAddr) {
        require(_counters[containerAddr] == ContainerCounterContract(address(0)), "Existing Counter");
        _;
    }

    function exists(address containerAddr) public view returns (bool) {
        if (_counters[containerAddr] != ContainerCounterContract(address(0))) {
            return true;
        } else {
            return false;
        }
    }

    function createCounter(address containerAddr, uint256 maxVal)
        public
        onlyByContract("ContainerProxyFactory")
        onlyCounterNotExist(containerAddr)
    {
        ContainerCounterContract counter =  new ContainerCounterContract(containerAddr, maxVal);
        _counters[containerAddr] = counter;
    }

    function increment(address containerAddr)
        public
        onlyCounterExist(containerAddr)
    {
        require(containerAddr == _msgSender() ||
                _IESA().getNextAddr(_IESA().getContainerIdByAddr(_msgSender())) == containerAddr,
                "Only by container");
        _counters[containerAddr].increment(containerAddr);
    }

    function current(address containerAddr)
        public
        view
        onlyCounterExist(containerAddr)
        returns (uint256)
    {
        return _counters[containerAddr].current();
    }

    function isMaxed(address containerAddr)
        public
        view
        onlyCounterExist(containerAddr)
        returns (bool)
    {
        return _counters[containerAddr].isMaxed(containerAddr);
    }

    function ownerKill() public onlyOwner {
        _IESA().delContractAddr("ContainerCounterFactory");
        selfdestruct(payable(owner()));
    }

}

contract ContainerCounterContract {

    Counter private counter;
    address private containerAddr;
    address private factory;
    uint256 private immutable maxVal;

    struct Counter {
        uint256 value; // default: 0
    }

    /*
        Events & Errors
    */
    error LimitExceeded(
        uint256 current,
        uint256 maxVal
    );

    constructor(address containerAddr_, uint256 maxVal_) {
        containerAddr = containerAddr_;
        factory = msg.sender;
        maxVal = maxVal_;
    }

    modifier onlyOwner(address caller) {
        require(caller == containerAddr, "Only Owner.");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "Only Factory.");
        _;
    }

    function current() public view returns (uint256) {
        return counter.value;
    }

    function increment(address caller)
        public
        onlyFactory
        onlyOwner(caller)
    {
        counter.value++;
        if (current() > maxVal)
            revert LimitExceeded(current(), maxVal);
    }

    function isMaxed(address caller)
        public
        view
        onlyFactory
        onlyOwner(caller)
        returns (bool)
    {
        return current() == maxVal;
    }
}
