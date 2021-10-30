// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./MinimalBeaconProxy.sol";
import "../ContextB.sol";

contract ContainerProxy is MinimalBeaconProxy {
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
     constructor(address beacon, address externalStorageAccessAddr_)
        MinimalBeaconProxy(beacon)
    {
        assert(_EXTERNAL_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.proxy.externalStorage")) - 1));
        StorageSlot.getAddressSlot(_EXTERNAL_STORAGE_SLOT).value = externalStorageAccessAddr_;
    }
}
