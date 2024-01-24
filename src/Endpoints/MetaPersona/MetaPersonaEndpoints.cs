using MetaPersonaApi.Data.DTOs;

namespace MetaPersonaApi.Endpoints.MetaPersona;

public static class MetaPersonaEndpoints
{
    public static void MapMetaPersonaEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapPost("", async (SpawnDto spawnDto) =>
        {

        })
            .WithTags("MetaPersona")
            .WithName("Spawn")
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized); ;
    }
}
