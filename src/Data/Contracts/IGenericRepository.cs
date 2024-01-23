using MetaPersonaApi.Entities;

namespace MetaPersonaApi.Data.Contracts;

public interface IGenericRepository<TEntity> where TEntity : Entity
{
    Task<TEntity?> GetAsync(Guid id, CancellationToken cancellationToken = default);
    Task<List<TEntity>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default);
    Task AddRangeAsync(params TEntity[] entity);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    Task UpdateAsync(TEntity entity, CancellationToken cancellationToken = default);
    Task<bool> Exists(Guid id, CancellationToken cancellationToken = default);
    public Task UpdateRangeAsync(params TEntity[] entity);
}
