using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;

namespace MetaPersona.SolidityFunctions;

public partial class GetPersonasFunction : GetPersonasFunctionBase { }

[Function("getPersonas", "uint256[]")]
public class GetPersonasFunctionBase : FunctionMessage
{

}
