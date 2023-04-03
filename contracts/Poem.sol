// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Renderable.sol";
import "./IERC4906.sol";

/// Index should be > 0 and <= MAX_INDEX_VAL
error InvalidIndexMin1Max25();
error MintFeeNotMet();
error OutOfTokens();
error YouCanOnlyMint1Token();
error OneCanHoldMax3Tokens(address to);

contract Poem is ERC721A, Ownable, RenderableMetadata, IERC4906 {
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
        909926238360867929735398212882603035651154206890943765045016467916676687136,
        1818085630288831225152556248451971318888503523798382480310458815959332643872,
        2272165325726251414518349332747065322088826020657626361746610005128180491296,
        3180324987148369089773348128288666447838811641617754937016204995381191602720,
        3634404682585789279139141212583760451039134138476998818452362667201525675808,
        4088484324313940717540769080940660335567536152699603319147591701831350580000,
        4996747404196785874318577574518732436239457003206005123780796073656619314208,
        5450827099634206063684370490145147299504781135953138366136996742706988788768,
        5904906741362357502085998358502047184033180789182506683369869381085680643104,
        6358972633517708693661330946681252721694745114521562559116258182992763956256,
        28401173286392137062282498244147996712585797453844752906497297566288129312,
        7267042491568102673472288079791435007277491848695416039695757951770697739552,
        7721122187005522862838081164086529010477816686302650906528229574704811027744,
        8175201828733674301239709032443428895006216368920813013741776612273540640032,
        8594068814520393617499167544906726529559004267002573124180864310697404476704,
        35337536625952488945442353345468866105503576651486680613904023256224917280,
        9083360762342544255095990558673540698909844224853249627178106287697995654944,
        9537440457779964444461783642968634702110166721712493045804330008850255996704,
        9950883237096986387747710946728864883886123773160573567615668309188887737120,
        40637485017397839625788323267119790272122513636518100172476145866495897120,
        10445599847013189259733731396253629037175415391554223306187261971216655134240,
        10855508368420576029336636817905695204924795288228489930808958924893436653088,
        44171176619459608239582437518572962895687097421890867835206555903583413280,
        11307821214581659709333104004754678501295896940003961333516881900789037365024,
        599231521422541571779177849951840302
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

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return (interfaceId == bytes4(0x49064906) || // ERC4906
            super.supportsInterface(interfaceId));
    }

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
        // tokenId is 0-indexed so the last ID we'll have is 6
        // The standard recommends not emitting this when a token is minted or burned
        //      But in our case, a token getting minted/burned updates all other tokens' metadata
        //      It's not worth emitting BatchMetadataUpdate twice to meet the recommendation imo.
        emit BatchMetadataUpdate(0, MAX_NUM_NFTS - 1);
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
