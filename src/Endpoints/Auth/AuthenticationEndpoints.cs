using MetaPersonaApi.Data.DTOs;
using Microsoft.AspNetCore.Identity;
using MetaPersonaApi.Identity;
using MetaPersonaApi.Services;

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
    }
}
