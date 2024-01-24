using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Services.Authentication;
using Microsoft.AspNetCore.Authorization;

namespace MetaPersonaApi.Endpoints.Auth;

public static class AuthenticationEndpoints
{
    public static void MapAuthenticationEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapPost("/api/login", async (LoginDto loginDto, IAuthManager authManager) =>
        {
            var response = await authManager.Login(loginDto);
            if (response == null)
            {
                return Results.Unauthorized();
            }

            return Results.Ok(response);
        })
            .AllowAnonymous()
            .WithTags("Authentication")
            .WithName("Login")
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized);

        routes.MapPost("/api/register", [Authorize(Policy ="Admin")] async (RegisterDto registerDto, IAuthManager authManager) =>
        {
            if (registerDto == null || string.IsNullOrEmpty(registerDto.Email) || string.IsNullOrEmpty(registerDto.Password))
            {
                return Results.BadRequest();
            }
            var response = await authManager.Register(registerDto);
            if (!response?.Any() ?? true)
            {
                return Results.Ok();
            }
            else
            {
                var errors = new List<ErrorResponseDto>();
                foreach (var error in response)
                {
                    errors.Add(new ErrorResponseDto { Code = error.Code, Description = error.Description });
                }

                return Results.BadRequest(errors);
            }
        })
            .WithTags("Authentication")
            .WithName("Register")
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
}
