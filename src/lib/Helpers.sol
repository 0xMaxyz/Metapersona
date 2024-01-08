// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Errors} from "./Errors.sol";

library Helpers {
    uint8 private constant CHAR_0 = uint8(bytes("0")[0]);
    uint8 private constant CHAR_9 = uint8(bytes("9")[0]);
    uint8 private constant CHAR_A = uint8(bytes("a")[0]);
    uint8 private constant CHAR_F = uint8(bytes("f")[0]);
    uint8 private constant CHAR_A_CAP = uint8(bytes("A")[0]);
    uint8 private constant CHAR_F_CAP = uint8(bytes("F")[0]);

    function getStringLength(string memory str) external pure returns (uint256) {
        return bytes(str).length;
    }

    // Convert a single hexadecimal character to its byte value representation
    function fromHexChar(uint8 c) public pure returns (uint8) {
        if ((c >= CHAR_0) && c <= CHAR_9) {
            return c - CHAR_0;
        } else if (c >= CHAR_A && c <= CHAR_F) {
            return 10 + c - CHAR_A;
        } else if (c >= CHAR_A_CAP && c <= CHAR_F_CAP) {
            return 10 + c - CHAR_A_CAP;
        } else {
            revert Errors.MetaPersona_InvalidHexChar();
        }
    }

    function random(uint256 seed) external view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender, seed)));
    }
}
