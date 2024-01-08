// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Genetics.sol";

error MetaPersona_NotMutable();
error MetaPersona_InvalidChromosome();
error MetaPersona_InvalidGeneticCombination();

contract Chromosomes {
    Chromosome private c1;
    Chromosome private c2;

    constructor(
        uint256[37] memory _autosomes1,
        uint256[2] memory _x1,
        uint192 _y1,
        uint256[37] memory _autosomes2,
        uint256[2] memory _x2,
        uint192 _y2
    ) {
        // revert if both sex chromosomes are the same
        if ((_y1 > 0 && _y2 > 0) || ((_x1[0] > 0 || _x1[1] > 0) && (_x2[0] > 0 || _x2[1] > 0))) {
            revert MetaPersona_InvalidGeneticCombination();
        }

        c1.setDNA(_autosomes1, _x1, _y1);
        c2.setDNA(_autosomes2, _x2, _y2);
    }

    function getX(uint8 _c) external view returns (uint256[2] memory) {
        if (_c > 2 || _c == 0) {
            revert MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1.getX();
        } else if (_c == 2) {
            return c2.getX();
        }
    }

    function getY(uint8 _c) external view returns (uint192) {
        if (_c > 2 || _c == 0) {
            revert MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1.getY();
        } else if (_c == 2) {
            return c2.getY();
        }
    }

    function getAutosome(uint8 _c) external view returns (uint256[37] memory) {
        if (_c > 2 || _c == 0) {
            revert MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1.getAutosomes();
        } else if (_c == 2) {
            return c2.getAutosomes();
        }
    }

    function getChromosme(uint8 _c) external view returns (Chromosome) {
        if (_c > 2 || _c == 0) {
            revert MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1;
        } else if (_c == 2) {
            return c2;
        }
    }
}

contract Chromosome {
    uint256[37] private autosomes;
    uint256[2] private x;
    uint192 private y;

    bool private isDNASet;

    function setDNA(uint256[37] memory _autosomes, uint256[2] memory _x, uint192 _y) external {
        // only set once
        if (isDNASet) {
            revert MetaPersona_NotMutable();
        }
        // either x is set or y is set
        if ((_y > 0 && (_x[0] > 0 || _x[1] > 0)) || ((_x[0] > 0 || _x[1] > 0) && _y > 0)) {
            revert MetaPersona_InvalidGeneticCombination();
        }

        for (uint256 i = 0; i < 37; i++) {
            autosomes[i] = _autosomes[i];
        }
        x[0] = _x[0];
        x[1] = _x[1];

        y = _y;

        isDNASet = true;
    }

    function getAutosomes() external view returns (uint256[37] memory) {
        return autosomes;
    }

    function getX() external view returns (uint256[2] memory) {
        return x;
    }

    function getY() external view returns (uint192) {
        return y;
    }

    function getGender() external view returns (Genetics.Gender) {
        if (y == 0 && (x[0] > 0 || x[1] > 0)) {
            return Genetics.Gender.Female;
        } else if (y > 0 && (x[0] == 0 && x[1] == 0)) {
            return Genetics.Gender.Male;
        } else {
            return Genetics.Gender.Undefined;
        }
    }
}
