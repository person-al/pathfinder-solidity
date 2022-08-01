// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PoemError();

contract Poem is ERC721A("Poem", "POEM"), Ownable {
    bytes32[26] private nodes;
    uint16 public constant TOTAL_NUM_BITS = 256;
    uint8 public constant MAX_NUM_SIBLINGS = 4;
    uint8 public constant MAX_LEN_VALUE = 26;
    uint8 public constant MAX_INDEX_VAL = 25;
    uint8 public constant MAX_NUM_NFTS = 7;
    uint8 public constant BITS_IN_BYTES = 8;
    uint256 private constant VALUE_FILTER = 0x000000ffffffffffffffffffffffffff;

    function indexIsValid(uint256 _index) private pure {
        require(_index > 0, "Use a positive, non-zero index for your nodes.");
        require(_index <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
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
        string calldata value,
        uint8 leftIndex,
        uint8 rightIndex,
        uint8[] calldata siblingIndices
    ) external onlyOwner {
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
            indexIsValid(sibling); // Doing this here so we don't have to for-loop twice.
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

    function getLeftChild(uint8 index) public view returns (uint8) {
        indexIsValid(index);
        return uint8(nodes[index][0]);
    }

    function getRightChild(uint8 index) public view returns (uint8) {
        indexIsValid(index);
        return uint8(nodes[index][1]);
    }

    function getValueBytes(uint8 index) public view returns (bytes32) {
        indexIsValid(index);
        return nodes[index] & bytes32(VALUE_FILTER);
    }

    function getSiblings(uint8 index) public view returns (uint8[] memory) {
        indexIsValid(index);
        uint8[] memory siblings = new uint8[](4);
        bytes32 node = nodes[index];
        for (uint8 i = 0; i < MAX_NUM_SIBLINGS; i++) {
            uint8 sib = uint8(node[2 + i]);
            // TODO: I would really prefer to make a dynamically sized array with only non-zero values.
            //       But I'm not sure how/if that's possible?
            siblings[i] = sib;
        }
        return siblings;
    }

    /**
     * @dev Burns `tokenId` and then sets poem value. See {ERC721A-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        _burn(tokenId, true);
        // TODO: add modifications to the poem structure
    }

    function throwError() external pure {
        revert PoemError();
    }
}
