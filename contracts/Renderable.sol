//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

/* solhint-disable quotes */
abstract contract RenderableMetadata {
    uint256 private indexLocation = 0x15242633353742444648515355575962646668737577848695000000000000;

    function _getValueBytes(uint8 index) internal view virtual returns (bytes32);

    function _getTokenUri(
        uint256 _tokenId,
        uint8 currStep,
        uint8[9] storage path,
        bool _shouldRenderDiamond
    ) internal view returns (string memory) {
        string memory svgString = _getSvg(currStep, path, _shouldRenderDiamond);
        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(bytes(getJSON(_tokenId, Base64.encode(bytes(svgString)))))
            );
    }

    function _getSvg(
        uint8 currStep,
        uint8[9] storage path,
        bool _shouldRenderDiamond
    ) internal view returns (string memory) {
        string memory svgString;
        if (_shouldRenderDiamond) {
            svgString = renderDiamond(path, currStep);
        } else {
            svgString = renderLine(path, currStep);
        }
        return svgString;
    }

    function getJSON(uint256 _tokenId, string memory _imageData) public pure returns (string memory) {
        /* solhint-disable max-line-length */
        return
            string.concat(
                '{"name": "Piece #',
                uint2str(_tokenId),
                '", "description":"POEM is a collaborative poetry pathfinder. As tokens are minted, transferred, and held, the path before us changes. To take the next step, we must burn a token. Let us see what we create together.", "image": "data:image/svg+xml;base64,',
                _imageData,
                '"}'
            );
    }

    function renderDiamond(uint8[9] storage path, uint8 currStep) private view returns (string memory) {
        /* solhint-disable max-line-length */
        string
            memory returnVal = '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="800" style="background:#1a1a1a"><style>.node{font-size:18px;font-family:serif;color:#a9a9a9;height:100%;overflow:auto;} .nodeNotSelected{font-size:18px;font-family:serif;color:#555555;height:100%;overflow:auto;} .nodeSelected{font-size:18px;font-family:serif;color:white;height:100%;overflow:auto;} .nodeHidden{font-size:18px;font-family:serif;color:#333333;text-decoration:line-through;height:100%;overflow:auto;}</style>';
        for (uint8 i = 1; i <= 25; i++) {
            bytes32 phraseBytes = _getValueBytes(i);
            uint8[2] memory dimen = nodeIndexToRowColumn(i);
            returnVal = string.concat(
                returnVal,
                renderNodeWord(path[dimen[0] - 1], currStep, bytes32ToString(phraseBytes), i, dimen[0], dimen[1])
            );
        }
        return string.concat(returnVal, "</svg>");
    }

    function renderLine(uint8[9] storage path, uint8 currStep) private view returns (string memory) {
        /* solhint-disable max-line-length */
        string
            memory returnVal = '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="800" style="background:#1a1a1a"><style>.sentence{font-size:70px;font-family:serif;color:white;height:100%;overflow:auto;}</style>';
        string memory sentence = "";
        for (uint8 i = 0; i < 9; i++) {
            uint8 index = path[i];
            sentence = string.concat(sentence, getNodeText(i, currStep, index));
        }
        string memory sentenceWrapped = Svg.wrapText(
            sentence,
            Svg.prop("class", "sentence"),
            string.concat(Svg.prop("x", "30"), Svg.prop("y", "20"), Svg.prop("width", "760"), Svg.prop("height", "760"))
        );
        return string.concat(string.concat(returnVal, sentenceWrapped), "</svg>");
    }

    function getNodeText(
        uint8 row,
        uint8 _currStep,
        uint8 index
    ) private view returns (string memory) {
        if (row > _currStep) {
            return unicode"█████";
        }
        if (index == 0) {
            return unicode"█████ ";
        }
        return bytes32ToString(_getValueBytes(index));
    }

    function nodeIndexToRowColumn(uint8 nodeIndex) private view returns (uint8[2] memory) {
        bytes1 info = bytes32(indexLocation)[nodeIndex];
        uint8 row = uint8(info >> 4);
        uint8 col = uint8((info << 4) >> 4);
        return [row, col];
    }

    function renderNodeWord(
        uint8 pathVal,
        uint8 currStep,
        string memory value,
        uint8 index,
        uint256 row,
        uint256 column
    ) private pure returns (string memory) {
        return
            Svg.wrapText(
                value,
                Svg.prop("class", getTextClass(pathVal, currStep, index, row)),
                string.concat(
                    Svg.prop("x", uint2str(column * 80 - 40)),
                    Svg.prop("y", uint2str(row * 75)),
                    Svg.prop("width", "130"),
                    Svg.prop("height", "60")
                )
            );
    }

    function getTextClass(
        uint8 pathVal,
        uint8 currStep,
        uint8 index,
        uint256 row
    ) private pure returns (string memory) {
        if (currStep >= row - 1) {
            if (pathVal == index) {
                // If this node was selected
                return "nodeSelected";
            }
            if (pathVal == 0) {
                // If this row was hidden
                return "nodeHidden";
            }
            // If we're passed this row and this node wasn't selected
            return "nodeNotSelected";
        }
        // If this node could be selected in the future
        return "node";
    }

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 numNonZeroBytes = 0;
        for (uint8 i = 0; i < 32; i++) {
            if (_bytes32[i] != 0) {
                numNonZeroBytes++;
            }
        }

        bytes memory bytesArray = new bytes(numNonZeroBytes);
        uint8 bytesArrayIndex = 0;
        for (uint8 k = 0; k < 32; k++) {
            if (_bytes32[k] != 0) {
                bytesArray[bytesArrayIndex] = _bytes32[k];
                bytesArrayIndex++;
            }
        }
        return string(bytesArray);
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

// These library functions are copied from the Hot Chain Svg project.
library Svg {
    function text(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("text", _props, _children);
    }

    function wrapText(
        string memory _text,
        string memory _textProps,
        string memory _boxProps
    ) internal pure returns (string memory) {
        return
            el(
                "foreignObject",
                _boxProps,
                el("div", string.concat(prop("xmlns", "http://www.w3.org/1999/xhtml"), _textProps), _text)
            );
    }

    /* COMMON */
    // A generic element, can be used to construct any SVG (or HTML) element
    function el(
        string memory _tag,
        string memory _props,
        string memory _children
    ) internal pure returns (string memory) {
        return string.concat("<", _tag, " ", _props, ">", _children, "</", _tag, ">");
    }

    // an SVG attribute
    function prop(string memory _key, string memory _val) internal pure returns (string memory) {
        return string.concat(_key, "=", '"', _val, '" ');
    }
}

// This library function is copied from the WatchfacesWorld project
library Base64 {
    string internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        /* solhint-disable no-inline-assembly, no-empty-blocks */
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}
