// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PoemStructsError();

contract PoemStructs is ERC721A("PoemStruct", "STPOEM"), Ownable {
    struct Node {
        uint8 leftChild;
        uint8 rightChild;
        bytes26 value;
        uint8[4] siblings;
    }
    Node[26] private nodesList;
    uint8 public constant MAX_NUM_SIBLINGS = 4;
    uint8 public constant MAX_LEN_VALUE = 28;
    uint8 public constant MAX_INDEX_VAL = 25;
    uint8 public constant MAX_NUM_NFTS = 7;

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
    function storeNode(
        uint8 index,
        string calldata value,
        uint8 leftIndex,
        uint8 rightIndex,
        uint8[] calldata siblingIndices
    ) external onlyOwner {
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
            indexIsValid(sibIndex);
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
        revert PoemStructsError();
    }
}
