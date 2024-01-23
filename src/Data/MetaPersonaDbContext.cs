using MetaPersonaApi.Data.Seeder;
using MetaPersonaApi.Data.Seeders;
using MetaPersonaApi.Entities;
using MetaPersonaApi.Entities.Configuration;
using MetaPersonaApi.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace MetaPersonaApi.Data;

public class MetaPersonaDbContext(DbContextOptions<MetaPersonaDbContext> options, IHttpContextAccessor httpContextAccessor) : IdentityDbContext<MetaPersonaIdentityUser, IdentityRole<Guid>, Guid>(options)
{
    private readonly IHttpContextAccessor _httpContextAccessor = httpContextAccessor;

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        SetTimestamps();

        return base.SaveChangesAsync(cancellationToken);
    }

    private void SetTimestamps()
    {
        var entities = ChangeTracker.Entries()
            .Where(x => x.Entity is Entity)
            .Where(x => x.State is EntityState.Added || x.State is EntityState.Modified)
            .Select(x => new { Entity = x.Entity as Entity, x.State });

        var currentUserId = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var currentUserName = _httpContextAccessor.HttpContext?.User.Identity?.Name;

        if (entities?.Any() ?? false)
        {
            foreach (var item in entities)
            {
                if (item.Entity != null)
                {
                    if (item.State == EntityState.Added)
                    {
                        if (Guid.TryParse(currentUserId, out Guid id))
                        {
                            item.Entity.CreaterId = id;
                        }

                        item.Entity.Creater = currentUserName;

                        item.Entity.CreatedAt = DateTime.UtcNow;
                    }
                    if (item.State == EntityState.Modified)
                    {
                        if (Guid.TryParse(currentUserId, out Guid id))
                        {
                            item.Entity.ModifierId = id;
                        }

                        item.Entity.Modifier = currentUserName;

                        item.Entity.ModifiedAt = DateTime.UtcNow;
                    }
                }
            }
        }
    }
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ConfigEntities().SeedData();
    }
    DbSet<ConfigEntity> configEntities { get; set; }
}

public static class DbcontextExtensions
{

    public static ModelBuilder ConfigEntities(this ModelBuilder builder)
    {
        return builder
            .ConfigureMetaPersonaIdentityUser()
            .ConfigureConfigEntity();
    }

    public static ModelBuilder SeedData(this ModelBuilder builder)
    {
        return builder
            .ApplyConfiguration(new ConfigSeeder())
            .ApplyConfiguration(new UserSeeder())
            .ApplyConfiguration(new RoleSeeder())
            .ApplyConfiguration(new UserRoleSeeder());
    }
}
