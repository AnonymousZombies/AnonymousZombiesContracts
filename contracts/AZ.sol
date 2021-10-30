// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./ContextB.sol";
import "hardhat/console.sol";

contract AZ is ContextB, ERC721Pausable, Ownable {
    event MintLeader(address account, uint256 containerId);
    event ChangeName(uint256 tokenId, string newName);
    event Remint(uint256 oldZombieId, uint256 newZombieId, address account);
    event ZombieEnded();

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;

    uint256 public startingIndex;
    uint256 public startingBlockIndex;

    Counters.Counter private _zombieId;
    Counters.Counter private _leaderId;

    mapping(address => uint256) private _leaderBalance;

    uint256 private constant totalAZSupply = 10000; // 10000
    uint256 private constant maxZombiesSupply = 9600;
    uint256 private constant maxLeaderSupply = 400; // 400

    // Store the address which can remint
    mapping(address => bool) private _canRemintAddress;
    uint256 private _remintMappingLength;

    uint256 private _remintStartingTime;

    uint256 private _remintEndingTime;

    string private _zombieBaseURI;
    string private _leaderBaseURI;

    constructor(address externalStorageAccessAddr_)
        ContextB(externalStorageAccessAddr_)
        ERC721("Anonymous Zombies", "AZ")
    {
        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("Zombies", address(this));
        _zombieIdIncrement();
        _leaderIdIncrement();
    }

    function remint(uint256 zombieId, uint256 newZombieId) public {
        require(
            _getZombieId() - 1 <= maxZombiesSupply,
            "Exceeding the limit"
        );
        require(startingIndex != 0, "StartingIndex not set");
        require(!_exists(newZombieId), "Zombie was minted");
        require(ownerOf(zombieId) == _msgSender(), "Zombie is not yours");
        require(!_isLeader(zombieId), "Leader zombie not remint");

        if (block.timestamp > _remintEndingTime) {
            _burn(zombieId);
            _mint(_msgSender(), newZombieId);
        } else {
            if (_canRemintAddress[_msgSender()]) {
                _burn(zombieId);
                _mint(_msgSender(), newZombieId);
            } else {
                revert("You can't remint now");
            }
        }

        emit Remint(zombieId, newZombieId, _msgSender());
    }

    function mint(address to) public {
        require(
            _msgSender() == _getContractAddr("ContainerProxyManager") ||
                _msgSender() == _getContractAddr("Presale") ||
                _msgSender() == owner(),
            "Not allowed"
        );

        uint256 zombieId = _getZombieId();
        require(zombieId <= maxZombiesSupply, "Exceeding the limit");
        _mint(to, zombieId);

        if (_canRemintAddress[to] == false && _remintMappingLength < 1) {
            _canRemintAddress[to] = true;
            _remintMappingLength++;
        }
        _zombieIdIncrement();
    }

    function mintLeader(address to, uint256 containerId)
        public
        onlyByContract("ContainerProxyManager")
    {
        require(_getLeaderId() <= maxLeaderSupply, "Exceeding the limit");

        uint256 leaderId_ = maxZombiesSupply + _getLeaderId();
        _mint(to, leaderId_);
        _leaderIdIncrement();

        emit MintLeader(to, containerId);
    }

    function setBaseURI(string memory zombieURI, string memory leaderURI)
        public
        onlyOwner
    {
        _zombieBaseURI = zombieURI;
        _leaderBaseURI = leaderURI;
    }

    function isLeaderMinted(uint256 tokenId) public view returns (bool) {
        uint256 maxZombiesSupply = zombiesTotalSupply();
        uint256 maxLeaderId = maxZombiesSupply + _getLeaderId();
        return tokenId > maxZombiesSupply && tokenId < maxLeaderId;
    }

    function setZombieIsEnded() public {
        _finalizeStartingIndex();
        emit ZombieEnded();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _getCID(tokenId);
    }

    function isLeader(uint256 zombieId) public pure returns (bool) {
        return _isLeader(zombieId);
    }

    function totalSupply() public pure returns (uint256) {
        return totalAZSupply;
    }

    function zombiesTotalSupply() public pure returns (uint256) {
        return maxZombiesSupply;
    }

    function leadersTotalSupply() public pure returns (uint256) {
        return maxLeaderSupply;
    }

    function setPaused() public onlyOwner {
        _pause();
    }

    function balanceOfLeaders(address account) external view returns (uint256) {
        return _leaderBalance[account];
    }

    function _isLeader(uint256 zombieId) internal pure returns (bool) {
        return
            zombieId > maxZombiesSupply &&
            zombieId <= maxZombiesSupply + maxLeaderSupply;
    }

    function _getZombieId() internal view returns (uint256) {
        return _zombieId.current();
    }

    function _getLeaderId() internal view returns (uint256) {
        return _leaderId.current();
    }

    function _zombieIdIncrement() private {
        _zombieId.increment();
    }

    function _leaderIdIncrement() private {
        _leaderId.increment();
    }

    function _getCID(uint256 zombieId)
        private
        view
        returns (string memory ipfsHash)
    {
        require(zombieId <= totalAZSupply, "Zombie ID must less than 10000");
        require(startingIndex != 0, "Not set startingIndex");

        uint256 correspondingOriginalSequenceIndex;

        if (isLeader(zombieId)) {
            require(bytes(_leaderBaseURI).length > 0, "Not set _leaderBaseURI");
            correspondingOriginalSequenceIndex =
                (zombieId + startingIndex) %
                maxLeaderSupply;
            ipfsHash = string(
                abi.encodePacked(
                    _leaderBaseURI,
                    correspondingOriginalSequenceIndex.toString(),
                    ".png"
                )
            );
        } else {
            require(bytes(_zombieBaseURI).length > 0, "Not set _zombieBaseURI");
            correspondingOriginalSequenceIndex =
                (zombieId + startingIndex) %
                maxZombiesSupply;
            
            ipfsHash = string(
                abi.encodePacked(
                    _zombieBaseURI,
                    correspondingOriginalSequenceIndex.toString(),
                    ".png"
                )
            );
        }
    }

    /**
     * @dev Finalize starting index
     */
    function _finalizeStartingIndex() private {
        require(startingIndex == 0, "Starting index is already set");

        _remintStartingTime = block.timestamp;
        _remintEndingTime = _remintStartingTime + 5;

        startingBlockIndex = block.number;
        startingIndex = uint256(blockhash(startingBlockIndex - 1)) % totalAZSupply;

        if (startingIndex == 0) startingIndex++;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (_isLeader(tokenId)) {
            if (from == address(0x00)) {
                _leaderBalance[to] += 1;
            } else if (to == address(0x00)) {
                _leaderBalance[to] -= 1;
            } else {
                _leaderBalance[to] += 1;
                _leaderBalance[from] -= 1;
            }

        }
    }
}
