using MetaPersonaApi.Data.DTOs;
using Microsoft.AspNetCore.Identity;

namespace MetaPersonaApi.Services.Authentication;

public interface IAuthManager
{
    Task<AuthResponseDto> Login(LoginDto loginDto);
    Task<IEnumerable<IdentityError>> Register(RegisterDto registerDto);
    Task<List<RoleDto>> GetRoles(CancellationToken cancellationToken = default);
    Task<ErrorResponseDto?> AddUserRoleAsync(UserRoleDto userRoleDto, CancellationToken cancellationToken = default);
}
