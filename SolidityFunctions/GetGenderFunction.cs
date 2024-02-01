using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;

namespace MetaPersona.SolidityFunctions;

public partial class GetGenderFunction : GetGenderFunctionBase { }

[Function("getGender", "uint8")]
public class GetGenderFunctionBase : FunctionMessage
{
    [Parameter("uint256", "_pId", 1)]
    public virtual BigInteger PId { get; set; }
}
