using AutoMapper;
using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Services.MetaPersona.DTOs;
using MetaPersonaApi.Services.MetaPersona.SolidityStructs;
using Microsoft.AspNetCore.Identity;

namespace MetaPersonaApi.Mappings;

public class Mappings: Profile
{
    public Mappings()
    {
        CreateMap<IdentityRole<Guid>,RoleDto>(MemberList.Destination);
        CreateMap<Chromosome,ChromosomeDto>().ReverseMap();
        CreateMap<ChromosomeDto, ChromosomeDto>();
    }
}
