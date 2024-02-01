using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Services.MetaPersona;
using Microsoft.AspNetCore.Authorization;
using System.Numerics;

namespace MetaPersonaApi.Endpoints.MetaPersona;

public static class MetaPersonaEndpoints
{
    public static void MapMetaPersonaEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapPost("/api/MetaPersona/spawn", [Authorize(Roles ="Spawner")] async (SpawnInputDto spawnInputDto, IMetaPersonaManager metaPersonaManager) =>
        {
            try
            {
                // convert SpawnInputDto => SpawnDto

                SpawnDto spawnDto = new()
                {
                    Persona1Id = BigInteger.Parse(spawnInputDto.Persona1Id),
                    Persona2Id = BigInteger.Parse(spawnInputDto.Persona2Id),
                    Persona1OwnerAddress = spawnInputDto.Persona1OwnerAddress,
                    Persona2OwnerAddress = spawnInputDto.Persona2OwnerAddress,
                    ReceiverAddress = spawnInputDto.ReceiverAddress
                };

                //
                var result = await metaPersonaManager.SpawnAsync(spawnDto);

                return Results.Ok("PersonaId: " + result.ToString());
            }
            catch (Exception ex)
            {
                return Results.BadRequest(ex.Message);
            }
        })
            .WithTags("MetaPersona")
            .WithName("Spawn")
            .Produces<string>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest)
            .Produces(StatusCodes.Status401Unauthorized);

        routes.MapGet("/api/MetaPersona/contract", async (IConfigEntityRepository configRepository) =>
        {
            var contractConfig = await configRepository.GetConfigAsync(Constants.ContractAddress);
            return contractConfig == null ? Results.NoContent() : Results.Ok(contractConfig);
        })
            .AllowAnonymous()
            .WithTags("MetaPersona")
            .WithName("Contract Address")
            .Produces<string>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status401Unauthorized);

        routes.MapGet("/api/MetaPersona/pid/", async (string id) =>
        {
            
        })
            .AllowAnonymous()
            .RequireCors(Constants.AllowAnyOrigin)
            .WithTags("MetaPersona")
            .WithName("Contract Address")
            .Produces<string>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status401Unauthorized);
    }
}
