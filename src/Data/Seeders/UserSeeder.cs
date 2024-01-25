using MetaPersonaApi.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System.MetaPersona;

namespace MetaPersonaApi.Data.Seeder;
internal class UserSeeder : IEntityTypeConfiguration<MetaPersonaIdentityUser>
{
    public void Configure(EntityTypeBuilder<MetaPersonaIdentityUser> builder)
    {
        var hasher = new PasswordHasher<MetaPersonaIdentityUser>();
            builder.HasData(
            new MetaPersonaIdentityUser
            {
                Id = Constants.AdminUserId,
                Email = "omni001@proton.me",
                NormalizedEmail = "omni001@proton.me".UNormalize(),
                UserName = "omni001@proton.me",
                NormalizedUserName = "omni001@proton.me".UNormalize(),
                PasswordHash = hasher.HashPassword(null, Constants.AdminPassword),
                EmailConfirmed = true,
                WalletAddress = "0xdFF70A71618739f4b8C81B11254BcE855D02496B"
            });
    }
}