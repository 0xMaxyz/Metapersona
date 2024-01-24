using MetaPersonaApi.Data.DTOs;

namespace MetaPersonaApi.Services.MetaPersona;

public interface IMetaPersonaManager
{
    public Task SpawnAsync(SpawnDto spawnDto);
}
