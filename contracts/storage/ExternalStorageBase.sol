// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @author Simon Tian
/// @title The external storage base contract.
abstract contract ExternalStorageBase is Initializable, Ownable {

    mapping(address => bool) private _contractPermission;

    bool private _inAccessible;

    /**
     * @dev Sets contract `contractAddr_` allowed to visit external storage.
     */
    function setExternalStoragePermission(address contractAddr_)
        public
        onlyOwner
    {
        _contractPermission[contractAddr_] = true;
    }

    /**
     * @dev Sets `controller` to true to turn off access.
     */
    function turnOffAccess()
        public
        initializer
        onlyOwner
    {
        _inAccessible = true;
    }

    /**
     * @dev Modifier that checks if _msgSender() is allowed to visit external
     * storage. Only external storage allowed contracts(ESAC).
     */
    modifier onlyESAC {
        require(_contractPermission[_msgSender()] || !_inAccessible);
        _;
    }
}
