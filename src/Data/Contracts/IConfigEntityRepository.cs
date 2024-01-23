using MetaPersonaApi.Entities.Configuration;

namespace MetaPersonaApi.Data.Contracts;

public interface IConfigEntityRepository: IGenericRepository<ConfigEntity>
{
    Task<string?> GetConfigAsync(string key, CancellationToken cancellationToken = default);
    Task SetConfigAsync(string key, string value, CancellationToken cancellationToken = default);
    Task<bool> ConfigExistsAsync(string key, CancellationToken cancellationToken = default);

}
