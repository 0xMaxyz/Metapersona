using MetaPersonaApi.Data.DTOs;
using Microsoft.AspNetCore.Identity;
using MetaPersonaApi.Identity;
using MetaPersonaApi.Services;
using Microsoft.AspNetCore.Authorization;

namespace MetaPersonaApi.Endpoints.Administration;

[Authorize(Roles = "Administrator")]
public static class AdministrationEndpoints
{
    public static void MapAdministrationEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapGet("/api/getWallet", async () =>
        {

        })
            .WithTags("Administartion")
            .WithName("WalletAddress")
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized);
    }
}
