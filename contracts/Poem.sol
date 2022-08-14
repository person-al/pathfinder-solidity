// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Poem is ERC721A, Ownable {
    uint8 public constant MAX_NUM_SIBLINGS = 4;
    uint8 public constant MAX_INDEX_VAL = 25;
    uint8 public constant MAX_NUM_NFTS = 7;
    uint256 private constant VALUE_FILTER = 0x000000ffffffffffffffffffffffffff;

    uint8[9] public path = [1, 0, 0, 0, 0, 0, 0, 0, 25];
    uint8 public currStep = 0;
    uint256 internal _historicalInput = 1;
    uint256[26] internal nodes = [
        0x0000000000000000000000000000000000000000000000000000000000000000,
        0x0203000000000000000000000000000000000000000000000000417320686520,
        0x0405000000030000000000000000000000000000000000007265616368656420,
        0x05060000000200000000000000000000000000000000000064726f7070656420,
        0x0708000006050000000000000000000000000000000000007570776172647320,
        0x080900000604000000000000000000000000000000006869732068616e647320,
        0x090a000005040000000000000000000000000000000000686973206579657320,
        0x0b0c000a090800000000000000000000000000000000006a6f796f75736c792c,
        0x0c0d000a0907000000000000000000000000746f2074686520636c6f7564732c,
        0x0d0e000a080700000000000000000000000000000000000000007368796c792c,
        0x0e0f000908070000000000000000746f7761726473206869732073686f65732c,
        0x00100f0e0d0c0000000000000000000000000000000000007468652073756e20,
        0x10110f0e0d0b00000000000000000000000000000000007468652077696e6420,
        0x11120f0e0c0b0000000000000000000000000074686520666f6f747374657073,
        0x12130f0d0c0b0000000000007468756e6465726f7573206c6175676874657220,
        0x13000e0d0c0b000000000000007477696e6b6c696e6720666561747572657320,
        0x00140013121100000000000000000000000000000000626f6973746572656420,
        0x1415001312100000000000000000000000000000000000617373756167656420,
        0x151600131110000000000000000000000000000000006563686f656420696e20,
        0x1600001211100000000000000000000000000000000000006272757368656420,
        0x00170000161500000000000000000000686973206578636974656d656e742e20,
        0x1718000016140000000000000000000000000000006869732066656172732e20,
        0x1800000015140000000000000000000000000000000068697320656172732e20,
        0x00190000001800000000000000000000000000486973207374727567676c6520,
        0x19000000001700000000000000000000000048697320616476656e7475726520,
        0x00000000000000000000000000776173206a75737420626567696e6e696e672e
    ];
    uint256 private immutable _deployedBlockNumber;

    constructor(string memory name_, string memory symbol_) ERC721A(name_, symbol_) {
        _deployedBlockNumber = block.number;
    }

    function indexIsValid(uint256 _index) internal pure {
        require(_index > 0, "Use a positive, non-zero index for your nodes.");
        require(_index <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
    }

    function _getNode(uint8 index) internal view returns (bytes32) {
        return bytes32(nodes[index]);
    }

    function _getLeftChild(uint8 index) internal view returns (uint8) {
        indexIsValid(index);
        return uint8(_getNode(index)[0]);
    }

    function _getRightChild(uint8 index) internal view returns (uint8) {
        indexIsValid(index);
        return uint8(_getNode(index)[1]);
    }

    function _getValueBytes(uint8 index) internal view returns (bytes32) {
        indexIsValid(index);
        return _getNode(index) & bytes32(VALUE_FILTER);
    }

    function _getSiblings(uint8 index) internal view returns (uint8[4] memory) {
        indexIsValid(index);
        uint8[4] memory siblings;
        bytes32 node = _getNode(index);
        for (uint8 i = 0; i < MAX_NUM_SIBLINGS; i++) {
            uint8 sib = uint8(node[2 + i]);
            siblings[i] = sib;
        }
        return siblings;
    }

    function _getJitterChild(uint8 index, uint256 seed) internal view returns (uint8) {
        indexIsValid(index);

        uint8 left = _getLeftChild(index);
        uint8 right = _getRightChild(index);
        uint8[4] memory siblings = [0, 0, 0, 0];
        if (left > 0) {
            siblings = _getSiblings(left);
        } else if (right > 0) {
            siblings = _getSiblings(right);
        } else {
            // TODO: emit an error?
            console.log("this isn't possible. How did we get here?");
            return 0;
        }
        // "jittering" should usually take us off the expected path.
        for (uint8 i = 0; i < MAX_NUM_SIBLINGS; i++) {
            uint8 thisOne = uint8(seed % 2);
            uint8 sib = siblings[i];
            if (thisOne == 1 && sib != right && sib > 0) {
                return sib;
            }
            seed = seed >> 1;
        }
        // but sometimes, we stay on the path
        if (seed % 2 == 1) {
            return left;
        }
        return right;
    }

    function mint() public {
        address to = msg.sender;
        require(_totalMinted() < MAX_NUM_NFTS, "Out of tokens.");
        require(_numberMinted(to) == 0, "You can only mint 1 token.");
        _mint(to, 1);
    }

    // TODO: prevent transferring to contracts

    function _newHistoricalInput(
        uint256 currInput,
        uint256 from,
        uint256 to,
        uint256 difficulty,
        uint256 blockNumber
    ) internal pure returns (uint256) {
        // We're okay with an overflow or underflow here.
        // This is about storing the "essence" of history, not keep an accurate record.
        unchecked {
            uint256 part1 = uint160(from) + difficulty;
            uint256 part2 = uint160(to) + blockNumber;
            if (part1 > part2) {
                return currInput + part1 - part2;
            } else {
                return currInput + part2 - part1;
            }
        }
    }

    /**
     * @dev Hook that is called after a set of serially-ordered token IDs
     * have been transferred. This includes minting.
     * And also called after one token has been burned.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256,
        uint256
    ) internal override {
        _historicalInput = _newHistoricalInput(
            _historicalInput,
            uint256(uint160(from)),
            uint256(uint160(to)),
            block.difficulty,
            block.number
        );
        if (to != address(0)) {
            // If it's not being burned, store transfer timestamp
            //      Because we only have 64 bits, we can't store the full block number.
            //      Instead, we'll store the difference between this block and the deploy block.
            //      That's enough bits to store roughly 77M centuries
            //      from deployment, if I'm counting correctly.
            uint64 MAX_VAL = 18446744073709551615;
            uint256 newBlockNumber = block.number - _deployedBlockNumber;
            if (newBlockNumber >= MAX_VAL) {
                _setAux(to, MAX_VAL);
            } else {
                _setAux(to, uint64(newBlockNumber));
            }
        }
    }

    /**
     * @dev Called during each token transfer to set the 24bit `extraData` field.
     * Intended to be overridden by the cosumer contract.
     *
     * `previousExtraData` - the value of `extraData` before transfer.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _extraData(
        address,
        address to,
        uint24 previousExtraData
    ) internal pure override returns (uint24) {
        if (to == address(0)) {
            // If it's being burned, we don't need to store anything
            return previousExtraData;
        }

        uint24 MAX_VAL = 16777215;
        uint32 numOwnersHad;
        unchecked {
            // This will never overflow bc previousExtraData is a uint24 and numOwnersHad is a uint32.
            numOwnersHad = previousExtraData + 1;
        }
        if (numOwnersHad >= MAX_VAL) {
            return MAX_VAL;
        } else {
            return uint24(numOwnersHad);
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token IDs
     * are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address,
        address to,
        uint256 startTokenId,
        uint256
    ) internal override {
        // If we're burning the token and we're not done, take the next step.
        // Note that calling this in _beforeTokenTransfers instead of in the public burn function
        // ensures that the owner check on burning happens BEFORE we take the step.
        if (uint160(to) == 0) {
            if (currStep < MAX_NUM_NFTS) {
                takeNextStep(startTokenId);
            }
        } else {
            // If we're not burning, the receiver can only hold 3 tokens at a time.
            require(balanceOf(to) <= 2, "One can hold max 3 tokens at a time.");
        }
    }

    /**
     * @dev Burns `tokenId`. See {ERC721A-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public {
        _burn(tokenId, true);
    }

    function _opacityLevel(uint256 numBlocksHeld) internal pure returns (uint8) {
        uint256 estNumMonthsHeld = numBlocksHeld / (7000 * 30);
        if (estNumMonthsHeld < 4) {
            return 0;
        } else if (estNumMonthsHeld >= 4 && estNumMonthsHeld < 5) {
            return 5;
        } else if (estNumMonthsHeld >= 5 && estNumMonthsHeld < 6) {
            return 10;
        } else if (estNumMonthsHeld >= 6 && estNumMonthsHeld < 7) {
            return 15;
        } else if (estNumMonthsHeld >= 7 && estNumMonthsHeld < 8) {
            return 20;
        } else if (estNumMonthsHeld >= 8 && estNumMonthsHeld < 9) {
            return 40;
        } else if (estNumMonthsHeld >= 9 && estNumMonthsHeld < 10) {
            return 60;
        } else if (estNumMonthsHeld >= 10 && estNumMonthsHeld < 11) {
            return 80;
        } else {
            return 100;
        }
    }

    function _jitterLevel(uint24 numOwners) internal pure returns (uint8) {
        if (numOwners < 5) {
            return 0;
        } else if (numOwners >= 5 && numOwners < 10) {
            return 10;
        } else if (numOwners >= 10 && numOwners < 20) {
            return 15;
        } else if (numOwners >= 20 && numOwners < 30) {
            return 20;
        } else if (numOwners >= 30 && numOwners < 40) {
            return 25;
        } else {
            return 30;
        }
    }

    function _getCurrIndex(uint160 fromSeed) internal view returns (uint8) {
        // If our currIndex is non-zero, return it.
        uint8 currIndex = path[currStep];
        if (currIndex != 0) {
            return currIndex;
        }

        // If we had an opacity issue and don't know where we are,
        // pick a random place we _could_ be to decide where to go next.
        // 1. Figure out the last time we had a value
        uint8 nonZeroStep = currStep;
        while (currIndex == 0 && nonZeroStep > 0) {
            nonZeroStep -= 1;
            currIndex = path[nonZeroStep];
        }

        // 2. Take a pseudorandom walk to a place we could be
        for (uint8 i = nonZeroStep; i < currStep; i++) {
            uint8 leftChild = _getLeftChild(currIndex);
            uint8 rightChild = _getRightChild(currIndex);
            if (leftChild == 0) {
                currIndex = rightChild;
            } else if (rightChild == 0) {
                currIndex = leftChild;
            } else if (fromSeed % 2 == 0) {
                currIndex = leftChild;
            } else {
                currIndex = rightChild;
            }
            fromSeed >> 1;
        }
        return currIndex;
    }

    function takeNextStep(uint256 tokenId) private {
        TokenOwnership memory info = _ownershipOf(tokenId);
        uint64 lastTransferBlockNumber = _getAux(info.addr);
        uint24 numOwners = info.extraData;

        // Info 1: figure out opacity
        uint256 numBlocksHeld = block.number - _deployedBlockNumber - lastTransferBlockNumber;
        uint8 hiddenPercentage = _opacityLevel(numBlocksHeld);
        if (hiddenPercentage == 100) {
            currStep += 1;
            return;
        }

        // Info 2: figure out jitter
        uint8 remainingPercentage = 100 - hiddenPercentage;
        uint8 jitterLevel = _jitterLevel(numOwners);
        uint8 jitterPercentage = uint8((uint16(remainingPercentage) * uint16(jitterLevel)) / 100);
        uint8 childPercentage = (remainingPercentage - uint8(jitterPercentage)) / 2;

        // Now determine the percentage chance we pick an expected child and the chance we experience a jitter
        uint8 leftMax = childPercentage;
        uint8 rightMax = 2 * childPercentage;
        uint8 jitterMax = rightMax + uint8(jitterPercentage);

        // TODO: handle potential overflow
        uint256 historicalSeed = uint256(_historicalInput + uint160(info.addr));
        uint8 seed = uint8(historicalSeed % 100);

        uint8 currIndex = _getCurrIndex(uint160(info.addr));
        currStep += 1;
        uint8 leftChild = _getLeftChild(currIndex);
        uint8 rightChild = _getRightChild(currIndex);
        if (seed <= leftMax) {
            if (leftChild > 0) {
                path[currStep] = leftChild;
            } else {
                path[currStep] = rightChild;
            }
        } else if (seed <= rightMax) {
            if (rightChild > 0) {
                path[currStep] = rightChild;
            } else {
                path[currStep] = leftChild;
            }
        } else if (seed <= jitterMax) {
            path[currStep] = _getJitterChild(currIndex, historicalSeed >> 30);
        }
        // else, it's in the "hiddenPercentage" zone and we don't pick a child
        return;
    }
}
