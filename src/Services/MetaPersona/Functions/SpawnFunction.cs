using MetaPersonaApi.Services.MetaPersona.SolidityStructs;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona.Functions;

public partial class SpawnFunction : SpawnFunctionBase { }

[Function("spawn", "uint256")]
public class SpawnFunctionBase : FunctionMessage
{
    [Parameter("uint256", "_personaId1", 1)]
    public virtual BigInteger PersonaId1 { get; set; }
    [Parameter("uint256", "_personaId2", 2)]
    public virtual BigInteger PersonaId2 { get; set; }
    [Parameter("address", "_personaOwner1", 3)]
    public virtual string PersonaOwner1 { get; set; }
    [Parameter("address", "_personaOwner2", 4)]
    public virtual string PersonaOwner2 { get; set; }
    [Parameter("address", "_receiver", 5)]
    public virtual string Receiver { get; set; }
    [Parameter("tuple[2]", "_chr", 6)]
    public virtual List<Chromosome> Chromosomes { get; set; }
}
