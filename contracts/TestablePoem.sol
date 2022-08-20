// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "./Poem.sol";

contract TestablePoem is Poem("Poem", "POEM", 0) {
    uint16 public constant TOTAL_NUM_BITS = 256;
    uint8 public constant BITS_IN_BYTES = 8;
    uint8 public constant MAX_LEN_VALUE = 27;

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
        uint8[3] memory jitterIndices
    ) public onlyOwner {
        // 1. Most of the requires up-front
        require(_totalMinted() == 0, "Owner cannot modify graph after minting has begun");
        indexIsValid(index);
        require(leftIndex <= MAX_INDEX_VAL && rightIndex <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
        require(bytes(value).length <= MAX_LEN_VALUE, "Value can't be more than 26 characters/bytes");
        require(jitterIndices.length <= MAX_NUM_JITTERS, "Can't support more than 4 jitter kids.");

        // 2. Now pack the node with the final require checks
        // 2a. Start with jitter kids
        uint256 jitterKidsPacked = 0;
        for (uint256 i = 0; i < jitterIndices.length; i++) {
            uint256 sibling = jitterIndices[i];
            require(sibling != index, "A node cannot be its own sibling.");
            require(sibling <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
            // Now put the jitter kids one after the other
            jitterKidsPacked = jitterKidsPacked | (sibling << (BITS_IN_BYTES * i));
        }
        // move all the jitter kids over to make room for valInt
        jitterKidsPacked = jitterKidsPacked << (MAX_LEN_VALUE * BITS_IN_BYTES);

        // 2b. Now pack everyone together
        uint256 kidsPacked = (uint256(leftIndex) << (TOTAL_NUM_BITS - BITS_IN_BYTES)) |
            (uint256(rightIndex) << (TOTAL_NUM_BITS - 2 * BITS_IN_BYTES));
        uint256 packed = kidsPacked | jitterKidsPacked | bytesToUint(bytes(value));
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

    function getJitterKids(uint8 index) public view returns (uint8[3] memory) {
        return _getJitterKids(index);
    }

    function getLeftChild(uint8 index) public view returns (uint8) {
        return _getLeftChild(index);
    }

    function getValueBytes(uint8 index) public view returns (bytes32) {
        return _getValueBytes(index);
    }

    function getValueString(uint8 index) public view returns (string memory) {
        return bytes32ToString(getValueBytes(index));
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

    function initialize() public onlyOwner {
        packNode(1, "As he ", 2, 3, [0, 0, 0]);
        packNode(2, "reached ", 4, 5, [6, 0, 0]);
        packNode(3, "dropped ", 5, 6, [4, 0, 0]);
        packNode(4, "upwards ", 7, 8, [9, 10, 0]);
        packNode(5, "his hands ", 8, 9, [7, 10, 0]);
        packNode(6, "his eyes ", 9, 10, [7, 8, 0]);
        packNode(7, "joyously,", 11, 12, [13, 14, 15]);
        packNode(8, "to the clouds, ", 12, 13, [11, 14, 15]);
        packNode(9, "shyly, ", 13, 14, [11, 12, 15]);
        packNode(10, "towards his shoes, ", 14, 15, [11, 12, 13]);
        packNode(11, "the sun ", 0, 16, [17, 18, 19]);
        packNode(12, "the wind ", 16, 17, [18, 19, 0]);
        packNode(13, "the footsteps ", 17, 18, [16, 19, 0]);
        packNode(14, "thunderous laughter ", 18, 19, [16, 17, 0]);
        packNode(15, "twinkling feathers ", 19, 0, [16, 17, 18]);
        packNode(16, "boistered ", 0, 20, [21, 22, 0]);
        packNode(17, "assuaged ", 20, 21, [22, 0, 0]);
        packNode(18, "echoed in ", 21, 22, [20, 0, 0]);
        packNode(19, "brushed ", 22, 0, [20, 21, 0]);
        packNode(20, "his excitement. ", 0, 23, [24, 0, 0]);
        packNode(21, "his fears. ", 23, 24, [0, 0, 0]);
        packNode(22, "his ears. ", 24, 0, [23, 0, 0]);
        packNode(23, "His struggle ", 0, 25, [0, 0, 0]);
        packNode(24, "His adventure ", 25, 0, [0, 0, 0]);
        packNode(25, "was just beginning.", 0, 0, [0, 0, 0]);
    }
}
