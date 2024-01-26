using MetaPersonaApi.Services.MetaPersona.SolidityStructs;
using Nethereum.ABI.FunctionEncoding.Attributes;

namespace MetaPersonaApi.Services.MetaPersona.DTOs;

public partial class GetChromosomesOutputDTO : GetChromosomesOutputDTOBase { }

[FunctionOutput]
public class GetChromosomesOutputDTOBase : IFunctionOutputDTO
{
    [Parameter("tuple[2]", "", 1)]
    public virtual List<Chromosome> Chromosomes { get; set; }
}
