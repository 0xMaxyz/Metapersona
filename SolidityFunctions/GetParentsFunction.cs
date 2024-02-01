using MetaPersona.SolidityDTOs;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using System.Numerics;

namespace MetaPersona.SolidityFunctions;

public partial class GetParentsFunction : GetParentsFunctionBase { }

[Function("getParents", typeof(GetParentsOutputDTO))]
public class GetParentsFunctionBase : FunctionMessage
{
    [Parameter("uint256", "_pid", 1)]
    public virtual BigInteger Pid { get; set; }
}
