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
        uint8 jitterLevel,
        uint8 hiddenLevel,
        bool _shouldRenderDiamond
    ) internal view returns (string memory) {
        string memory svgString = _getSvg(_tokenId, currStep, path, jitterLevel, hiddenLevel, _shouldRenderDiamond);
        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        _getJSON(
                            _tokenId,
                            jitterLevel,
                            hiddenLevel,
                            getSentence(currStep, path),
                            Base64.encode(bytes(svgString))
                        )
                    )
                )
            );
    }

    function _getSvg(
        uint256 tokenId,
        uint8 currStep,
        uint8[9] storage path,
        uint16 jitterLevel,
        uint16 hiddenLevel,
        bool _shouldRenderDiamond
    ) internal view returns (string memory) {
        uint16 blur = 100 - hiddenLevel;
        string memory opacity = string.concat("0.", uint2str(blur));
        string memory transformString = "";
        if (blur == 100) {
            opacity = "1";
        }
        if (_shouldRenderDiamond) {
            transformString = ' transform-origin="center" transform="rotate(45)scale(0.7)"';
        } else {
            transformString = "";
        }
        string memory jitterVal = uint2str(jitterLevel * 10);
        string memory id = uint2str(uint16(uint256(keccak256(abi.encode(jitterLevel, hiddenLevel, tokenId)))));
        /* solhint-disable max-line-length */
        string memory svgString = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" height="100%" width="100%" viewBox="0 0 800 800"><defs><filter id="adj',
            id,
            '" x="0" y="0"><feTurbulence type="turbulence" baseFrequency="0.001" seed="',
            uint2str(tokenId + 1),
            '" numOctaves="',
            jitterVal,
            '" result="turbulence" /><feDisplacementMap  in2="turbulence"  in="SourceGraphic"  scale="',
            jitterVal,
            '" /></filter></defs><g',
            transformString,
            '><style>.a{fill:#640202;stroke:#600000;stroke-width:14}.b{fill:#600000}</style><path class="a" d="m7 7h786v786h-786z"/><path class="a" d="m150 150h500v500h-500z"/><path class="b" d="m13.7 795.3l-9.8-9.9 143.4-142.8 9.9 10z"/><path class="b" d="m4.5 14.3l10-9.8 143.4 144.9-9.9 9.8z"/><path class="b" d="m793.6 784.7l-9.9 9.9-142.8-143.5 10-9.9z"/><path class="b" d="m655.5 152.8l-9.9-9.9 139.2-137.6 9.9 9.9z"/></g>'
        );
        if (_shouldRenderDiamond) {
            svgString = string.concat(svgString, renderDiamond(path, currStep, opacity, id));
        } else {
            svgString = string.concat(svgString, renderLine(path, currStep, opacity, id));
        }
        return svgString;
    }

    function _getJSON(
        uint256 _tokenId,
        uint16 jitterLevel,
        uint16 hiddenLevel,
        string memory poem,
        string memory _imageData
    ) internal pure returns (string memory) {
        /* solhint-disable max-line-length */
        return
            string.concat(
                '{"name": "Gem #',
                uint2str(_tokenId),
                '","image":"data:image/svg+xml;base64,',
                _imageData,
                '","description": "POEM is a collaborative poetry pathfinder. As gems are found, sold, and held, the path before us changes. To take the next step, we must burn a token. Let us see what we create together.","attributes": [{"trait_type":"energy","value":',
                uint2str(100 - hiddenLevel),
                '},{"trait_type":"chaos","value":',
                uint2str(jitterLevel),
                '},{"trait_type":"poem","value":"',
                poem,
                '"}]}'
            );
    }

    function renderDiamond(
        uint8[9] storage path,
        uint8 currStep,
        string memory opacity,
        string memory id
    ) private view returns (string memory) {
        string memory returnVal = string.concat(
            unicode"<style>[class*='node",
            id,
            unicode"-']{font-size:18px;font-family:serif;height:100%;overflow:auto;opacity:",
            opacity,
            ";text-align:center} .node",
            id,
            "-default{color:#b67272;} .node",
            id,
            "-notSelected{color:#965252;} .node",
            id,
            "-selected{color:white;} .node",
            id,
            '-hidden{color:#500000;text-decoration:line-through;}</style><svg filter="url(#adj',
            id,
            ')">'
        );
        for (uint8 i = 1; i <= 25; i++) {
            bytes32 phraseBytes = _getValueBytes(i);
            uint8[2] memory dimen = nodeIndexToRowColumn(i);
            returnVal = string.concat(
                returnVal,
                renderNodeWord(path[dimen[0] - 1], currStep, bytes32ToString(phraseBytes), i, dimen[0], dimen[1], id)
            );
        }
        return string.concat(returnVal, "</svg></svg>");
    }

    function renderLine(
        uint8[9] storage path,
        uint8 currStep,
        string memory opacity,
        string memory id
    ) private view returns (string memory) {
        string memory returnVal = string.concat(
            "<style>.sentence",
            id,
            "{font-size:70px;text-align:left;font-family:serif;color:white;height:100%;overflow-wrap:break-word;opacity:",
            opacity,
            "}</style>"
        );
        string memory sentenceWrapped = Svg.wrapText(
            getSentence(currStep, path),
            Svg.prop("class", string.concat("sentence", id)),
            string.concat(
                Svg.prop("x", "30"),
                Svg.prop("y", "20"),
                Svg.prop("width", "760"),
                Svg.prop("height", "760"),
                Svg.prop("filter", string.concat("url(#adj", id, ")"))
            )
        );
        return string.concat(returnVal, sentenceWrapped, "</svg>");
    }

    function getSentence(uint8 currStep, uint8[9] storage path) private view returns (string memory) {
        string memory sentence = "";
        for (uint8 i = 0; i < 9; i++) {
            uint8 index = path[i];
            sentence = string.concat(sentence, getNodeText(i, currStep, index));
        }
        return sentence;
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
        uint256 column,
        string memory id
    ) private pure returns (string memory) {
        if (row - 1 > currStep) {
            value = "?";
        }
        return
            Svg.wrapText(
                value,
                Svg.prop("class", getTextClass(pathVal, currStep, index, row, id)),
                string.concat(
                    Svg.prop("x", uint2str(column * 80 - 60)),
                    Svg.prop("y", uint2str(row * 75)),
                    Svg.prop("width", "120"),
                    Svg.prop("height", "70")
                )
            );
    }

    function getTextClass(
        uint8 pathVal,
        uint8 currStep,
        uint8 index,
        uint256 row,
        string memory id
    ) private pure returns (string memory) {
        if (currStep >= row - 1) {
            if (pathVal == index) {
                return string.concat("node", id, "-selected");
            }
            if (pathVal == 0) {
                return string.concat("node", id, "-hidden");
            }
            // If we're passed this row and this node wasn't selected
            return string.concat("node", id, "-notSelected");
        }
        // If this node could be selected in the future
        return string.concat("node", id, "-default");
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
