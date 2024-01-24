using AutoMapper;
using MetaPersonaApi.Data.DTOs;
using Microsoft.AspNetCore.Identity;

namespace MetaPersonaApi.Mappings;

public class Mappings: Profile
{
    public Mappings()
    {
        CreateMap<IdentityRole<Guid>,RoleDto>(MemberList.Destination);
    }
}
