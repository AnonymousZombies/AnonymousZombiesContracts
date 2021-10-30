// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IExternalStorage.sol";

import "hardhat/console.sol";

/// @author Simon Tian
/// @title Base contract for accessing storage
abstract contract ExternalStorageAccessBase is AccessControl, Ownable {
    bytes32 public constant ADMIN_ROLE =
        keccak256(abi.encodePacked("ADMIN_ROLE"));
    bytes32 public constant CONTRACT_ADDR_SETTER =
        keccak256(abi.encodePacked("CONTRACT_ADDR_SETTER"));

    address private externalStorageAddr;

    /**
     * @dev Sets `externalStorageAccessAddr_`.
     */
    constructor(address externalStorageAddr_) {
        externalStorageAddr = externalStorageAddr_;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setRoleAdmin(CONTRACT_ADDR_SETTER, DEFAULT_ADMIN_ROLE);
    }

    // n == 1
    modifier onlyByContract(string memory contractName) {
        require(
            _msgSender() == _getContractAddr(contractName),
            "Invalid Contract"
        );
        _;
    }

    // n == 2
    modifier onlyByContracts(
        string memory contractName1,
        string memory contractName2
    ) {
        require(
            _msgSender() == _getContractAddr(contractName1) ||
            _msgSender() == _getContractAddr(contractName2),
            "Invalid Contract"
        );
        _;
    }

    // n > 2
    modifier onlyByContractSetter() {
        require(
            hasRole(CONTRACT_ADDR_SETTER, _msgSender()),
            "Not contract setter role"
        );
        _;
    }

    modifier onlyByContainerId(uint256 containerId) {
        require(_msgSender() != _getContainerAddr(containerId));
        _;
    }

    // utility functions
    function _setContainerAddr(uint256 containerId, address containerAddr)
        internal
    {
        bytes32 key = _getUintKey("constants.containerAddr.", containerId);
        setAddress(key, containerAddr);
    }

    function _getContainerAddr(uint256 containerId)
        internal
        view
        returns (address)
    {
        bytes32 key = _getUintKey("constants.containerAddr.", containerId);
        return getAddress(key);
    }

    function _setContainerId(uint256 containerId, address containerAddr)
        internal
    {
        bytes32 key = _getAddressKey("constants.containerId.", containerAddr);
        setUint(key, containerId);
    }

    function _getContainerId(address containerAddr)
        internal
        view
        returns (uint256)
    {
        bytes32 key = _getAddressKey("constants.containerId.", containerAddr);
        return getUint(key);
    }

    function _getContractAddr(string memory contractName)
        internal
        view
        returns (address)
    {
        bytes32 key = _getStringKey("constants.contractName.", contractName);
        return getAddress(key);
    }

    function _setNextAddr(uint256 containerId, address nextAddr) internal {
        bytes32 key = _getUintKey("constants.nextAddr.", containerId);
        setAddress(key, nextAddr);
    }

    // set startingIndex
    function _setStartingIndex(uint256 startingIndex) internal {
        bytes32 key = _getStringKey("constants.startIndex.", "");
        setUint(key, startingIndex);
    }

    function _getStartingIndex() internal view returns (uint256) {
        bytes32 key = _getStringKey("constants.startIndex.", "");
        return getUint(key);
    }

    function _getNextAddr(uint256 containerId) internal view returns (address) {
        bytes32 key = _getUintKey("constants.nextAddr.", containerId);
        return getAddress(key);
    }

    function _activate(uint256 containerId) internal {
        bytes32 key = _getUintKey("constants.isActivated.", containerId);
        setBool(key, true);
    }

    function _deactivate(uint256 containerId) internal {
        bytes32 key = _getUintKey("constants.isActivated.", containerId);
        setBool(key, false);
    }

    function _isActivated(uint256 containerId) internal view returns (bool) {
        bytes32 key = _getUintKey("constants.isActivated.", containerId);
        return getBool(key);
    }

    function _setMaxNumOfContainers(uint256 nContainers) internal {
        bytes32 key = _getStringKey(
            "constants.settings.",
            "maxNumOfContainers"
        );
        setUint(key, nContainers);
    }

    function _getMaxNumOfContainers() internal view returns (uint256) {
        bytes32 key = _getStringKey(
            "constants.settings.",
            "maxNumOfContainers"
        );
        return getUint(key);
    }

    function _setMaxNumOfActiveContainers(uint256 nContainers) internal {
        bytes32 key = _getStringKey(
            "constants.settings.",
            "maxNumOfActiveContainers"
        );
        setUint(key, nContainers);
    }

    function _getMaxNumOfActiveContainers() internal view returns (uint256) {
        bytes32 key = _getStringKey(
            "constants.settings.",
            "maxNumOfActiveContainers"
        );
        return getUint(key);
    }

    function _setNumOfZombiesPerContainer(uint256 nZombies) internal {
        bytes32 key = _getStringKey(
            "constants.settings.",
            "numOfZombiesPerContainer"
        );
        setUint(key, nZombies);
    }

    function _getNumOfZombiesPerContainer() internal view returns (uint256) {
        bytes32 key = _getStringKey(
            "constants.settings.",
            "numOfZombiesPerContainer"
        );
        return getUint(key);
    }

    function _setOpeningThreshhold(uint256 nZombies) internal {
        bytes32 key = _getStringKey("constants.settings.", "openingThreshhold");
        setUint(key, nZombies);
    }

    function _getOpeningThreshhold() internal view returns (uint256) {
        bytes32 key = _getStringKey("constants.settings.", "openingThreshhold");
        return getUint(key);
    }

    /*
        internal functions
    */
    function setAddress(bytes32 key, address val) internal {
        IExternalStorage(externalStorageAddr).setAddress(key, val);
    }

    function setUint(bytes32 key, uint256 val) internal {
        IExternalStorage(externalStorageAddr).setUint(key, val);
    }

    function setString(bytes32 key, string memory val) internal {
        IExternalStorage(externalStorageAddr).setString(key, val);
    }

    function setBytes32(bytes32 key, bytes32 val) internal {
        IExternalStorage(externalStorageAddr).setBytes32(key, val);
    }

    function setBool(bytes32 key, bool val) internal {
        IExternalStorage(externalStorageAddr).setBool(key, val);
    }

    // 2. getters
    function getAddress(bytes32 key) internal view returns (address) {
        return IExternalStorage(externalStorageAddr).getAddress(key);
    }

    function getUint(bytes32 key) internal view returns (uint256) {
        return IExternalStorage(externalStorageAddr).getUint(key);
    }

    function getString(bytes32 key) internal view returns (string memory) {
        return IExternalStorage(externalStorageAddr).getString(key);
    }

    function getBytes32(bytes32 key) internal view returns (bytes32) {
        return IExternalStorage(externalStorageAddr).getBytes32(key);
    }

    function getBool(bytes32 key) internal view returns (bool) {
        return IExternalStorage(externalStorageAddr).getBool(key);
    }

    // 3. deleters
    function delAddress(bytes32 key) internal {
        IExternalStorage(externalStorageAddr).delAddress(key);
    }

    function delUint(bytes32 key) internal {
        IExternalStorage(externalStorageAddr).delUint(key);
    }

    function delString(bytes32 key) internal {
        IExternalStorage(externalStorageAddr).delString(key);
    }

    function delBytes32(bytes32 key) internal {
        IExternalStorage(externalStorageAddr).delBytes32(key);
    }

    function delBool(bytes32 key) internal {
        IExternalStorage(externalStorageAddr).delBool(key);
    }

    function _getUintKey(string memory str, uint256 val)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(str, val));
    }

    function _getAddressKey(string memory str, address addr)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(str, addr));
    }

    function _getStringKey(string memory str, string memory val)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(str, val));
    }

    function _getBytes32Key(string memory str, bytes32 val)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(str, val));
    }
}
