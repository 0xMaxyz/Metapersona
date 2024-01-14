// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

error MetaPersona_InvalidGeneticalDataInput(string genes);
error MetaPersona_InvalidInputString();
error MetaPersona_InvalidInputCharacter();
error MetaPersona_InvalidFunctionArgs();
error MetaPersona_InvalidHexChar();
error MetaPersona_InvalidInputGeneticData();
error MetaPersona_PersonaNotFound();
error MetaPersona_PersonaNotOwnedByYou();
error MetaPersona_WrongGender();
error MetaPersona_IncompatiblePersonas();
error MetaPersona_InvalidInput();
error MetaPersona_MaxCrossoversReached();
error MetaPersona_NotMutable();
error MetaPersona_InvalidChromosome();
error MetaPersona_InvalidGeneticCombination();

library Random {
    struct RandomArgs {
        uint256 Prevrandao;
        uint256 Timestamp;
        address Sender;
    }

    function random(uint256 _seed, RandomArgs calldata _args) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_args.Prevrandao, _args.Timestamp, _args.Sender, _seed)));
    }

    function randomBetween(uint256 _min, uint256 _max, uint256 _seed, RandomArgs calldata _args)
        public
        pure
        returns (uint256)
    {
        if (_min >= _max) {
            revert MetaPersona_InvalidInput();
        }

        uint256 rand = random(_seed, _args);

        return (rand % (_max - _min + 1)) + _min;
    }
}

library Genetics {
    struct Chromosome {
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

    function getGender(Genetics.Chromosome[2] calldata _chr) public pure returns (Genetics.Gender) {
        Genetics.XorY c1_XorY = isXorY(_chr[0]);
        Genetics.XorY c2_XorY = isXorY(_chr[1]);

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

    function isXorY(Genetics.Chromosome calldata _chr) public pure returns (Genetics.XorY) {
        if (_chr.y == 0 && (_chr.x[0] > 0 || _chr.x[1] > 0)) {
            return Genetics.XorY.X;
        } else if (_chr.y > 0 && (_chr.x[0] == 0 && _chr.x[1] == 0)) {
            return Genetics.XorY.Y;
        } else {
            return Genetics.XorY.Undefined;
        }
    }
}

library ChromosomeLib {
    function crossover(Genetics.Chromosome[2] calldata _chr, uint256 seed, Random.RandomArgs calldata _args)
        public
        pure
        returns (Genetics.Chromosome memory, Genetics.Chromosome memory, uint256)
    {
        uint256 rand;
        Genetics.Chromosome memory cs_1;
        Genetics.Chromosome memory cs_2;

        Genetics.Gender gender = Genetics.getGender(_chr);

        if (gender == Genetics.Gender.Female) {
            (cs_1.x, cs_2.x, rand) = doFemaleCrossover(_chr[0].x, _chr[1].x, seed, _args);
            (cs_1.autosomes, cs_2.autosomes, rand) =
                doAutosomalCrossover(_chr[0].autosomes, _chr[1].autosomes, rand, _args);
        } else if (gender == Genetics.Gender.Male) {
            (cs_1.x, cs_1.y, cs_2.x, cs_2.y, rand) =
                doMaleCrossover(_chr[0].x, _chr[0].y, _chr[1].x, _chr[1].y, seed, _args);
            (cs_1.autosomes, cs_2.autosomes, rand) =
                doAutosomalCrossover(_chr[0].autosomes, _chr[1].autosomes, rand, _args);
        } else {
            revert MetaPersona_InvalidGeneticCombination();
        }

        return (cs_1, cs_2, rand);
    }

    function meiosis(Genetics.Chromosome[2] calldata _chr, uint256 seed, Random.RandomArgs calldata _args)
        external
        pure
        returns (Genetics.Chromosome[4] memory, uint256)
    {
        uint256 rand;
        Genetics.Chromosome memory cs_1;
        Genetics.Chromosome memory cs_2;
        Genetics.Chromosome memory cs_3;
        Genetics.Chromosome memory cs_4;

        (cs_1, cs_2, rand) = crossover(_chr, seed, _args);
        (cs_3, cs_4, rand) = crossover(_chr, rand, _args);

        return ([cs_1, cs_2, cs_3, cs_4], rand);
    }

    function doMaleCrossover(
        uint256[2] calldata x1,
        uint192 y1,
        uint256[2] calldata x2,
        uint192 y2,
        uint256 seed,
        Random.RandomArgs calldata _args
    ) private pure returns (uint256[2] memory _x1, uint192 _y1, uint256[2] memory _x2, uint192 _y2, uint256) {
        uint256[2] memory iX;
        uint192 iY;

        if (y1 == 0) {
            // then the first one has x, second one has y
            iX[0] = x1[0];
            iX[1] = x1[1];
            iY = y2;
        } else {
            // first one has y, second one has x
            iX[0] = x2[0];
            iX[1] = x2[1];
            iY = y1;
        }
        // do the crossover
        // get a random number between 3 and 8
        uint256 numByte = Random.randomBetween(3, 8, seed, _args);

        // swap the sections
        iX[0] = (iX[0] & (type(uint256).max << (numByte * 8)))
            | ((iY << uint8(192 - numByte * 8)) >> uint8(192 - numByte * 8));
        iX[1] = (iX[1] & (type(uint256).max >> (numByte * 8)))
            | ((iY >> uint8(192 - numByte * 8)) << uint8(256 - numByte * 8));

        iY = (iY & (type(uint192).max << uint192(numByte * 8)))
            | uint192((iX[0] << uint8(256 - numByte * 8)) >> uint8(256 - numByte * 8));
        iY = (iY & (type(uint192).max >> uint192(numByte * 8)))
            | (uint192(iX[1] >> uint8(192 - numByte * 8)) << uint8(192 - numByte * 8));

        uint256[2] memory emptyX;

        if (y1 == 0) {
            return (iX, uint192(0), emptyX, iY, numByte);
        } else {
            return (emptyX, iY, iX, uint192(0), numByte);
        }
    }

    function doAutosomalCrossover(
        uint256[37] calldata auto1,
        uint256[37] calldata auto2,
        uint256 _seed,
        Random.RandomArgs calldata _args
    ) private pure returns (uint256[37] memory, uint256[37] memory, uint256) {
        (uint8[] memory indices, uint256 rand) = beforeCrossover(_seed, 10, _args);

        uint256[37] memory m_auto1;
        uint256[37] memory m_auto2;

        for (uint256 i = 0; i < 37; i++) {
            m_auto1[i] = auto1[i];
            m_auto2[i] = auto2[i];
        }

        for (uint256 i = 0; i < indices.length; i++) {
            uint256 index = indices[i];

            (m_auto1[index], m_auto2[index]) = (m_auto2[index], m_auto1[index]);
        }

        return (m_auto1, m_auto2, rand);
    }

    function doFemaleCrossover(
        uint256[2] calldata chr1_x,
        uint256[2] calldata chr2_x,
        uint256 seed,
        Random.RandomArgs calldata _args
    ) private pure returns (uint256[2] memory, uint256[2] memory, uint256) {
        uint256 rand;
        // 3 to 8 times on each array
        rand = Random.randomBetween(3, 8, seed, _args);
        uint8 numXCrossovers = uint8(rand);
        uint8[] memory xCrossovers = new uint8[](numXCrossovers);
        (xCrossovers, rand) = getXXCrossoverBytes(numXCrossovers, rand, _args);

        // Do the crossover on x[0]
        (uint256 chr1_xc0, uint256 chr2_xc0) = doXCrossover(chr1_x[0], chr2_x[0], xCrossovers);
        //
        rand = Random.randomBetween(3, 8, rand, _args);
        numXCrossovers = uint8(rand);
        xCrossovers = new uint8[](numXCrossovers);
        (xCrossovers, rand) = getXXCrossoverBytes(numXCrossovers, rand, _args);

        // Do the crossover on x[1]
        (uint256 chr1_xc1, uint256 chr2_xc1) = doXCrossover(chr1_x[1], chr2_x[1], xCrossovers);

        return ([chr1_xc0, chr1_xc1], [chr2_xc0, chr2_xc1], rand);
    }

    function getXXCrossoverBytes(uint8 _count, uint256 _seed, Random.RandomArgs calldata _args)
        private
        pure
        returns (uint8[] memory, uint256)
    {
        if (_count > 16) {
            revert MetaPersona_InvalidFunctionArgs();
        }
        uint256 rand;
        uint8[16] memory numbers = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32];

        for (uint8 i = 15; i > 0; i--) {
            rand = Random.random(_seed, _args);
            uint256 j = rand % (i + 1);
            (numbers[i], numbers[j]) = (numbers[j], numbers[i]);
        }

        uint8[] memory result = new uint8[](_count);
        for (uint8 i = 0; i < _count; i++) {
            result[i] = numbers[i];
        }

        return (result, rand);
    }

    function doXCrossover(uint256 _x1, uint256 _x2, uint8[] memory _crossoverIndices)
        private
        pure
        returns (uint256 _xc1, uint256 _xc2)
    {
        uint256 mask;
        for (uint256 i = 0; i < _crossoverIndices.length; i++) {
            mask = mask | (1 << _crossoverIndices[i]);
        }

        _xc1 = (_x1 & ~mask) | (_x2 & mask);
        _xc2 = (_x2 & ~mask) | (_x1 & mask);

        return (_xc1, _xc2);
    }

    function beforeCrossover(uint256 _seed, uint8 _maxCrossovers, Random.RandomArgs calldata _args)
        private
        pure
        returns (uint8[] memory, uint256)
    {
        if (_maxCrossovers > 20) {
            revert MetaPersona_MaxCrossoversReached();
        }

        bool[256] memory uniqueValues;

        uint8 maxVal = 37;
        uint8 uniqueValueCount;
        uint8 byteShiftIndex;

        uint256 rand;

        rand = Random.random(_seed, _args);

        uint8 coIndex;
        while (coIndex < 4) {
            coIndex = uint8(((rand >> (byteShiftIndex * 8)) & 0xFF) % _maxCrossovers);
            byteShiftIndex++;
        }

        byteShiftIndex = 0;

        uint8[] memory val = new uint8[](coIndex);

        while (uniqueValueCount < coIndex) {
            rand = Random.random(rand, _args);
            uint8 uniqueValue = uint8(rand % maxVal);
            if (uniqueValues[uniqueValue]) {
                byteShiftIndex++;
                continue;
            }
            val[uniqueValueCount++] = uniqueValue;
            uniqueValues[uniqueValue] = true;
            byteShiftIndex++;
        }

        return (val, rand);
    }

    // function getUint256Max() private pure returns (uint256) {
    //     return ~uint256(0);
    // }

    // function getUint192Max() private pure returns (uint192) {
    //     return ~uint192(0);
    // }
}
