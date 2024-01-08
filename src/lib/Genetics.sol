// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Structs.sol";
import "./Errors.sol";
import "./Helpers.sol";
import "./Chromosome.sol";

library Genetics {
    enum Gender {
        Undefined,
        Female,
        Male
    }

    uint256 public constant C_X_36_MASK = 0xffffffffffffffffffffffffffffffffffffffffffff00000000000000000000;

    uint256 public constant C_Y_38_MASK = 0xffffffffffffffffffffffffffffffffffffffffffffff000000000000000000;

    //uint256 public constant CROSSOVERS = 0x030405060708090a0b0c0d0e0f101112; // abi.encodePacked(arg) => [ 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
    uint256 public constant CROSSOVERS = 0x030405060708090a; // abi.encodePacked(arg) => [ 3, 4, 5, 6, 7, 8, 9, 10]

    function getCrossover(uint8 index) public pure returns (uint8) {
        require(index < 16, "Index out of bounds");
        uint8 startBit = 8 * (15 - index);
        return uint8((CROSSOVERS >> startBit) & 0xFF);
    }

    function hasX(Structs.Chromosome memory _chromosome) public view returns (bool) {
        bool X36 = _chromosome.DNA[36] & C_X_36_MASK > 0;
        bool X37 = _chromosome.DNA[37] > 0;
        bool X38 = _chromosome.DNA[38] & (~C_Y_38_MASK) > 0;

        return X36 || X37 || X38;
    }

    function hasXN(Chromosome _chr) public view returns (bool) {
        uint256[39] memory dna = _chr.getDNA();

        bool X36 = dna[36] & C_X_36_MASK > 0;
        bool X37 = dna[37] > 0;
        bool X38 = dna[38] & (~C_Y_38_MASK) > 0;

        return X36 || X37 || X38;
    }

    function hasY(Structs.Chromosome memory _chromosome) public view returns (bool) {
        return _chromosome.DNA[38] & C_Y_38_MASK > 0;
    }

    function hasYN(Chromosome _chr) public view returns (bool) {
        uint256[39] memory dna = _chr.getDNA();

        return dna[38] & C_Y_38_MASK > 0;
    }

    function isXX(Structs.Chromosomes memory _chromosomes) external view returns (bool) {
        bool ch1HasX = hasX(_chromosomes.chromosome[0]);
        bool ch2HasX = hasX(_chromosomes.chromosome[1]);

        bool ch1HasY = hasY(_chromosomes.chromosome[0]);
        bool ch2HasY = hasY(_chromosomes.chromosome[1]);

        return ch1HasX && ch2HasX && !(ch1HasY || ch2HasY);
    }

    function isXXN(Chromosomes _chr) external view returns (bool) {
        Chromosome c1 = _chr.getChromosome(1);
        Chromosome c2 = _chr.getChromosome(2);

        bool ch1HasX = hasXN(c1);
        bool ch2HasX = hasXN(c2);

        bool ch1HasY = hasYN(c1);
        bool ch2HasY = hasYN(c2);

        return ch1HasX && ch2HasX && !(ch1HasY || ch2HasY);
    }

    function isXY(Structs.Chromosomes memory _chromosomes) external view returns (bool _isXY) {
        bool ch1HasX = hasX(_chromosomes.chromosome[0]);
        bool ch2HasX = hasX(_chromosomes.chromosome[1]);

        bool ch1HasY = hasY(_chromosomes.chromosome[0]);
        bool ch2HasY = hasY(_chromosomes.chromosome[1]);

        _isXY = ch1HasX ? !ch1HasY && ch2HasY && !ch2HasX : ch1HasY && !ch2HasY && ch2HasX;
    }

    function isXYN(Chromosomes _chr) external view returns (bool _isXY) {
        Chromosome c1 = _chr.getChromosome(1);
        Chromosome c2 = _chr.getChromosome(2);

        bool ch1HasX = hasXN(c1);
        bool ch2HasX = hasXN(c2);

        bool ch1HasY = hasYN(c1);
        bool ch2HasY = hasYN(c2);

        _isXY = ch1HasX ? !ch1HasY && ch2HasY && !ch2HasX : ch1HasY && !ch2HasY && ch2HasX;
    }

    function meiosis(uint256[39] memory c1, uint256[39] memory c2, uint256 seed)
        external
        returns (uint256[39] memory, uint256[39] memory, uint256[39] memory, uint256[39] memory)
    {
        return crossover(c1, c2, seed);
    }

    function meiosisG(uint256[39] memory c1, uint256[39] memory c2, uint256 seed)
        external
        returns (uint256[39][4] memory)
    {
        (uint256[39] memory c11, uint256[39] memory c12, uint256[39] memory c21, uint256[39] memory c22) =
            crossover(c1, c2, seed);
        uint256[39][4] memory gamets;
        for (uint8 i = 0; i < 39; i++) {
            gamets[0][i] = c11[i];
            gamets[1][i] = c12[i];
            gamets[2][i] = c21[i];
            gamets[3][i] = c22[i];
        }

        return gamets;
    }

    function crossover(uint256[39] memory c1, uint256[39] memory c2, uint256 seed)
        private
        returns (uint256[39] memory, uint256[39] memory, uint256[39] memory, uint256[39] memory)
    {
        (uint8[] memory co, uint8 coCount) = beforeCrossover(seed);

        for (uint8 i = 0; i < coCount; i++) {
            uint256 temp = c1[co[i]];
            c1[co[i]] = c2[co[i]];
            c2[co[i]] = temp;
        }

        return (c1, c1, c2, c2);
    }

    function beforeCrossover(uint256 seed) private returns (uint8[] memory, uint8) {
        uint8[38] memory uniqueValues;

        uint8 uniqueValueCount;
        uint8 byteShiftIndex;

        seed = Helpers.random(seed);
        uint8 coIndex = uint8(seed % 8);

        uint8[] memory val = new uint8[](coIndex);

        while (uniqueValueCount < coIndex) {
            uint8 uniqueValue = uint8((seed >> (byteShiftIndex * 2)) & 0xFF);
            if (uniqueValue >= 38 || uniqueValues[uniqueValue] == 1) {
                byteShiftIndex++;
                continue;
            }
            val[uniqueValueCount] = uniqueValue;
            uniqueValues[uniqueValue] = 1;
            uniqueValueCount++;
            byteShiftIndex++;
        }

        return (val, coIndex);
    }
}
