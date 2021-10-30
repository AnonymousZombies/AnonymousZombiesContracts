// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract ContainerBeacon is UpgradeableBeacon {
    constructor(address implementation_)
        UpgradeableBeacon(implementation_) {}
}
