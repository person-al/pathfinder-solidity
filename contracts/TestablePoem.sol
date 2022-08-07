// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "./Poem.sol";

abstract contract TestablePoem is Poem {
    function initialize() public virtual;

    constructor(string memory name_, string memory symbol_) Poem(name_, symbol_) {}

    function getHistoricalInput() public view onlyOwner returns (uint256) {
        return _historicalInput;
    }

    function newHistoricalInput(
        uint256 currRandomNumber,
        uint256 from,
        uint256 to,
        uint256 difficulty,
        uint256 blockNumber
    ) public pure returns (uint256) {
        return _newHistoricalInput(currRandomNumber, from, to, difficulty, blockNumber);
    }

    function getLeftChild(uint8 index) public view returns (uint8) {
        return _getLeftChild(index);
    }

    function getRightChild(uint8 index) public view returns (uint8) {
        return _getRightChild(index);
    }

    function getJitterChild(uint8 index, uint8 sibIndex) public view returns (uint8) {
        return _getJitterChild(index, sibIndex);
    }

    function lastTransferedAt(address owner) public view onlyOwner returns (uint64) {
        return _getAux(owner);
    }

    function numOwners(uint256 tokenId) public view onlyOwner returns (uint24) {
        TokenOwnership memory info = _ownershipOf(tokenId);
        return info.extraData;
    }

    function opacityLevel(uint256 numBlocksHeld) public pure returns (uint8) {
        return _opacityLevel(numBlocksHeld);
    }

    function jitterLevel(uint24 _numOwners) public view returns (uint8) {
        return _jitterLevel(_numOwners);
    }

    function getCurrIndex(uint160 fromSeed) public view returns (uint8) {
        return _getCurrIndex(fromSeed);
    }
}
