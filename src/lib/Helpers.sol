// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Errors} from "./Errors.sol";

library Helpers {
    function random(uint256 seed) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender, seed)));
    }

    function randomBetween(uint256 _seed, uint256 _min, uint256 _max) external view returns (uint256) {
        if (_min <= _max) {
            revert Errors.MetaPersona_InvalidInput();
        }

        uint256 rand = random(_seed);

        return (rand % (_max - _min + 1)) + _min;
    }
}
