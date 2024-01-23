using System.Text.RegularExpressions;

namespace MetaPersonaApi.Utils;

public static class Web3
{
    public static bool IsValidAddress(this string address)
    {
        return Regex.Match(address, @"^(?:0x)?[a-fA-F0-9]{40}$", RegexOptions.IgnoreCase).Success;
    }
}
