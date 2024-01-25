using MetaPersonaApi.Entities.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MetaPersonaApi.Data.Seeders;

internal class ConfigSeeder : IEntityTypeConfiguration<ConfigEntity>
{
    public void Configure(EntityTypeBuilder<ConfigEntity> builder)
    {
        builder.HasData(
            new ConfigEntity(Constants.ContractAddress, "0x")
            {
                Id = Constants.ContractAddressId
            },
            new ConfigEntity(Constants.WalletAddress, "0x")
            {
                Id = Constants.WalletAddressId
            },
            new ConfigEntity(Constants.WalletPublicKey, "0x")
            {
                Id = Constants.WalletPublicKeyId
            },
            new ConfigEntity(Constants.WalletPrivateKey, "0x")
            {
                Id = Constants.WalletPrivateKeyId
            });
    }
}
