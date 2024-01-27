using AutoMapper;
using MetaPersonaApi.Services.MetaPersona.DTOs;
using MetaPersonaApi.Services.MetaPersona.Genetics.Enums;
using MetaPersonaApi.Services.MetaPersona.SolidityStructs;
using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona.Genetics;

public class Meiosis
{
    public const int AUTOSOMECOUNT = 37;
    public const int XCOUNT = 2;
    public const int YCOUNT = 1;

    public static XorY IsXorY(ChromosomeDto chromosome)
    {
        if (chromosome == null)
        {
            return XorY.Undefined;
        }

        if (chromosome.Y.IsZero && (chromosome.X[0] > 0 || chromosome.X[1] > 0))
        {
            return XorY.X;
        }
        else if (chromosome.Y > 0 && (chromosome.X[0].IsZero && chromosome.X[1].IsZero))
        {
            return XorY.Y;
        }
        else
        {
            return XorY.Undefined;
        }
    }

    public static Gender GetGender(ChromosomeDto[] chromosomes)
    {
        XorY c1_XorY = IsXorY(chromosomes[0]);
        XorY c2_XorY = IsXorY(chromosomes[1]);

        if (c1_XorY == XorY.X && c2_XorY == XorY.X)
        {
            return Gender.Female;
        }
        else if (
            (c1_XorY == XorY.X && c2_XorY == XorY.Y)
                || (c1_XorY == XorY.Y && c2_XorY == XorY.X)
        )
        {
            return Gender.Male;
        }
        else
        {
            return Gender.Undefined;
        }
    }

    public static ChromosomeDto[] DoMeiosis(ChromosomeDto[] chromosomes, IMapper mapper)
    {
        var input1 = mapper.Map<ChromosomeDto[]>(chromosomes);
        var input2 = mapper.Map<ChromosomeDto[]>(chromosomes);

        Crossover(input1);
        Crossover(input2);

        return [.. input1, .. input2];
    }

    public static void Crossover(ChromosomeDto[] chromosomes)
    {
        Gender gender = GetGender(chromosomes);
        BigInteger y1 = chromosomes[0].Y;
        BigInteger y2 = chromosomes[1].Y;

        if (gender == Gender.Female)
        {
            DoFemaleCrossover(chromosomes[0].X, chromosomes[1].X);
            DoAutosomalCrossover(chromosomes[0].Autosomes, chromosomes[1].Autosomes);
        }
        else if (gender == Gender.Male)
        {
            DoMaleCrossover(chromosomes[0].X, ref y1, chromosomes[1].X, ref y2);
            DoAutosomalCrossover(chromosomes[0].Autosomes, chromosomes[1].Autosomes);

            chromosomes[0].Y = y1;
            chromosomes[1].Y = y2;
        }
        else
        {
            throw new Exception("Undefined gender.");
        }
    }

    public static void DoFemaleCrossover(BigInteger[] _x1, BigInteger[] _x2)
    {
        if (_x1.Length != 2 || _x2.Length != 2)
        {
            throw new ArgumentException("The length of input arrays are invalid.");
        }
        // swap 10 -> 20 bytes on each element of chromosomes
        RandomlySwapElements(_x1, _x2, 10, 20);
    }

    public static void DoMaleCrossover(BigInteger[] x1, ref BigInteger y1, BigInteger[] x2, ref BigInteger y2)
    {
        if (y1 > 0)
        {
            // Swap bytes for y1 and x2
            SwapXY(ref y1, ref x2[0], Utils.Random.RandBetween(3, 9), true);
            SwapXY(ref y1, ref x2[1], Utils.Random.RandBetween(3, 9), false);
        }

        if (y2 > 0)
        {
            // Swap bytes for y2 and x1
            SwapXY(ref y2, ref x1[0], Utils.Random.RandBetween(3, 9), true);
            SwapXY(ref y2, ref x1[1], Utils.Random.RandBetween(3, 9), false);
        }
    }

    public static void SwapXY(ref BigInteger y, ref BigInteger x, int numBytes, bool fromStart)
    {
        byte[] yBytes = y.ToByteArray();
        byte[] xBytes = x.ToByteArray();

        if (fromStart)
        {
            // Swap numBytes from the start
            for (int i = 0; i < numBytes; i++)
            {
                (xBytes[i], yBytes[i]) = (yBytes[i], xBytes[i]);
            }
        }
        else
        {
            // Swap numBytes from the end
            int yStartIndex = yBytes.Length - numBytes;
            int xStartIndex = xBytes.Length - numBytes;

            for (int i = 0; i < numBytes; i++)
            {
                (xBytes[xStartIndex + i], yBytes[yStartIndex + i]) = (yBytes[yStartIndex + i], xBytes[xStartIndex + i]);
            }
        }

        // Update the values
        y = new BigInteger(yBytes, true);
        x = new BigInteger(xBytes, true);
    }

    public static void DoAutosomalCrossover(BigInteger[] _auto1, BigInteger[] _auto2)
    {
        if (_auto1.Length != AUTOSOMECOUNT || _auto2.Length != AUTOSOMECOUNT)
        {
            throw new ArgumentException("The length of input arrays are invalid.");
        }
        // swap 8 -> 16 bytes on each element of chromosomes
        RandomlySwapElements(_auto1, _auto2, 8, 16);
    }

    public static void RandomlySwapElements(BigInteger[] _chr1, BigInteger[] _chr2, int minSwaps, int maxSwaps)
    {
        if (_chr1.Length != _chr2.Length)
        {
            throw new ArgumentException("Both arrays shall have the same length.");
        }

        if (minSwaps > maxSwaps)
        {
            throw new ArgumentException("maxSwaps shall be greater than or equal to minSwaps.");
        }

        HashSet<int> swappedIndices = [];

        for (int i = 0; i < _chr1.Length; i++)
        {
            int numSwaps = Utils.Random.RandBetween(minSwaps, maxSwaps);

            for (int j = 0; j < numSwaps; j++)
            {
                // Ensure unique start and endpoint pairs for swaps
                int byteIndex;
                do
                {
                    byteIndex = Utils.Random.RandBetween(0, _chr1[i].ToByteArray().Length - 1);
                } while (!swappedIndices.Add(byteIndex));

                ByteSwap(ref _chr1[i], ref _chr2[i], byteIndex);
            }

            // Clear indices for the next element
            swappedIndices.Clear();
        }
    }

    public static void ByteSwap(ref BigInteger num1, ref BigInteger num2, int index)
    {
        byte[] bytes1 = num1.ToByteArray();
        byte[] bytes2 = num2.ToByteArray();

        if (index >= 0 && index < bytes1.Length && index < bytes2.Length)
        {
            (bytes2[index], bytes1[index]) = (bytes1[index], bytes2[index]);

            num1 = new BigInteger(bytes1, true);
            num2 = new BigInteger(bytes2, true);
        }
    }
}
