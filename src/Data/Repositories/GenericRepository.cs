using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Entities;

namespace MetaPersonaApi.Data.Repositories;

public class GenericRepository<TEntity, TKey>(MetaPersonaDbContext metaPersonaDbContext) : IGenericRepository<TEntity, TKey> where TEntity : Entity
{
    protected readonly MetaPersonaDbContext _dbContext = metaPersonaDbContext;

    public async Task<TEntity> CreateAsync(TEntity entity)
    {
        await _dbContext.AddAsync(entity);
        await _dbContext.SaveChangesAsync();
        return entity;
    }

    public async Task DeleteAsync(TKey id)
    {
        throw new NotImplementedException();
    }

    public async Task<bool> Exists(TKey id)
    {
        throw new NotImplementedException();
    }

    public async Task<List<TEntity>> GetAllAsync()
    {
        throw new NotImplementedException();
    }

    public async Task<TEntity> GetAsync(TKey id)
    {
        throw new NotImplementedException();
    }

    public async Task UpdateAsync(TKey id)
    {
        throw new NotImplementedException();
    }
}
