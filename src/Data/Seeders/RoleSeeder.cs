using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System.MetaPersona;

namespace MetaPersonaApi.Data.Seeder;
internal class RoleSeeder : IEntityTypeConfiguration<IdentityRole<Guid>>
{
    public void Configure(EntityTypeBuilder<IdentityRole<Guid>> builder)
    {
        builder.HasData(
            new IdentityRole<Guid>
            {
                Id = Guid.Parse(Constants.AdminRoleId),
                Name = "Administrator",
                NormalizedName = "Administrator".UNormalize()
            },
            new IdentityRole<Guid>
            {
                Id = Guid.Parse(Constants.UserRoleId),
                Name = "User",
                NormalizedName = "User".UNormalize()
            }
            ) ;
    }
}