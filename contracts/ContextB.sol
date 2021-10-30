// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./interfaces/IExternalStorageAccess.sol";

import "hardhat/console.sol";

/// @author Simon Tian
/// @title An abstract context base contract
abstract contract ContextB is Context {
    /**
     * @dev The storage slot of the ExternalStorageAccess contract which defines
     * the storage for this contract.
     * This is bytes32(uint256(keccak256('eip1967.proxy.externalStorage')) - 1))
     * and is validated in the constructor.
     */
    bytes32 private constant _EXTERNAL_STORAGE_SLOT = 0x5d7876868c9e78cee439e4eef1204b475795cf4ef8060f1ee3848da0b5885cb9;

    /**
     * @dev Sets the address of external storage access contract
     * `externalStorageAccessAddr_` at slot `_EXTERNAL_STORAGE_SLOT`.
     */
    constructor(address externalStorageAccessAddr_) {
        assert(_EXTERNAL_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.proxy.externalStorage")) - 1));
        StorageSlot.getAddressSlot(_EXTERNAL_STORAGE_SLOT).value = externalStorageAccessAddr_;
    }

    /**
     * @dev Modifier that checks if called by `contractName`
     */
    modifier onlyByContract(string memory contractName) {
        require(_msgSender() == _getContractAddr(contractName), "Only by contract");
        _;
    }

    /**
     * @dev Modifier that checks if called by contracts `contractName1`
     * and `contractName2`.
     */
    modifier onlyByContracts(string memory contractName1, string memory contractName2) {
        require(
            _msgSender() == _getContractAddr(contractName1) ||
            _msgSender() == _getContractAddr(contractName2),
            "Only by contracts"
        );
        _;
    }

    /**
     * @dev Returns the address of external storage access contract at slot
     * _EXTERNAL_STORAGE_SLOT.
     */
    function _getExternalStorageAccessAddr() internal view returns (address) {
        return StorageSlot.getAddressSlot(_EXTERNAL_STORAGE_SLOT).value;
    }

    /**
     * @dev Returns the instantiated interface `IExternalStorageAccess`.
     */
    function _IESA() internal view returns (IExternalStorageAccess) {
        return IExternalStorageAccess(_getExternalStorageAccessAddr());
    }

    /**
     * @dev Returns the contract address given contract name `contractName_`.
     */
    function _getContractAddr(string memory contractName_) internal view returns (address) {
        return _IESA().getContractAddr(contractName_);
    }
}
