namespace System.MetaPersona;

public static class SystemExtensions
{
    public static string FirstCharToUpper(this string input) =>
        input switch
        {
            null => throw new ArgumentNullException(nameof(input)),
            "" => throw new ArgumentException($"{nameof(input)} cannot be empty", nameof(input)),
            _ => string.Concat(input[0].ToString().ToUpper(), input.AsSpan(1).ToString().ToLower())
        };
    public static string? UNormalize(this string? s)
    {
        return s?.Trim().ToUpperInvariant().Normalize();
    }
}