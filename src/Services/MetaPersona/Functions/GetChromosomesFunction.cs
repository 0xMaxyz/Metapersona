using MetaPersonaApi.Services.MetaPersona.DTOs;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona.Functions;

public partial class GetChromosomesFunction : GetChromosomesFunctionBase { }

[Function("getChromosomesN", typeof(GetChromosomesOutputDTO))]
public class GetChromosomesFunctionBase : FunctionMessage
{
    [Parameter("address", "_owner", 1)]
    public virtual string Owner { get; set; }
    [Parameter("uint256", "_personaId", 2)]
    public virtual BigInteger PersonaId { get; set; }
}


