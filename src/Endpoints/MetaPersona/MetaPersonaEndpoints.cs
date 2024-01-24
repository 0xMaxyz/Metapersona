using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Services.MetaPersona;
using Microsoft.AspNetCore.Authorization;
using System.Numerics;

namespace MetaPersonaApi.Endpoints.MetaPersona;

public static class MetaPersonaEndpoints
{
    public static void MapMetaPersonaEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapPost("/api/MetaPersona/spawn", [Authorize(Roles ="Spawner")] async (SpawnDto spawnDto, IMetaPersonaManager metaPersonaManager) =>
        {
            try
            {
                var result = await metaPersonaManager.SpawnAsync(spawnDto);

                return Results.Ok(result);
            }
            catch (Exception)
            {
                return Results.BadRequest();
            }
        })
            .WithTags("MetaPersona")
            .WithName("Spawn")
            .Produces<BigInteger>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest)
            .Produces(StatusCodes.Status401Unauthorized); ;
    }
}
