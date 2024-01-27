using System.Security.Cryptography;

namespace MetaPersonaApi.Services.MetaPersona.Genetics.Utils;

public class Random
{

    public static int Rand()
    {
        return Math.Abs(BitConverter.ToInt32(RandomNumberGenerator.GetBytes(4), 0));
    }

    public static int RandBetween(int min, int max)
    {
        if (min > max)
        {
            throw new ArgumentException("min must be less than or equal to max.");
        }

        return min + Rand() % (max - min + 1);
    }
}
