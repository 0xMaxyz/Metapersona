// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Chromatid} from "./Chromatid.sol";

contract Chromosome is Chromatid {
    constructor(bytes32[39] memory genes) Chromatid(genes) {}
}
