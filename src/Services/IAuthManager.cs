using MetaPersonaApi.Data.DTOs;
using Microsoft.AspNetCore.Identity;

namespace MetaPersonaApi.Services;

public interface IAuthManager
{
    Task<AuthResponseDto> Login(LoginDto loginDto);
    Task<IEnumerable<IdentityError>> Register(RegisterDto registerDto);
}
