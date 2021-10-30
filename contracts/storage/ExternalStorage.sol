// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../interfaces/IExternalStorage.sol";
import "./ExternalStorageBase.sol";

/// @author Simon Tian
/// @title The external storage contract.
contract ExternalStorage is ExternalStorageBase, IExternalStorage {

    mapping(bytes32 => address) private _toAddress;  // 1. address
    mapping(bytes32 => uint256) private _toUint;  // 2. uint256
    mapping(bytes32 => string) private _toString;  // 3. string
    mapping(bytes32 => bytes32) private _toBytes32;  // 4. bytes32
    mapping(bytes32 => bool) private _toBool;  // 5. bool

    // 1. bytes32 => address
    function setAddress(bytes32 key, address addr) public override onlyESAC {
        _toAddress[key] = addr;
    }

    function getAddress(bytes32 key)
        public
        view
        override
        onlyESAC
        returns (address)
    {
        return _toAddress[key];
    }

    function delAddress(bytes32 key) public override onlyESAC {
        delete _toAddress[key];
    }

    // 2. bytes32 => uint256
    function setUint(bytes32 key, uint256 val) public override onlyESAC {
        _toUint[key] = val;
    }

    function getUint(bytes32 key)
        public
        view
        override
        onlyESAC
        returns (uint256)
    {
        return _toUint[key];
    }

    function delUint(bytes32 key) public override onlyESAC {
        delete _toUint[key];
    }

    // 3. bytes32 => string
    function setString(bytes32 key, string memory val) public override onlyESAC {
        _toString[key] = val;
    }

    function getString(bytes32 key)
        public
        view
        override
        onlyESAC
        returns (string memory)
    {
        return _toString[key];
    }

    function delString(bytes32 key) public override onlyESAC {
        delete _toString[key];
    }

    // 4. bytes32 => bytes32
    function setBytes32(bytes32 key, bytes32 val) public override onlyESAC {
        _toBytes32[key] = val;
    }

    function getBytes32(bytes32 key)
        public
        view
        override
        onlyESAC
        returns (bytes32)
    {
        return _toBytes32[key];
    }

    function delBytes32(bytes32 key) public override onlyESAC {
        delete _toBytes32[key];
    }

    // 5. bytes32 => bool
    function setBool(bytes32 key, bool val) public override onlyESAC {
        _toBool[key] = val;
    }

    function getBool(bytes32 key)
        public
        view
        override
        onlyESAC
        returns (bool)
    {
        return _toBool[key];
    }

    function delBool(bytes32 key) public override onlyESAC {
        delete _toBool[key];
    }
}
