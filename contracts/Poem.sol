// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Poem is ERC721A, Ownable {
    uint8 public constant MAX_NUM_SIBLINGS = 4;
    uint8 public constant MAX_LEN_VALUE = 26;
    uint8 public constant MAX_INDEX_VAL = 25;
    uint8 public constant MAX_NUM_NFTS = 7;

    uint8[9] public path = [1, 0, 0, 0, 0, 0, 0, 0, 25];
    uint8 public currStep = 0;
    uint256 private immutable _deployedBlockNumber;
    uint256 internal _historicalInput = 1;

    constructor(string memory name_, string memory symbol_) ERC721A(name_, symbol_) {
        _deployedBlockNumber = block.number;
    }

    function _getLeftChild(uint8 index) internal view virtual returns (uint8);

    function _getRightChild(uint8 index) internal view virtual returns (uint8);

    function _getJitterChild(uint8 index, uint8 sibIndex) internal view virtual returns (uint8);

    function mint() public {
        address to = msg.sender;
        require(_totalMinted() < MAX_NUM_NFTS, "Out of tokens.");
        require(_numberMinted(to) == 0, "You can only mint 1 token.");
        require(balanceOf(to) <= 2, "One can hold max 3 tokens at a time.");
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
        uint256 adjustment = uint256((uint256(uint160(from)) + uint256(uint160(to))) + difficulty - blockNumber);
        return uint256(currInput + adjustment);
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
    ) internal virtual override {
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
            //      That's enough bits to store an excessive amount of time. Roughly 77M centuries
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
    ) internal view virtual override returns (uint24) {
        if (to == address(0)) {
            // If it's being burned, we don't need to store anything
            return previousExtraData;
        }

        uint24 MAX_VAL = 16777215;

        uint32 numOwnersHad = previousExtraData + 1;
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
        // Ensures that the owner check on burning happens BEFORE we take the step.
        if (uint160(to) == 0) {
            if (currStep <= 6) {
                takeNextStep(startTokenId);
            }
        }
    }

    /**
     * @dev Burns `tokenId`. See {ERC721A-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
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

    function _jitterLevel(uint24 numOwners) internal view returns (uint8) {
        if (numOwners < 5 || currStep == 0) {
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
        uint8 currIndex = path[currStep];
        if (currIndex != 0) {
            return currIndex;
        }
        // Otherwise, pick one of our potential indices:
        // 1. Figure out the last time we had a value
        uint8 nonZeroStep = currStep;
        while (currIndex == 0 && nonZeroStep > 0) {
            nonZeroStep -= 1;
            currIndex = path[nonZeroStep];
        }

        for (uint8 i = nonZeroStep; i < currStep; i++) {
            if (fromSeed % 2 == 0) {
                currIndex = _getLeftChild(currIndex);
            } else {
                currIndex = _getRightChild(currIndex);
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
        uint8 jitterPercentage = (remainingPercentage * _jitterLevel(numOwners)) / 100;
        uint8 childPercentage = (remainingPercentage - jitterPercentage) / 2;

        // Now determine the percentage chance we pick an expected child and chance we experience a jitter
        uint8 leftMax = childPercentage;
        uint8 rightMax = 2 * childPercentage;
        uint8 jitterMax = rightMax + jitterPercentage;

        uint256 historicalSeed = uint256(_historicalInput + uint160(info.addr));
        uint8 seed = uint8(historicalSeed % 100);

        uint8 currIndex = _getCurrIndex(uint160(info.addr));
        currStep += 1;
        if (seed <= leftMax) {
            path[currStep] = _getLeftChild(currIndex);
        } else if (seed <= rightMax) {
            path[currStep] = _getRightChild(currIndex);
        } else if (seed <= jitterMax) {
            path[currStep] = _getJitterChild(currIndex, seed % 4);
        }
        // else, it's in the "hiddenPercentage" zone and we don't pick a child
        return;
    }
}
