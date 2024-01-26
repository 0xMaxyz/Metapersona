using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona.DTOs;

public class ChromosomeDto
{
    public BigInteger[] Autosomes { get; set; }
    public BigInteger[] X { get; set; }
    public BigInteger Y { get; set; }
}
