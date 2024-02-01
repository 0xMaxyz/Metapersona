using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using System.Numerics;

namespace MetaPersona.SolidityFunctions;

public partial class GetChildrenFunction : GetChildrenFunctionBase { }

[Function("getChildren", "uint256[]")]
public class GetChildrenFunctionBase : FunctionMessage
{
    [Parameter("uint256", "_pid1", 1)]
    public virtual BigInteger Pid1 { get; set; }
    [Parameter("uint256", "_pid2", 2)]
    public virtual BigInteger Pid2 { get; set; }
}
