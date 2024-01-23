using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Entities;
using Microsoft.EntityFrameworkCore;

namespace MetaPersonaApi.Data.Repositories;

public class GenericRepository<TEntity>(MetaPersonaDbContext metaPersonaDbContext) : IGenericRepository<TEntity> where TEntity : Entity
{
    protected readonly MetaPersonaDbContext _dbContext = metaPersonaDbContext;

    public async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        await _dbContext.AddAsync(entity, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return entity;
    }

    public async Task AddRangeAsync(params TEntity[] entity)
    {
        await _dbContext.AddRangeAsync(entity);
        await _dbContext.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await GetAsync(id, cancellationToken);
        if (entity != null)
        {
            _dbContext.Set<TEntity>().Remove(entity);
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<bool> Exists(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbContext.Set<TEntity>().AnyAsync(x => x.Id == id, cancellationToken);
    }

    public async Task<List<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.Set<TEntity>().ToListAsync(cancellationToken);
    }

    public async Task<TEntity?> GetAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbContext.Set<TEntity>().FindAsync([id], cancellationToken: cancellationToken);
    }

    public async Task UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        _dbContext.Update(entity);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateRangeAsync(params TEntity[] entity)
    {
        _dbContext.UpdateRange(entity);
        await _dbContext.SaveChangesAsync();
    }
}
