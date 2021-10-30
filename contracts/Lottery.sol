// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

interface IAZ {
    function zombiesTotalSupply() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function leadersTotalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function balanceOfLeaders(address account) external view returns (uint256);
}

contract Lottery is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet goldPrizeTokenIds;
    EnumerableSet.UintSet silverPrizeTokenIds;
    EnumerableSet.UintSet bronzePrizeTokenIds;
    uint256 public diamondPrizeTokenId;

    uint256 public constant numOfDiamondPrizeWinners = 1;
    uint256 public constant numOfGoldPrizeWinners = 4;
    uint256 public constant numOfSilverPrizeWinners = 40;
    uint256 public constant numOfBronzePrizeWinners = 400;

    uint256 public numOfRemainingDiamondPrizeWinners;
    uint256 public numOfRemainingGoldPrizeWinners;
    uint256 public numOfRemainingSilverPrizeWinners;
    uint256 public numOfRemainingBronzePrizeWinners;

    address[numOfGoldPrizeWinners] public goldPrizeWinners;
    address[numOfSilverPrizeWinners] public silverPrizeWinners;

    bytes32 public diamondPrizeWinnersProof;
    bytes32 public goldPrizeWinnersProof;
    bytes32 public silverPrizeWinnersProof;
    bytes32 public bronzePrizeWinnersProof;

    bool public diamondPrizeWinnerVerified;
    bool public goldPrizeWinnersVerified;
    bool public silverPrizeWinnersVerified;
    bool public bronzePrizeWinnersVerified;

    uint256 public constant diamondPrizeAmount = 400 ether;
    uint256 public constant goldPrizeAmount = 100 ether;
    uint256 public constant silverPrizeAmount = 10 ether;
    uint256 public constant bronzePrizeAmount = 1 ether;

    address private _azAddr;

    // status: 0: no prize 1: have prize 2: already withdraw
    mapping(uint256 => uint256) public tokenPrizeStatus;

    uint256 public revealPrizeTime;
    uint256 public month = 30 * 24 * 60 * 60 * 1;

    constructor(address azAddr_) {
        _azAddr = azAddr_;
        numOfRemainingDiamondPrizeWinners = numOfDiamondPrizeWinners;
        numOfRemainingGoldPrizeWinners = numOfGoldPrizeWinners;
        numOfRemainingSilverPrizeWinners = numOfSilverPrizeWinners;
        numOfRemainingBronzePrizeWinners = numOfBronzePrizeWinners;
    }

    /*
     * @dev The winners must be input in the same order with the tokenIds.
     */
    function setGoldPrizeWinners(uint256[] memory tokenIds) public onlyOwner {
        uint256 n = tokenIds.length;
        require(n == numOfGoldPrizeWinners, "Wrong length");

        address winner;
        for (uint256 i = 0; i < n; i++) {
            winner = IAZ(_azAddr).ownerOf(tokenIds[i]);
            goldPrizeWinners[i] = winner;
            goldPrizeTokenIds.add(tokenIds[i]);
            tokenPrizeStatus[tokenIds[i]] = 1;
        }
    }

    function setSilverPrizeWinners(uint256[] memory tokenIds) public onlyOwner {
        uint256 n = tokenIds.length;
        require(n == 7, "Wrong length");

        address winner;
        for (uint256 i = 0; i < n; i++) {
            require(tokenIds[i] < 9600, "Zombie leaders are not silver prizes");
            winner = IAZ(_azAddr).ownerOf(tokenIds[i]);
            silverPrizeWinners[i] = winner;
            silverPrizeTokenIds.add(tokenIds[i]);
            tokenPrizeStatus[tokenIds[i]] = 1;
        }

        revealPrizeTime = block.timestamp;
    }

    function verifyGoldPrizeWinners() public onlyOwner {
        bytes32 proof = _hash(goldPrizeWinners[0]);
        for (uint256 i = 1; i < numOfGoldPrizeWinners; i++) {
            proof = _updateHash(proof, goldPrizeWinners[i]);
        }

        if (goldPrizeWinnersProof == proof) {
            goldPrizeWinnersVerified = true;
        }
    }

    function checkGoldPrizeWinner(address addr) public view returns (bool) {
        for (uint256 i = 0; i < numOfGoldPrizeWinners; i++) {
            if (addr ==  goldPrizeWinners[i]) {
                return true;
            }
        }
        return false;
    }

    function verifySilverPrizeWinners() public onlyOwner {
        bytes32 proof = _hash(silverPrizeWinners[0]);
        proof = _updateHash(proof, silverPrizeWinners[0]);
        for (uint256 i = 1; i < numOfSilverPrizeWinners; i++) {
            proof = _updateHash(proof, silverPrizeWinners[i]);
        }

        if (silverPrizeWinnersProof == proof) {
            silverPrizeWinnersVerified = true;
        }

        
    }

    function checkSilverPrizeWinner(address addr) public view returns (bool) {
        for (uint256 i = 0; i < numOfSilverPrizeWinners; i++) {
            if (addr == silverPrizeWinners[i]) {
                return true;
            }
        }
        return false;
    }

    function checkBronzePrizeWinner(address addr) public view returns (bool) {
        return IAZ(_azAddr).balanceOfLeaders(addr) > 0;
    }

    function setGoldPrizeWinnersProof(bytes32 proof) public onlyOwner {
        goldPrizeWinnersProof = proof;
    }

    function setSilverPrizeWinnersProof(bytes32 proof) public onlyOwner {
        silverPrizeWinnersProof = proof;
    }

    function setDiamondPrizeTokenId(uint256 tokenId) public onlyOwner {
        diamondPrizeTokenId = tokenId;
    }

    function claimDiamondPrize(uint256 tokenId) public {
        require(diamondPrizeTokenId == tokenId, "Not the winning token");
        require(IAZ(_azAddr).ownerOf(tokenId) == _msgSender(), "Not token holder");
        require(tokenPrizeStatus[tokenId] == 1, "Not qualified to claim");

        (bool success, ) = _msgSender().call{value: diamondPrizeAmount}("");
        require(success, "Not successful");
        tokenPrizeStatus[tokenId] = 2;
    }

    //
    function claimGoldPrize(uint256 tokenId) public {
        require(goldPrizeWinnersVerified, "Gold prize winners unverified");
        require(IAZ(_azAddr).ownerOf(tokenId) == _msgSender(), "Not token holder");
        require(goldPrizeTokenIds.contains(tokenId), "Not the winning token");
        require(tokenPrizeStatus[tokenId] == 1, "Not qualified to claim");

        (bool success, ) = _msgSender().call{value: goldPrizeAmount}("");
        require(success, "Not successful");
        numOfRemainingGoldPrizeWinners -= 1;
        tokenPrizeStatus[tokenId] = 2;
    }

    function claimSilverPrize(uint256 tokenId) public {
        require(silverPrizeWinnersVerified, "Silver prize winners unverified");
        require(IAZ(_azAddr).ownerOf(tokenId) == _msgSender(), "Not token holder");
        require(silverPrizeTokenIds.contains(tokenId), "Not a Silver prize winner");
        require(tokenPrizeStatus[tokenId] == 1, "Not qualified to claim");
        (bool success, ) = _msgSender().call{value: silverPrizeAmount}("");
        require(success, "Not successful");
        numOfRemainingSilverPrizeWinners -= 1;
        tokenPrizeStatus[tokenId] = 2;
    }

    function claimBronzePrize(uint256 tokenId) public {
        require(IAZ(_azAddr).ownerOf(tokenId) == _msgSender(), "Not token holder");
        require(tokenId >= 9600, "Not zombie leaders");
        require(tokenPrizeStatus[tokenId] == 1, "Not qualified to claim");

        (bool success, ) = _msgSender().call{value: bronzePrizeAmount}("");
        require(success, "Not successful");
        numOfRemainingBronzePrizeWinners -= 1;
        tokenPrizeStatus[tokenId] = 2;
    }

    function hash(address addr) public pure returns (bytes32) {
        return _hash(addr);
    }

    function _hash(address addr) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(addr));
    }

    function updateHash(bytes32 hashedValue, address addr) public pure returns (bytes32) {
        return _updateHash(hashedValue, addr);
    }

    function _updateHash(bytes32 hashedValue, address addr) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(hashedValue, addr));
    }

    function getPoolSize() public view returns (uint256) {
        return address(this).balance;
    }

    function getBronzePrizeWinnersTokenId() public view returns (uint256[numOfBronzePrizeWinners] memory)  {
        require(address(_azAddr) != address(0x00), "_azAddr not zero address");
        uint256[numOfBronzePrizeWinners] memory thirdPrize;
        uint256 leaderIdStartIndex = IAZ(_azAddr).zombiesTotalSupply();
        uint256 leadersTotalSupply = IAZ(_azAddr).leadersTotalSupply();

        for (uint256 i = 1; i <= leadersTotalSupply; i++) {
            uint256 tokenId = leaderIdStartIndex + i;
            thirdPrize[i - 1] = tokenId;
        }

        return thirdPrize;
    }

    function getSilverPrizeWinnersTokenId(uint256 ethPrice) public returns (uint256[numOfSilverPrizeWinners] memory) {
        uint256[numOfSilverPrizeWinners] memory secondPrize;
        uint256 getSecondPrizeAmount = 0;
        uint256 totalZombiesAmount = IAZ(_azAddr).zombiesTotalSupply();
        bytes32 hashB = bytes32(ethPrice);
        uint256 i = 0;
        while (true) {
            hashB = keccak256(abi.encode(hashB));
            uint256 tokenId = (_bytesToUint(hashB) % totalZombiesAmount);
            
            if (tokenPrizeStatus[tokenId] != 0 && tokenId != 0) {
                secondPrize[i] = tokenId;
                getSecondPrizeAmount++;
            } else {
                continue;
            }

            if (getSecondPrizeAmount >= numOfSilverPrizeWinners) break;
            i++;
        }

        return secondPrize;
    }

    function getGoldPrizeWinnersTokenId(uint256 btcPrice) public returns (uint256[numOfGoldPrizeWinners] memory) {
        uint256[numOfGoldPrizeWinners] memory firstPrize;
        uint256 getFirstPrizeAmount = 0;
        uint256 totalSupply = IAZ(_azAddr).totalSupply();
        bytes32 hashB = keccak256(abi.encode(btcPrice));
        uint256 i = 0;
        while (true) {
            hashB = keccak256(abi.encode(hashB));
            uint256 tokenId = (_bytesToUint(hashB) % totalSupply);
            if (tokenPrizeStatus[tokenId] != 0 && tokenId != 0) {
                firstPrize[i] = tokenId;
                getFirstPrizeAmount++;
            } else {
                continue;
            }

            if (getFirstPrizeAmount >= numOfGoldPrizeWinners) break;
            i++;
        }

        return firstPrize;
    }

    function getDiamondPrizeWinnerTokenId() public returns (uint256) {
        bytes memory allLeaderAddress;
        uint256 specialPrize;
        uint256 totalZombiesAmount = IAZ(_azAddr).zombiesTotalSupply();
        uint256 totalSupply = IAZ(_azAddr).totalSupply();

        for (uint256 i = 1; i <= numOfBronzePrizeWinners; i++) {
            uint256 tokenId = totalZombiesAmount + i;
            address tokenOwner = IAZ(_azAddr).ownerOf(tokenId);
            allLeaderAddress = abi.encodePacked(allLeaderAddress, tokenOwner);
        }

        while (true) {
            bytes32 hashB = keccak256(allLeaderAddress);
            uint256 diamondPrizeTokenId = (_bytesToUint(hashB) % totalSupply);
            
            if (tokenPrizeStatus[diamondPrizeTokenId] != 0 && diamondPrizeTokenId != 0) {
                specialPrize = diamondPrizeTokenId;
                break;
            } else {
                allLeaderAddress = abi.encodePacked(allLeaderAddress, hashB);
                continue;
            }
        }

        return specialPrize;
    }

    function withDrawByOwner() public onlyOwner {
        require(revealPrizeTime + month <= block.timestamp, "Can't withdraw");
        (bool success, ) = _msgSender().call{value: address(this).balance}("");
        require(success, "withdraw failed");
    }

    function _bytesToUint(bytes32 b) private returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number = number + uint8(b[i]) * (2**(8 * (b.length - (i + 1))));
        }
        return number;
    }
    
    receive() external payable { }
}
