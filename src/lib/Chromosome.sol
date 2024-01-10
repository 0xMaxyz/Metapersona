// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Constants.sol";
import "./Helpers.sol";
import "./Errors.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

library Genetics {
    struct ChromosomeStructure {
        uint256[37] autosomes;
        uint256[2] x;
        uint192 y;
    }

    enum Gender {
        Undefined,
        Female,
        Male
    }

    enum XorY {
        Undefined,
        X,
        Y
    }

    function meiosis(Chromosomes _chr, uint256 seed) external returns (ChromosomeStructure[4] memory) {
        ChromosomeStructure memory cs_1;
        ChromosomeStructure memory cs_2;
        ChromosomeStructure memory cs_3;
        ChromosomeStructure memory cs_4;

        Chromosome instance = _chr.getChromosme(1);

        (cs_1, cs_2) = instance.crossover(_chr, seed);
        (cs_3, cs_4) = instance.crossover(_chr, seed);

        return [cs_1, cs_2, cs_3, cs_4];
    }
}

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
            revert Errors.MetaPersona_InvalidGeneticCombination();
        }

        c1.setDNA(_autosomes1, _x1, _y1);
        c2.setDNA(_autosomes2, _x2, _y2);
    }

    function getX(uint8 _c) external view returns (uint256[2] memory) {
        if (_c > 2 || _c == 0) {
            revert Errors.MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1.getX();
        } else if (_c == 2) {
            return c2.getX();
        }
    }

    function getY(uint8 _c) external view returns (uint192) {
        if (_c > 2 || _c == 0) {
            revert Errors.MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1.getY();
        } else if (_c == 2) {
            return c2.getY();
        }
    }

    function getAutosome(uint8 _c) external view returns (uint256[37] memory) {
        if (_c > 2 || _c == 0) {
            revert Errors.MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1.getAutosomes();
        } else if (_c == 2) {
            return c2.getAutosomes();
        }
    }

    function getChromosme(uint8 _c) external view returns (Chromosome) {
        if (_c > 2 || _c == 0) {
            revert Errors.MetaPersona_InvalidChromosome();
        }

        if (_c == 1) {
            return c1;
        } else if (_c == 2) {
            return c2;
        }
    }

    function getGender() public view returns (Genetics.Gender) {
        Genetics.XorY c1_XorY = c1.isXorY();
        Genetics.XorY c2_XorY = c2.isXorY();

        if (c1_XorY == Genetics.XorY.X && c2_XorY == Genetics.XorY.X) {
            return Genetics.Gender.Female;
        } else if (
            (c1_XorY == Genetics.XorY.X && c2_XorY == Genetics.XorY.Y)
                || (c1_XorY == Genetics.XorY.Y && c2_XorY == Genetics.XorY.X)
        ) {
            return Genetics.Gender.Male;
        } else {
            return Genetics.Gender.Undefined;
        }
    }
}

contract Chromosome {
    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap private uniqueValues;

    uint256[37] private autosomes;
    uint256[2] private x;
    uint192 private y;

    bool private isDNASet;

    function setDNA(uint256[37] memory _autosomes, uint256[2] memory _x, uint192 _y) external {
        // only set once
        if (isDNASet) {
            revert Errors.MetaPersona_NotMutable();
        }
        // either x is set or y is set
        if ((_y > 0 && (_x[0] > 0 || _x[1] > 0)) || ((_x[0] > 0 || _x[1] > 0) && _y > 0)) {
            revert Errors.MetaPersona_InvalidGeneticCombination();
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

    function isXorY() public view returns (Genetics.XorY) {
        if (y == 0 && (x[0] > 0 || x[1] > 0)) {
            return Genetics.XorY.X;
        } else if (y > 0 && (x[0] == 0 && x[1] == 0)) {
            return Genetics.XorY.Y;
        } else {
            return Genetics.XorY.Undefined;
        }
    }

    function crossover(Chromosomes _chr, uint256 seed)
        public
        returns (Genetics.ChromosomeStructure memory, Genetics.ChromosomeStructure memory)
    {
        Genetics.ChromosomeStructure memory cs_1;
        Genetics.ChromosomeStructure memory cs_2;

        Genetics.Gender gender = _chr.getGender();

        if (gender == Genetics.Gender.Female) {
            (cs_1.x, cs_2.x) = doFemaleCrossover(_chr.getChromosme(1).getX(), _chr.getChromosme(2).getX(), seed);
            (cs_1.autosomes, cs_2.autosomes) = doAutosomalCrossover(_chr, seed);

            return (cs_1, cs_2);
        } else if (gender == Genetics.Gender.Male) {
            (cs_1.x, cs_1.y, cs_2.x, cs_2.y) = doMaleCrossover(_chr, seed);
            (cs_1.autosomes, cs_2.autosomes) = doAutosomalCrossover(_chr, seed);
        }
    }

    function doFemaleCrossover(uint256[2] memory chr1_x, uint256[2] memory chr2_x, uint256 seed)
        private
        returns (uint256[2] memory, uint256[2] memory)
    {
        // 3 to 8 times on each array
        seed = Helpers.randomBetween(seed, 3, 8);
        uint8 numXCrossovers = uint8(seed);
        uint8[] memory xCrossovers = new uint8[](numXCrossovers);
        xCrossovers = getXXCrossoverBytes(numXCrossovers, seed);

        // Do the crossover on x[0]
        (uint256 chr1_xc0, uint256 chr2_xc0) = doXCrossover(chr1_x[0], chr2_x[0], xCrossovers);
        //
        seed = Helpers.randomBetween(seed, 3, 8);
        numXCrossovers = uint8(seed);
        xCrossovers = new uint8[](numXCrossovers);
        xCrossovers = getXXCrossoverBytes(numXCrossovers, seed);

        // Do the crossover on x[1]
        (uint256 chr1_xc1, uint256 chr2_xc1) = doXCrossover(chr1_x[1], chr2_x[1], xCrossovers);

        return ([chr1_xc0, chr1_xc1], [chr2_xc0, chr2_xc1]);
    }

    function doMaleCrossover(Chromosomes _chr, uint256 seed)
        private
        returns (uint256[2] memory _x1, uint192 _y1, uint256[2] memory _x2, uint192 _y2)
    {
        // crossover happens only for n first byte and n last bytes of x and y
        uint8 indexOfX; // 1 0r 2
        uint8 indexOfY; // 1 0r 2

        // find which chromosome is X and which one is Y
        if (_chr.getY(1) == 0) {
            // then the first one has x, second one has y
            indexOfX = 1;
            indexOfY = 2;
        } else {
            // first one has y, second one has x

            indexOfX = 2;
            indexOfY = 1;
        }
        // do the crossover
        // get a random number between 1 and 5
        seed = Helpers.randomBetween(seed, 3, 8);
        uint256 numByte = seed;

        uint256[2] memory iX = _chr.getChromosme(indexOfX).getX();
        uint192 iY = _chr.getChromosme(indexOfY).getY();

        // exctract the first/last n byte of X and Y
        uint8 xShiftLength = uint8(256 - numByte * 8);
        uint8 yShiftLength = uint8(192 - numByte * 8);

        uint256 firstNbyteX = (iX[0] << xShiftLength) >> xShiftLength;
        uint256 lastNbyteX = iX[1] >> xShiftLength;
        uint256 firstNbyteY = (iY << yShiftLength) >> yShiftLength;
        uint256 lastNbyteY = iY >> yShiftLength;

        // swap the sections
        iX[0] = (iX[0] & (Constants.UI256MAX << (numByte * 8))) | firstNbyteY;
        iX[1] = (iX[1] & (Constants.UI256MAX >> (numByte * 8))) | (lastNbyteY << xShiftLength);

        iY = (iY & (Constants.UI192MAX << uint192(numByte * 8))) | uint192(firstNbyteX);
        iY = (iY & (Constants.UI192MAX >> uint192(numByte * 8))) | (uint192(lastNbyteX) << yShiftLength);

        uint256[2] memory emptyX;

        if (indexOfX == 1) {
            return (iX, uint192(0), emptyX, iY);
        } else {
            return (emptyX, iY, iX, uint192(0));
        }
    }

    function doAutosomalCrossover(Chromosomes _chr, uint256 seed)
        private
        returns (uint256[37] memory, uint256[37] memory)
    {
        uint8[] memory indices = beforeCrossover(seed, 10);

        uint256[37] memory auto1 = _chr.getAutosome(1);
        uint256[37] memory auto2 = _chr.getAutosome(2);

        for (uint256 i = 0; i < indices.length; i++) {
            uint256 index = indices[i];

            (auto1[index], auto2[index]) = (auto2[index], auto1[index]);
        }

        return (auto1, auto2);
    }

    function doXCrossover(uint256 _x1, uint256 _x2, uint8[] memory _crossoverIndexes)
        private
        returns (uint256 _xc1, uint256 _xc2)
    {
        uint256 mask;
        for (uint256 i = 0; i < _crossoverIndexes.length; i++) {
            mask = mask | (1 << _crossoverIndexes[i]);
        }

        _xc1 = (_x1 & ~mask) | (_x2 & mask);
        _xc2 = (_x2 & ~mask) | (_x1 & mask);

        return (_xc1, _xc2);
    }

    function getXXCrossoverBytes(uint8 _count, uint256 _seed) private returns (uint8[] memory) {
        if (_count > 16) {
            revert Errors.MetaPersona_InvalidFunctionArgs();
        }
        uint8[16] memory numbers = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32];

        for (uint8 i = 15; i > 0; i--) {
            _seed = Helpers.random(_seed);
            uint256 j = _seed % (i + 1);
            (numbers[i], numbers[j]) = (numbers[j], numbers[i]);
        }

        uint8[] memory result = new uint8[](_count);
        for (uint8 i = 0; i < _count; i++) {
            result[i] = numbers[i];
        }

        return result;
    }

    function beforeCrossover(uint256 _seed, uint8 _maxCrossovers) private returns (uint8[] memory) {
        if (_maxCrossovers > 20) {
            revert Errors.MetaPersona_MaxCrossoversReached();
        }

        delete uniqueValues;

        uint8 maxVal = 37;
        uint8 uniqueValueCount;
        uint8 byteShiftIndex;

        _seed = Helpers.random(_seed);

        uint8 coIndex;
        while (coIndex < 4) {
            coIndex = uint8(((_seed >> (byteShiftIndex * 8)) & 0xFF) % _maxCrossovers);
            byteShiftIndex++;
        }

        byteShiftIndex = 0;

        uint8[] memory val = new uint8[](coIndex);

        while (uniqueValueCount < coIndex) {
            _seed = Helpers.random(_seed);
            uint8 uniqueValue = uint8(_seed % maxVal);
            if (uniqueValues.get(uniqueValue)) {
                byteShiftIndex++;
                continue;
            }
            val[uniqueValueCount++] = uniqueValue;
            uniqueValues.set(uniqueValue);
            byteShiftIndex++;
        }

        return val;
    }
}
