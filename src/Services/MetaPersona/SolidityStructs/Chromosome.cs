using Nethereum.ABI.FunctionEncoding.Attributes;
using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona.SolidityStructs;

public partial class Chromosome : ChromosomeBase { }

public class ChromosomeBase
{
    [Parameter("uint256[37]", "autosomes", 1)]
    public virtual BigInteger[] Autosomes { get; set; }
    [Parameter("uint256[2]", "x", 2)]
    public virtual BigInteger[] X { get; set; }
    [Parameter("uint192", "y", 3)]
    public virtual BigInteger Y { get; set; }
}
