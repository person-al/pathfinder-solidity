// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "./TestablePoem.sol";

contract PoemStructs is TestablePoem("PoemStructs", "STPOEM") {
    struct Node {
        uint8 leftChild;
        uint8 rightChild;
        bytes26 value;
        uint8[4] siblings;
    }
    Node[26] private nodesList;

    function initialize() public override onlyOwner {
        storeNode(1, "As he ", 2, 3, [0, 0, 0, 0]);
        storeNode(2, "reached ", 4, 5, [3, 0, 0, 0]);
        storeNode(3, "dropped ", 5, 6, [2, 0, 0, 0]);
        storeNode(4, "upwards ", 7, 8, [5, 6, 0, 0]);
        storeNode(5, "his hands ", 8, 9, [4, 6, 0, 0]);
        storeNode(6, "his eyes ", 9, 10, [4, 5, 0, 0]);
        storeNode(7, "joyously,", 11, 12, [8, 9, 10, 0]);
        storeNode(8, "to the clouds,", 12, 13, [7, 9, 10, 0]);
        storeNode(9, "shyly,", 13, 14, [7, 8, 10, 0]);
        storeNode(10, "towards his shoes,", 14, 15, [7, 8, 9, 0]);
        storeNode(11, "the sun ", 0, 16, [12, 13, 14, 15]);
        storeNode(12, "the wind ", 16, 17, [11, 13, 14, 15]);
        storeNode(13, "the footsteps", 17, 18, [11, 12, 14, 15]);
        storeNode(14, "thunderous laughter ", 18, 19, [11, 12, 13, 15]);
        storeNode(15, "twinkling features ", 19, 0, [11, 12, 13, 14]);
        storeNode(16, "boistered ", 0, 20, [17, 18, 19, 0]);
        storeNode(17, "assuaged ", 20, 21, [16, 18, 19, 0]);
        storeNode(18, "echoed in ", 21, 22, [16, 17, 19, 0]);
        storeNode(19, "brushed ", 22, 0, [16, 17, 18, 0]);
        storeNode(20, "his excitement. ", 0, 23, [21, 22, 0, 0]);
        storeNode(21, "his fears. ", 23, 24, [20, 22, 0, 0]);
        storeNode(22, "his ears. ", 24, 0, [20, 21, 0, 0]);
        storeNode(23, "His struggle ", 0, 25, [24, 0, 0, 0]);
        storeNode(24, "His adventure ", 25, 0, [23, 0, 0, 0]);
        storeNode(25, "was just beginning.", 0, 0, [0, 0, 0, 0]);
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
    function storeNode(
        uint8 index,
        string memory value,
        uint8 leftIndex,
        uint8 rightIndex,
        uint8[4] memory siblingIndices
    ) public onlyOwner {
        // All the requires
        require(_totalMinted() == 0, "Owner cannot modify graph after minting has begun");
        require(nodesList.length <= MAX_INDEX_VAL + 1, "Cannot support more than 25 nodes.");
        indexIsValid(index);
        require(leftIndex <= MAX_INDEX_VAL && rightIndex <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
        require(bytes(value).length <= MAX_LEN_VALUE, "Value can't be more than 26 characters/bytes");
        require(siblingIndices.length <= MAX_NUM_SIBLINGS, "Can't support more than 4 siblings.");
        // TODO: feedback from CryptoDevs: I can store siblings in a uint8[2] instead of a general list
        uint8[4] memory siblings;
        for (uint256 i = 0; i < siblingIndices.length; i++) {
            uint8 sibIndex = siblingIndices[i];
            require(sibIndex <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
            require(sibIndex != index, "A node cannot be its own sibling.");
            siblings[i] = sibIndex;
        }

        // Now store it
        nodesList[index] = Node(leftIndex, rightIndex, bytes26(bytes(value)), siblings);
    }

    function getNode(uint8 index) public view returns (Node memory) {
        indexIsValid(index);
        return nodesList[index];
    }

    function _getLeftChild(uint8 index) internal view override returns (uint8) {
        return getNode(index).leftChild;
    }

    function _getRightChild(uint8 index) internal view override returns (uint8) {
        return getNode(index).rightChild;
    }

    function _getSiblings(uint8 index) internal view override returns (uint8[4] memory) {
        return getNode(index).siblings;
    }

    function _getValueBytes(uint8 index) internal view override returns (bytes32) {
        return getNode(index).value;
    }
}
