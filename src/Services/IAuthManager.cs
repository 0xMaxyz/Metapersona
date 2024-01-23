using MetaPersonaApi.Data.DTOs;

namespace MetaPersonaApi.Services;

public interface IAuthManager
{
    Task<AuthResponseDto> Login(LoginDto loginDto);
}
