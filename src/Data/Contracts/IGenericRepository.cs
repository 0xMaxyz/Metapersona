using MetaPersonaApi.Entities;

namespace MetaPersonaApi.Data.Contracts;

public interface IGenericRepository<TEntity, TKey> where TEntity : Entity
{
    Task<TEntity> GetAsync(TKey id);
    Task<List<TEntity>> GetAllAsync();
    Task<TEntity> CreateAsync(TEntity entity);
    Task DeleteAsync(TKey id);
    Task UpdateAsync(TKey id);
    Task<bool> Exists(TKey id);
}
