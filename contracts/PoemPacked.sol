// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "./TestablePoem.sol";

contract PoemPacked is TestablePoem("Poem", "POEM") {
    bytes32[26] private nodes;
    uint16 public constant TOTAL_NUM_BITS = 256;
    uint8 public constant BITS_IN_BYTES = 8;
    uint256 private constant VALUE_FILTER = 0x000000ffffffffffffffffffffffffff;

    function initialize() public override onlyOwner {
        packNode(1, "As he ", 2, 3, [0, 0, 0, 0]);
        packNode(2, "reached ", 4, 5, [3, 0, 0, 0]);
        packNode(3, "dropped ", 5, 6, [2, 0, 0, 0]);
        packNode(4, "upwards ", 7, 8, [5, 6, 0, 0]);
        packNode(5, "his hands ", 8, 9, [4, 6, 0, 0]);
        packNode(6, "his eyes ", 9, 10, [4, 5, 0, 0]);
        packNode(7, "joyously,", 11, 12, [8, 9, 10, 0]);
        packNode(8, "to the clouds,", 12, 13, [7, 9, 10, 0]);
        packNode(9, "shyly,", 13, 14, [7, 8, 10, 0]);
        packNode(10, "towards his shoes,", 14, 15, [7, 8, 9, 0]);
        packNode(11, "the sun ", 0, 16, [12, 13, 14, 15]);
        packNode(12, "the wind ", 16, 17, [11, 13, 14, 15]);
        packNode(13, "the footsteps", 17, 18, [11, 12, 14, 15]);
        packNode(14, "thunderous laughter ", 18, 19, [11, 12, 13, 15]);
        packNode(15, "twinkling features ", 19, 0, [11, 12, 13, 14]);
        packNode(16, "boistered ", 0, 20, [17, 18, 19, 0]);
        packNode(17, "assuaged ", 20, 21, [16, 18, 19, 0]);
        packNode(18, "echoed in ", 21, 22, [16, 17, 19, 0]);
        packNode(19, "brushed ", 22, 0, [16, 17, 18, 0]);
        packNode(20, "his excitement. ", 0, 23, [21, 22, 0, 0]);
        packNode(21, "his fears. ", 23, 24, [20, 22, 0, 0]);
        packNode(22, "his ears. ", 24, 0, [20, 21, 0, 0]);
        packNode(23, "His struggle ", 0, 25, [24, 0, 0, 0]);
        packNode(24, "His adventure ", 25, 0, [23, 0, 0, 0]);
        packNode(25, "was just beginning.", 0, 0, [0, 0, 0, 0]);
    }

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
        bytes32 packed = bytes32(abi.encodePacked(kidsPacked | siblingsPacked | bytesToUint(bytes(value))));
        nodes[index] = packed;
    }

    function bytesToUint(bytes memory b) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number = number + uint256(uint8(b[i])) * (2**(8 * (b.length - (i + 1))));
        }
        return number;
    }

    function _getLeftChild(uint8 index) internal view override returns (uint8) {
        indexIsValid(index);
        return uint8(nodes[index][0]);
    }

    function _getRightChild(uint8 index) internal view override returns (uint8) {
        indexIsValid(index);
        return uint8(nodes[index][1]);
    }

    function _getValueBytes(uint8 index) internal view override returns (bytes32) {
        indexIsValid(index);
        return nodes[index] & bytes32(VALUE_FILTER);
    }

    function _getSiblings(uint8 index) internal view override returns (uint8[4] memory) {
        indexIsValid(index);
        uint8[4] memory siblings;
        bytes32 node = nodes[index];
        for (uint8 i = 0; i < MAX_NUM_SIBLINGS; i++) {
            uint8 sib = uint8(node[2 + i]);
            // TODO: I would really prefer to make a dynamically sized array with only non-zero values.
            //       But I'm not sure how/if that's possible?
            siblings[i] = sib;
        }
        return siblings;
    }
}
