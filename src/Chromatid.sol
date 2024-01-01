// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Helpers} from "./lib/Helpers.sol";
import {Constants} from "./lib/Constants.sol";
import {Errors} from "./lib/Errors.sol";

abstract contract Chromatid {
    bytes32[39] internal chromatid;

    constructor(bytes32[39] memory genes) {
        chromatid = genes;
    }
}
