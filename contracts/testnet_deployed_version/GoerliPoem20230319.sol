// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./GoerliRenderable20230319.sol";

/// Index should be > 0 and <= MAX_INDEX_VAL
error InvalidIndexMin1Max25();
error MintFeeNotMet();
error OutOfTokens();
error YouCanOnlyMint1Token();
error OneCanHoldMax3Tokens(address to);

contract Poem20230319 is ERC721A, Ownable, RenderableMetadata {
    uint8 internal constant MAX_NUM_JITTERS = 3;
    uint8 internal constant MAX_INDEX_VAL = 25;

    uint8 public constant MAX_NUM_NFTS = 7;
    uint8 public currStep = 0;
    uint8[9] public path = [1, 0, 0, 0, 0, 0, 0, 0, 25];
    uint256 public mintFee; // In wei

    uint256 private constant VALUE_FILTER = 0x0000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 private immutable _deployedBlockNumber;
    uint256 internal _historicalInput = 1;
    uint256[26] internal _nodes = [
        0,
        909926238360867929735398212882603035651154206890943763432627265628419941664,
        1818085630288831225152556248451971318888503523798382480318670550428524307488,
        2272165325726251414518349332747065322088826020657626361753819989959403463712,
        3180324987148369089773348128288666447838811641617614208638020369611860767520,
        3634404682585789279139141212583760451039134138476858583137030637339093005088,
        4088484324313940717540769080940660335567536152699603319147880213682479002400,
        4996747404196785874318577405850053296304456278064491627768569074979230526496,
        5450827099634206063684370490145147299505383335278118719355313680067884952608,
        5904906741362357502085998358502047184033180789146480233733677844117077961760,
        6358972633517708693661330946683849285079837964484281646812318644041703173152,
        28401173286392137062282498244147996712585788310297368222521403865233190432,
        7267042491568102673472288079791435007277491848695276522382272216462879777824,
        7721122187005522862838081164086529010477816706585060482103526844235668026144,
        8175201828733674301239709033108001331624392849233692055307543228010251776544,
        8594068814520393617499124365727618858396950975904160398476206872148189541152,
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
    constructor(uint256 _mintPrice) ERC721A("Pathfinder", "POEM") {
        _deployedBlockNumber = block.number;
        mintFee = _mintPrice;
    }

    // ========= VALIDATION =========
    function indexIsValid(uint256 _index) internal pure {
        if (_index <= 0 || _index > MAX_INDEX_VAL) {
            revert InvalidIndexMin1Max25();
        }
    }

    // ========= PAYMENTS =========
    // withdraw funds, royalties

    event ThankYou(address);

    function tipTheCreator() external payable {
        emit ThankYou(msg.sender);
    }

    function withdrawAllEth() external {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawAllERC20(IERC20 _erc20Token) external {
        _erc20Token.transfer(owner(), _erc20Token.balanceOf(address(this)));
    }

    function updateMintFee(uint256 mintFeeWei) external onlyOwner {
        mintFee = mintFeeWei;
    }

    // ========= PUBLIC FUNCTIONS =========
    // mint, burn, tokenURI, SVG

    function totalMinted() external view returns (uint256) {
        return _totalMinted();
    }

    function totalBurned() external view returns (uint256) {
        return _totalBurned();
    }

    function totalMintedTo(address to) external view returns (uint256) {
        return _numberMinted(to);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken(); // do we want this check?
        TokenOwnership memory info = _ownershipOf(_tokenId);
        uint64 lastTransferBlockNumber = _getAux(info.addr);
        uint24 numOwners = info.extraData;
        uint256 numBlocksHeld = block.number - _deployedBlockNumber - lastTransferBlockNumber;

        return
            _getTokenUri(
                _tokenId,
                currStep,
                path,
                _jitterLevel(numOwners),
                _hiddenLevel(numBlocksHeld),
                _shouldRenderDiamond()
            );
    }

    function getDefaultSvg() external view returns (string memory) {
        return _getSvg(0, currStep, path, 0, 0, _shouldRenderDiamond());
    }

    function getHiddenLevel(uint8 _tokenId) external view returns (uint8) {
        TokenOwnership memory info = _ownershipOf(_tokenId);
        uint64 lastTransferBlockNumber = _getAux(info.addr);

        uint256 numBlocksHeld = block.number - _deployedBlockNumber - lastTransferBlockNumber;
        return _hiddenLevel(numBlocksHeld);
    }

    function getJitterLevel(uint8 _tokenId) external view returns (uint8) {
        TokenOwnership memory info = _ownershipOf(_tokenId);
        uint24 numOwners = info.extraData;

        return _jitterLevel(numOwners);
    }

    function mint() external payable {
        if (msg.value != mintFee) {
            revert MintFeeNotMet();
        }
        address to = msg.sender;
        if (_totalMinted() >= MAX_NUM_NFTS) {
            revert OutOfTokens();
        }
        if (_numberMinted(to) != 0) {
            revert YouCanOnlyMint1Token();
        }
        _safeMint(to, 1);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId, true);
    }

    // ========= HOOKS=========
    function _beforeTokenTransfers(
        address,
        address to,
        uint256 startTokenId,
        uint256
    ) internal override {
        // If we're burning the token and we're not done, take the next step.
        // Note that calling this in _beforeTokenTransfers instead of in the public burn function
        // to ensure that the owner check on burning happens BEFORE we take the step.
        if (uint160(to) == 0) {
            if (currStep < MAX_NUM_NFTS) {
                _takeNextStep(startTokenId);
            }
        } else {
            // If we're not burning, the receiver can only hold 3 tokens at a time.
            if (balanceOf(to) > 2) {
                revert OneCanHoldMax3Tokens(to);
            }
        }
    }

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
            //      That's enough bits to store roughly 77M centuries from deployment.
            uint256 newBlockNumber = block.number - _deployedBlockNumber;
            // Unchecked because we can let it wrap around to zero after 77M centuries
            unchecked {
                _setAux(to, uint64(newBlockNumber));
            }
        } else {
            // If we've burning the last token, set our currStep to the end.
            //    It's MAX_NUM_NFTs-1 because the burn counter is
            //    incremented after this function is called
            if (_totalBurned() == MAX_NUM_NFTS - 1) {
                currStep = 8;
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
            // This will never overflow
            numOwnersHad = previousExtraData + 1;
        }
        if (numOwnersHad >= maxVal) {
            return maxVal;
        } else {
            return uint24(numOwnersHad);
        }
    }

    function _takeNextStep(uint256 tokenId) private {
        TokenOwnership memory info = _ownershipOf(tokenId);
        uint64 lastTransferBlockNumber = _getAux(info.addr);
        uint24 numOwners = info.extraData;

        // 1: figure out opacity
        uint256 numBlocksHeld = block.number - _deployedBlockNumber - lastTransferBlockNumber;
        uint8 hiddenPercentage = _hiddenLevel(numBlocksHeld);
        if (hiddenPercentage == 100) {
            currStep += 1;
            return;
        }

        // 2: figure out jitter
        uint8 remainingPercentage = 100 - hiddenPercentage;
        uint8 jitterLevel = _jitterLevel(numOwners);
        uint8 jitterPercentage = uint8((uint16(remainingPercentage) * uint16(jitterLevel)) / 100);
        uint8 childPercentage = (remainingPercentage - uint8(jitterPercentage)) / 2;

        // 3: Determine % chance of each outcome type
        uint8 leftMax = childPercentage;
        uint8 rightMax = 2 * childPercentage;
        uint8 jitterMax = rightMax + uint8(jitterPercentage);

        // We don't care about over/underflow.
        uint256 historicalSeed;
        unchecked {
            historicalSeed = uint256(_historicalInput + uint160(info.addr));
        }
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

    function _shouldRenderDiamond() internal view returns (bool) {
        return (_historicalInput >> 3) % 2 == 1;
    }

    function _getNode(uint8 index) internal view returns (bytes32) {
        return bytes32(_nodes[index]);
    }

    function _getLeftChild(uint8 index) internal view returns (uint8) {
        indexIsValid(index);
        return uint8(_getNode(index)[0]);
    }

    function _getRightChild(uint8 index) internal view returns (uint8) {
        indexIsValid(index);
        return uint8(_getNode(index)[1]);
    }

    function _getValueBytes(uint8 index) internal view override returns (bytes32) {
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

    function _numBlocksToEstMonths(uint256 numBlocks) internal pure returns (uint256) {
        return numBlocks / (7000 * 30);
    }

    function _hiddenLevel(uint256 numBlocksHeld) internal pure returns (uint8) {
        uint256 estNumMonthsHeld = _numBlocksToEstMonths(numBlocksHeld);
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
