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

    function indexIsValid(uint256 _index) private pure {
        require(_index > 0, "Use a positive, non-zero index for your nodes.");
        require(_index <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
    }

    function initialize() public override onlyOwner {
        storeNode(1, "As he ", 2, 3, [0, 0, 0, 0]);
        storeNode(2, "reached ", 2, 3, [3, 0, 0, 0]);
        storeNode(3, "dropped ", 2, 3, [2, 0, 0, 0]);
        storeNode(4, "upwards ", 2, 3, [5, 6, 0, 0]);
        storeNode(5, "his hands ", 2, 3, [4, 6, 0, 0]);
        storeNode(6, "his eyes ", 2, 3, [4, 5, 0, 0]);
        storeNode(7, "joyously,", 2, 3, [8, 9, 10, 0]);
        storeNode(8, "to the clouds,", 2, 3, [7, 9, 10, 0]);
        storeNode(9, "shyly,", 2, 3, [7, 8, 10, 0]);
        storeNode(10, "towards his shoes,", 2, 3, [7, 8, 9, 0]);
        storeNode(11, "the sun ", 2, 3, [12, 13, 14, 15]);
        storeNode(12, "the wind ", 2, 3, [11, 13, 14, 15]);
        storeNode(13, "the footsteps", 2, 3, [11, 12, 14, 15]);
        storeNode(14, "thunderous laughter ", 2, 3, [11, 12, 13, 15]);
        storeNode(15, "twinkling features ", 2, 3, [11, 12, 13, 14]);
        storeNode(16, "boistered ", 2, 3, [17, 18, 19, 0]);
        storeNode(17, "assuaged ", 2, 3, [16, 18, 19, 0]);
        storeNode(18, "echoed in ", 2, 3, [16, 17, 19, 0]);
        storeNode(19, "brushed ", 2, 3, [16, 17, 18, 0]);
        storeNode(20, "his excitement. ", 2, 3, [21, 22, 0, 0]);
        storeNode(21, "his fears. ", 2, 3, [20, 22, 0, 0]);
        storeNode(22, "his ears. ", 2, 3, [20, 21, 0, 0]);
        storeNode(23, "His struggle ", 2, 3, [24, 0, 0, 0]);
        storeNode(24, "His adventure ", 2, 3, [23, 0, 0, 0]);
        storeNode(25, "was just beginning.", 2, 3, [0, 0, 0, 0]);
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
        require(bytes(value).length <= MAX_LEN_VALUE, "Value can't be more than 28 characters/bytes");
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

    function _getJitterChild(uint8 index, uint8 sibIndex) internal view override returns (uint8) {
        return getNode(index).siblings[sibIndex];
    }
}
