using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Entities.Configuration;
using Microsoft.EntityFrameworkCore;
using System.MetaPersona;

namespace MetaPersonaApi.Data.Repositories;

public class ConfigEntityRepository(MetaPersonaDbContext db) : GenericRepository<ConfigEntity>(db), IConfigEntityRepository
{
    public async Task<bool> ConfigExistsAsync(string key, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(key))
        {
            return false;
        }
        var normalizedKey = key.UNormalize();

        return await _dbContext.Set<ConfigEntity>().AnyAsync(x => x.NormalizedKey == normalizedKey, cancellationToken);
    }

    public async Task<string?> GetConfigAsync(string key, CancellationToken cancellationToken = default)
    {
        var normalizedKey = key.UNormalize();
        if (normalizedKey != null)
        {
            return (await _dbContext.Set<ConfigEntity>().FirstAsync(x => x.NormalizedKey == normalizedKey, cancellationToken)).Value;
        }
        return default;
    }

    public async Task SetConfigAsync(string key, string value, CancellationToken cancellationToken = default)
    {
        var normalizedKey = key.UNormalize();
        if (normalizedKey != null)
        {
            // check if config is created in db
            var hasConfig = await _dbContext.Set<ConfigEntity>().AnyAsync(x => x.NormalizedKey == normalizedKey, cancellationToken: cancellationToken);
            if (hasConfig)
            {
                var config = await _dbContext.Set<ConfigEntity>().FirstAsync(x => x.NormalizedKey == normalizedKey, cancellationToken);
                if (!string.Equals(config.NormalizedValue, value.UNormalize()))
                {
                    config.Value = value ?? string.Empty;
                    config.NormalizedValue = value.UNormalize() ?? string.Empty;

                    await UpdateAsync(config, cancellationToken);
                }
            }
            else
            {
                // create the config
                var config = new ConfigEntity(key, value);
                await AddAsync(config, cancellationToken);
            }
        }
    }
}
