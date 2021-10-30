// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ExternalStorageAccessBase.sol";
import "../interfaces/IExternalStorageAccess.sol";

import "hardhat/console.sol";

/// @author Simon Tian
/// @title A contract for accessing storage
contract ExternalStorageAccess is IExternalStorageAccess, Ownable, ExternalStorageAccessBase {
    /**
     * @dev Sets `externalStorageAccessAddr_`.
     */
    constructor(address externalStorageAddr_)
        ExternalStorageAccessBase(externalStorageAddr_) {}

    function getOwner() public view override returns (address) {
        return owner();
    }

    function setContractAddr(string memory contractName, address contractAddr)
        public
        override
        onlyByContractSetter
    {
        bytes32 key = _getStringKey("constants.contractName.", contractName);
        setAddress(key, contractAddr);

        emit SetContractAddr(contractName, contractAddr);
    }

    function getContractAddr(string memory contractName)
        public
        view
        override
        returns (address)
    {
        return _getContractAddr(contractName);
    }

    function delContractAddr(string memory contractName)
        public
        override
        onlyByContractSetter
    {
        bytes32 key = _getStringKey("constants.contractName.", contractName);
        delAddress(key);
    }

    // A new contract would set up the permission to itself first. And replace
    // the existing contract by contract name.
    function setContractPermission(address contractAddr, address caller)
        public
        override
    {
        require(caller == owner());
        _setupRole(CONTRACT_ADDR_SETTER, contractAddr);
    }

    function setContainerAddr(uint256 containerId, address containerAddr)
        public
        override
        onlyByContract("ContainerProxyFactory")
    {
        _setContainerAddr(containerId, containerAddr);
    }

    function setContainerId(uint256 containerId, address containerAddr)
        public
        override
        onlyByContract("ContainerProxyFactory")
    {
        _setContainerId(containerId, containerAddr);
    }

    function getContainerAddrById(uint256 containerId)
        public
        view
        override
        returns (address)
    {
        return _getContainerAddr(containerId);
    }

    function getContainerIdByAddr(address containerAddr)
        public
        view
        override
        returns (uint256)
    {
        return _getContainerId(containerAddr);
    }

    function setNextAddr(uint256 containerId, address nextAddr)
        public
        override
        onlyByContract("ContainerProxyManager")
    {
        _setNextAddr(containerId, nextAddr);
    }

    function getNextAddr(uint256 containerId)
        public
        view
        override
        returns (address)
    {
        return _getNextAddr(containerId);
    }

    function activate(uint256 containerId)
        public
        override
        onlyByContracts("ContainerProxyFactory", "ContainerProxyManager")
    {
        _activate(containerId);
    }

    function deactivate(uint256 containerId)
        public
        override
        onlyByContracts("ContainerProxyFactory", "ContainerProxyManager")
    {
        _deactivate(containerId);
    }

    function isActivated(uint256 containerId)
        public
        view
        override
        returns (bool)
    {
        return _isActivated(containerId);
    }

    /* System-level parameters */
    function setMaxNumOfContainers(uint256 nContainers)
        public
        onlyOwner
        override
    {
        _setMaxNumOfContainers(nContainers);
    }

    function getMaxNumOfContainers()
        public
        view
        override
        returns (uint256)
    {
        return _getMaxNumOfContainers();
    }

    function setNumOfZombiesPerContainer(uint256 nZombies)
        public
        onlyOwner
        override
    {
        _setNumOfZombiesPerContainer(nZombies);
    }

    function getNumOfZombiesPerContainer()
        public
        view
        override
        returns (uint256)
    {
        return _getNumOfZombiesPerContainer();
    }

    function setMaxNumOfActiveContainers(uint256 nContainers)
        public
        onlyOwner
        override
    {
        _setMaxNumOfActiveContainers(nContainers);
    }

    function getMaxNumOfActiveContainers()
        public
        view
        override
        returns (uint256)
    {
        return _getMaxNumOfActiveContainers();
    }

    function setOpeningThreshhold(uint256 nZombies)
        public
        onlyOwner
        override
    {
        _setOpeningThreshhold(nZombies);
    }

    function getOpeningThreshhold()
        public
        view
        override
        returns (uint256)
    {
        return _getOpeningThreshhold();
    }

    function setStartingIndex(uint256 startingIndex)
        public
        onlyByContract("Zombies")
        override
    {
        _setStartingIndex(startingIndex);
    }

    function getStartingIndex()
        public
        view
        override
        returns (uint256)
    {
        return _getStartingIndex();
    }

}
