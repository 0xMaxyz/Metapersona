using System.Security.Cryptography;

namespace MetaPersonaApi.Services.MetaPersona.Genetics.Utils;

public class Random
{
    public static ulong Rand()
    {
        return BitConverter.ToUInt64(RandomNumberGenerator.GetBytes(8), 0);
    }

    public static ulong RandBetween(uint min, uint max)
    {
        if (min > max)
        {
            throw new ArgumentException("min must be less than or equal to max.");
        }

        return min + Rand() % (max - min + 1);
    }
}
