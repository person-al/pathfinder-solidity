// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC2981 {
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

contract Poem is ERC721A, Ownable, IERC2981 {
    uint8 public constant MAX_NUM_JITTERS = 3;
    uint8 public constant MAX_INDEX_VAL = 25;
    uint8 public constant MAX_NUM_NFTS = 7;
    uint256 private constant VALUE_FILTER = 0x00000fffffffffffffffffffffffffff;

    uint256 public immutable _mintFee; // In wei
    uint256 private immutable _deployedBlockNumber;

    uint8[9] public path = [1, 0, 0, 0, 0, 0, 0, 0, 25];
    uint8 public currStep = 0;
    uint256 internal _historicalInput = 1;
    uint256[26] internal nodes = [
        0,
        909926238360867929735398212882603035651154206890943763432627265628419941664,
        1818085630288831225152556248451971318888503523798382480318670550428524307488,
        2272165325726251414518349332747065322088826020657626361753819989959403463712,
        3180324987148369089773348128288666447838811641617614208638020369611860767520,
        3634404682585789279139141212583760451039134138476858583137030637339093005088,
        4088484324313940717540769080940660335567536152699603319147880213682479002400,
        4996747404196785874318577405850053296304456278064491127104770402649314720044,
        5450827099634206063684370490145147299504781136487619317955575716192681489196,
        5904906741362357502085998358502047184033180789146480233733645486516586969388,
        6358972633517708693661330946681262831505134165285174307704094589306752299820,
        28401173286392137062282498244147996712585788310297368222521403865233190432,
        7267042491568102673472288079791435007277491848695276522382272216462879777824,
        7721122187005522862838081164086529010477814354777295948860271258278308442227,
        8175201828733674301239709033108001331624392849233692055307543228010251776544,
        8594068814520393617499124365727618858396950975904160398476206872204241367840,
        35337536625952488945442353345468866105503576651487143313660503028163503136,
        9083360762342544255095990558673540698909844224853249164312911225587916694560,
        9537440457779964444461783642968634702110166721712493522744180277778267598368,
        9950883237096986387747710946149794462226042099961420753510984315443664479264,
        40637485017397839625788323267119790410909743057208080281411575484228316704,
        10445599846969808156496454824392134265572084798328785506672366718191527996960,
        10855508368420576029336595138616605997968481005738390565983096147756436368928,
        44171176619459608239582437518572962895687103158953280726063294786640307488,
        11307821214581659709333104004754678501295898408692039780574742603076044219680,
        2662277745920782326914498756153016221122324270
    ];

    /**
     * _mintPrice is denominated in wei
     *
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _mintPrice
    ) ERC721A(name_, symbol_) {
        _deployedBlockNumber = block.number;
        _mintFee = _mintPrice;
    }

    // ========= VALIDATION =========
    function indexIsValid(uint256 _index) internal pure {
        require(_index > 0, "Use a positive, non-zero index for your nodes.");
        require(_index <= MAX_INDEX_VAL, "Cannot support more than 25 nodes.");
    }

    // ========= PAYMENTS =========
    // withdraw funds, royalties

    function withdrawAllEth() external {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawAllERC20(IERC20 _erc20Token) external {
        _erc20Token.transfer(owner(), _erc20Token.balanceOf(address(this)));
    }

    function supportsInterface(bytes4 _interfaceId) public view override returns (bool) {
        return _interfaceId == type(IERC2981).interfaceId || super.supportsInterface(_interfaceId);
    }

    function royaltyInfo(uint256, uint256 _salePrice) external view override returns (address, uint256) {
        return (owner(), _salePrice / 100);
    }

    // ========= PUBLIC FUNCTIONS =========
    // mint, burn

    function mint(bool plusTip) external payable {
        if (plusTip) {
            require(msg.value >= _mintFee, "Wrong price");
        } else {
            require(msg.value == _mintFee, "Wrong price");
        }
        address to = msg.sender;
        require(_totalMinted() < MAX_NUM_NFTS, "Out of tokens.");
        require(_numberMinted(to) == 0, "You can only mint 1 token.");
        _safeMint(to, 1);
    }

    /**
     * @dev Burns `tokenId`. See {ERC721A-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) external {
        _burn(tokenId, true);
    }

    // ========= HOOKS=========
    // beforeTransfer, afterTransfer

    // TODO: prevent transferring to contracts? Or does it matter?
    // TODO: Do I have a re-entrancy risk on minting, burning, or transferring?

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
            uint64 maxVal = 18446744073709551615;
            uint256 newBlockNumber = block.number - _deployedBlockNumber;
            if (newBlockNumber >= maxVal) {
                _setAux(to, maxVal);
            } else {
                _setAux(to, uint64(newBlockNumber));
            }
        }
    }

    // ========= MODIFYING INTERNAL DATA =========
    // storing owner count, transfer blockstamp, historical data,
    // taking the next step in our poem path

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

        uint24 maxVal = 16777215;
        uint32 numOwnersHad;
        unchecked {
            // This will never overflow bc previousExtraData is a uint24 and numOwnersHad is a uint32.
            numOwnersHad = previousExtraData + 1;
        }
        if (numOwnersHad >= maxVal) {
            return maxVal;
        } else {
            return uint24(numOwnersHad);
        }
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
            path[currStep] = _preferNonZeroVal(leftChild, rightChild, leftChild);
        } else if (seed <= rightMax) {
            path[currStep] = _preferNonZeroVal(leftChild, rightChild, rightChild);
        } else if (seed <= jitterMax) {
            path[currStep] = _getJitterChild(currIndex, historicalSeed >> 30);
        }
        // else, it's in the "hiddenPercentage" zone and we don't pick a child
        return;
    }

    // ========= INTERNAL GETTERS =========

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

    function _getJitterKids(uint8 index) internal view returns (uint8[3] memory) {
        indexIsValid(index);
        uint8[3] memory jitters;
        bytes32 node = _getNode(index);
        for (uint8 i = 0; i < MAX_NUM_JITTERS; i++) {
            jitters[i] = uint8(node[2 + i]);
        }
        return jitters;
    }

    function _preferNonZeroVal(
        uint8 option1,
        uint8 option2,
        uint8 preferred
    ) private pure returns (uint8) {
        if (preferred > 0) {
            return preferred;
        } else if (option1 > 0) {
            return option1;
        }
        return option2;
    }

    function _getJitterChild(uint8 index, uint256 seed) internal view returns (uint8) {
        indexIsValid(index);

        uint8[3] memory jitters = _getJitterKids(index);
        // "jittering" usually takes us off the expected path.
        for (uint8 i = 0; i < MAX_NUM_JITTERS; i++) {
            uint8 thisOne = uint8(seed % 2);
            uint8 j = jitters[i];
            if (thisOne == 1 && j > 0) {
                return j;
            }
            seed = seed >> 1;
        }
        // but sometimes, we stay on the path
        uint8 left = _getLeftChild(index);
        uint8 right = _getRightChild(index);
        if (seed % 2 == 1) {
            return _preferNonZeroVal(left, right, left);
        }
        return _preferNonZeroVal(left, right, right);
    }

    function _opacityLevel(uint256 numBlocksHeld) internal pure returns (uint8) {
        uint256 estNumMonthsHeld = numBlocksHeld / (7000 * 30);
        if (estNumMonthsHeld <= 4) {
            return 0;
        } else if (estNumMonthsHeld <= 12) {
            return uint8(12 * estNumMonthsHeld - 54);
        }
        return 100;
    }

    function _jitterLevel(uint24 numOwners) internal pure returns (uint8) {
        if (numOwners < 5) {
            return 0;
        } else if (numOwners < 10) {
            return 10;
        } else if (numOwners < 20) {
            return 15;
        } else if (numOwners < 30) {
            return 20;
        } else if (numOwners < 40) {
            return 25;
        } else {
            return 30;
        }
    }

    /**
     * Return the index of the node we're currently on. If our current node is
     * "hidden", return a node we _could_ be on.
     */
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
            if (fromSeed % 2 == 0) {
                currIndex = _preferNonZeroVal(leftChild, rightChild, leftChild);
            } else {
                currIndex = _preferNonZeroVal(leftChild, rightChild, rightChild);
            }
            fromSeed >> 1;
        }
        return currIndex;
    }
}
