// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Structs {
    struct Chromosome {
        uint256[39] DNA;
    }

    struct Chromosomes {
        // 3rd element is for chromosomal abnormalities
        Chromosome[3] chromosome;
    }
}
