using MetaPersonaApi.Data.DTOs;
using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona;

public interface IMetaPersonaManager
{
    public Task<BigInteger> SpawnAsync(SpawnDto spawnDto);
}
