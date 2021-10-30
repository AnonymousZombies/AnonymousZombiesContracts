// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContainerImplementationBase.sol";
import "../interfaces/IContainerProxyManager.sol";

import "hardhat/console.sol";

contract ContainerImplementation is ContainerImplementationBase, Ownable {

    constructor(address externalStorageAccessAddr_)
        ContextB(externalStorageAccessAddr_)
    {
        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("ContainerImplementation", address(this));
    }

    function buyZombies(uint256 nZombies) public payable {
        require(_isActivated(), "Container not activated or deactivated");
        require(nZombies == 1 || nZombies == 3 || nZombies == 5, "Only 1, 3, and 5 are allowed");

        uint256 unitPrice = 0.0001 ether;  // Hardcoded, not parameterized yet.
        require(msg.value == nZombies * unitPrice, "Not right");

        uint256 nAZ = _IESA().getNumOfZombiesPerContainer();
        uint256 nZombiesMinted = _getNumOfMintedZombies();
        address nextAddr = _getNextAddr();
        uint256 openingThreshhold = _IESA().getOpeningThreshhold();

        if (nZombies + nZombiesMinted < nAZ) {
            for (uint256 i = 0; i < nZombies; i++) {
                _mint();
                _increment();
            }
            
            if (!_hasNext() && !_isMaxed() && nZombies + nZombiesMinted >= openingThreshhold) {
                _openNext();
            }
        } else if (nZombiesMinted < nAZ && nZombiesMinted + nZombies >= nAZ) {
            uint256 nZombiesToMint = nAZ - nZombiesMinted;
            uint256 nZombiesToMintNext = nZombies - nZombiesToMint;

            for (uint256 i = 0; i < nZombiesToMint; i++) {
                _mint();
                _increment();
            }

            _mintLeader();

            if (_hasNext()) {
                uint256 nextContainerId = _IESA().getContainerIdByAddr(nextAddr);
                _ICPM().activate(nextContainerId, address(this));

                // if nZombiesToMintNext is 0, this for loop would not run.
                for (uint256 i = 0; i < nZombiesToMintNext; i++) {
                    _mint();
                    _ICCF().increment(nextAddr);
                }
            } else {
                uint256 refundAmount = nZombiesToMintNext * unitPrice;
                (bool success, ) = _msgSender().call{value: refundAmount}("");
                require(success, "Refund not successful");
            }

        } else if (nZombiesMinted == nAZ) {
            if (_hasNext()) {
                if (_ICCF().current(nextAddr) < 10) {
                    for (uint256 i = 0; i < nZombies; i++) {
                        _mint();
                        _ICCF().increment(nextAddr);
                    }
                } else {
                    uint256 refundAmount = nZombies * unitPrice;
                    (bool success, ) = _msgSender().call{value: refundAmount}("");
                    require(success, "Refund not successful");
                }
                _deactivate();
            } else {
                revert("No more containers available");
            }
        }
    }

    function ownerKill() public onlyOwner {
        _IESA().delContractAddr("ContainerImplementation");
        selfdestruct(payable(owner()));
    }
}
