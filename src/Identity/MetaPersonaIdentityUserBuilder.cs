using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MetaPersonaApi.Identity;

public static class MetaPersonaIdentityUserBuilder
{
    public static ModelBuilder ConfigureMetaPersonaIdentityUser(this ModelBuilder builder)
    {
        builder?.Entity((EntityTypeBuilder<MetaPersonaIdentityUser> entity) =>
        {
            entity.Property(x => x.WalletAddress).IsFixedLength().HasMaxLength(42);
        });

        return builder;
    }
}
