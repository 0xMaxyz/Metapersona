using AutoMapper;
using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Identity;
using MetaPersonaApi.Utils;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.MetaPersona;
using System.Security.Claims;
using System.Text;
namespace MetaPersonaApi.Services.Authentication;

public class AuthManager(UserManager<MetaPersonaIdentityUser> userManager, RoleManager<IdentityRole<Guid>> roleManager, IConfiguration configuration, IMapper mapper) : IAuthManager
{
    private readonly UserManager<MetaPersonaIdentityUser> _userManager = userManager;
    private readonly RoleManager<IdentityRole<Guid>> _roleManager = roleManager;
    private readonly IConfiguration _configuration = configuration;
    private readonly IMapper _mapper = mapper;

    public async Task<AuthResponseDto> Login(LoginDto loginDto)
    {
        var user = await _userManager.FindByEmailAsync(loginDto.UserName);
        if (user == null)
        {
            return default;
        }
        var isPasswordValid = await _userManager.CheckPasswordAsync(user, loginDto.Password);
        if (!isPasswordValid)
        {
            return default;
        }

        var token = await GenerateTokenAsync(user);

        return new AuthResponseDto
        {
            Token = token,
            UserId = user.Id.ToString(),
        };
    }

    public async Task<IEnumerable<IdentityError>> Register(RegisterDto registerDto)
    {
        var validEmail = registerDto.Email.IsValidEmail();
        if (!validEmail)
        {
            return [new IdentityError { Code = "E01", Description = "Use valid email." }];
        }
        var normEmail = registerDto.Email.UNormalize();
        var checkEmail = await _userManager.Users.AnyAsync(x => x.NormalizedEmail == normEmail);
        if (checkEmail)
        {
            return [new IdentityError { Code = "E02", Description = "Already registered." }];
        }
        var newUser = new MetaPersonaIdentityUser
        {
            Email = registerDto.Email,
            UserName = registerDto.Email
        };

        var result = await _userManager.CreateAsync(newUser, registerDto.Password);

        return result.Errors;
    }

    public async Task<List<RoleDto>> GetRoles(CancellationToken cancellationToken = default)
    {
        var roles = await _roleManager.Roles.ToListAsync(cancellationToken: cancellationToken);
        if (roles?.Count > 0)
        {
            return _mapper.Map<List<RoleDto>>(roles);
        }
        return [];
    }

    public async Task<ErrorResponseDto?> AddUserRoleAsync(UserRoleDto userRoleDto, CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByEmailAsync(userRoleDto.Email);
        var role = await _roleManager.FindByNameAsync(userRoleDto.Role);

        if (role == null || user == null)
        {
            return new ErrorResponseDto { Code = "E03", Description = "Invalid user or role" };
        }

        var result = await _userManager.AddToRoleAsync(user, userRoleDto.Role);
        return null;
    }

    private async Task<string> GenerateTokenAsync(MetaPersonaIdentityUser user)
    {
        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JKEY"]));

        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

        var roles = await _userManager.GetRolesAsync(user);

        var roleClaims = roles.Select(x => new Claim(ClaimTypes.Role, x)).ToList();
        var userClaims = await _userManager.GetClaimsAsync(user);

        var claims = new List<Claim>
        {
            new (JwtRegisteredClaimNames.Sub, user.Email),
            new (JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new (JwtRegisteredClaimNames.Email, user.Email),
            new ("userId", user.Id.ToString()),
        }.Union(userClaims).Union(roleClaims);

        var token = new JwtSecurityToken(
            issuer: _configuration["JwtSettings:Issuer"],
            audience: _configuration["JwtSettings:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(Convert.ToInt32(_configuration["JwtSettings:DurationInHours"])),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
