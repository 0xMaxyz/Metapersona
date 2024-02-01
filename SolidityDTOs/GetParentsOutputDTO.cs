using Nethereum.ABI.FunctionEncoding.Attributes;
using System.Numerics;

namespace MetaPersona.SolidityDTOs;

public partial class GetParentsOutputDTO : GetParentsOutputDTOBase { }

[FunctionOutput]
public class GetParentsOutputDTOBase : IFunctionOutputDTO
{
    [Parameter("uint256", "", 1)]
    public virtual BigInteger Parent1 { get; set; }
    [Parameter("uint256", "", 2)]
    public virtual BigInteger Parent2 { get; set; }
}
