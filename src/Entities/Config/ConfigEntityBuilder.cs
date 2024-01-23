using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MetaPersonaApi.Entities.Configuration;

public static class ConfigEntityBuilder
{
    public static ModelBuilder ConfigureConfigEntity(this ModelBuilder builder)
    {
        builder?.Entity((EntityTypeBuilder<ConfigEntity> entity) =>
        {
            entity.Property(x => x.Key).IsRequired().HasMaxLength(256);
            entity.Property(x => x.Value).IsRequired().HasMaxLength(2048);
        });

        return builder;
    }
}