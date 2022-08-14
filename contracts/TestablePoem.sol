// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "./Poem.sol";

contract TestablePoem is Poem("Poem", "POEM") {
    uint16 public constant TOTAL_NUM_BITS = 256;
    uint8 public constant BITS_IN_BYTES = 8;
    uint8 public constant MAX_LEN_VALUE = 26;

    /**
     * @dev Takes node information and adds it to the graph store
     *
     * Requirements:
     *      - only callable by contract owner
     *
     * TODOs:
     *      - consider removing this from the smart contract and
     *          prepopulating nodes above. Then nodes can be public constant.
     *      - or put it in the constructor so that I can test with different values?
     */
    function packNode(
        uint8 index,
        string memory value,
        uint8 leftIndex,
        uint8 rightIndex,
        uint8[4] memory siblingIndices
    ) public onlyOwner {
        // 1. Most of the requires up-front
        require(_totalMinted() == 0, "Owner cannot modify graph after minting has begun");
        indexIsValid(index);
        require(leftIndex <= MAX_INDEX_VAL && rightIndex <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
        require(bytes(value).length <= MAX_LEN_VALUE, "Value can't be more than 26 characters/bytes");
        require(siblingIndices.length <= MAX_NUM_SIBLINGS, "Can't support more than 4 siblings.");

        // 2. Now pack the node with the final require checks
        // 2a. Start with siblings
        uint256 siblingsPacked = 0;
        for (uint256 i = 0; i < siblingIndices.length; i++) {
            uint256 sibling = siblingIndices[i];
            require(sibling != index, "A node cannot be its own sibling.");
            require(sibling <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
            // Now put the siblings one after the other
            siblingsPacked = siblingsPacked | (sibling << (BITS_IN_BYTES * i));
        }
        // move all the siblings over to make room for valInt
        siblingsPacked = siblingsPacked << (MAX_LEN_VALUE * BITS_IN_BYTES);

        // 2b. Now pack everyone together
        uint256 kidsPacked = (uint256(leftIndex) << (TOTAL_NUM_BITS - BITS_IN_BYTES)) |
            (uint256(rightIndex) << (TOTAL_NUM_BITS - 2 * BITS_IN_BYTES));
        uint256 packed = kidsPacked | siblingsPacked | bytesToUint(bytes(value));
        nodes[index] = packed;
    }

    function bytesToUint(bytes memory b) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number = number + uint256(uint8(b[i])) * (2**(8 * (b.length - (i + 1))));
        }
        return number;
    }

    function getCurrentPathIndex() public view returns (uint8) {
        return path[currStep];
    }

    function getHistoricalInput() public view returns (uint256) {
        return _historicalInput;
    }

    function setHistoricalInput(uint256 newInput) public onlyOwner {
        _historicalInput = newInput;
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

    function getSiblings(uint8 index) public view returns (uint8[4] memory) {
        return _getSiblings(index);
    }

    function getLeftChild(uint8 index) public view returns (uint8) {
        return _getLeftChild(index);
    }

    function getValueBytes(uint8 index) public view returns (bytes32) {
        return _getValueBytes(index);
    }

    function getRightChild(uint8 index) public view returns (uint8) {
        return _getRightChild(index);
    }

    function getJitterChild(uint8 index, uint256 seed) public view returns (uint8) {
        return _getJitterChild(index, seed);
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

    function jitterLevel(uint24 _numOwners) public pure returns (uint8) {
        return _jitterLevel(_numOwners);
    }

    function getCurrIndex(uint160 fromSeed) public view returns (uint8) {
        return _getCurrIndex(fromSeed);
    }

    function getNodes() public view returns (uint256[26] memory) {
        return nodes;
    }

    function getPath() public view returns (uint8[9] memory) {
        return path;
    }
}
