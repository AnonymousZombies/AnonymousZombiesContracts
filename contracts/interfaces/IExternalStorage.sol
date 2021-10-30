// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IExternalStorage {
    function setAddress(bytes32 key, address addr) external;
    function setUint(bytes32 key, uint256 val) external;
    function setString(bytes32 key, string memory val) external;
    function setBytes32(bytes32 key, bytes32 val) external;
    function setBool(bytes32 key, bool val) external;

    function getAddress(bytes32 key) external view returns (address);
    function getUint(bytes32 key) external view returns (uint256);
    function getString(bytes32 key) external view returns (string memory);
    function getBytes32(bytes32 key) external view returns (bytes32);
    function getBool(bytes32 key) external view returns (bool);

    function delAddress(bytes32 key) external;
    function delUint(bytes32 key) external;
    function delString(bytes32 key) external;
    function delBytes32(bytes32 key) external;
    function delBool(bytes32 key) external;
}
