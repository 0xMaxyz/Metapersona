using Microsoft.AspNetCore.Authorization;
using MetaPersonaApi.Data.Contracts;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.Web3.Accounts;
using MetaPersonaApi.Entities.Configuration;

namespace MetaPersonaApi.Endpoints.Administration;

[Authorize(Roles = "Administrator")]
public static class AdministrationEndpoints
{
    public static void MapAdministrationEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapGet("/", async (IConfigEntityRepository configRepository) =>
        {
            // check if a wallet is created
            var walletAdress = await configRepository.GetConfigAsync(Constants.WalletAddress);

            if (!string.IsNullOrWhiteSpace(walletAdress))
            {
                return Results.Ok(walletAdress);
            }
            else
            {
                // create a wallet and save it in db and then return the wallet address
                var wallet = GenerateAccount();

                await configRepository.AddRangeAsync(
                    new ConfigEntity(Constants.WalletAddress, wallet.address),
                    new ConfigEntity(Constants.WalletPrivateKey, wallet.privateKey),
                    new ConfigEntity(Constants.WalletPublicKey, wallet.publicKey)
                    );
                return Results.Ok(wallet.address);
            }
        })
            .WithTags("Administartion")
            .WithName("WalletAddress")
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized);
    }

    private static (string privateKey, string publicKey, string address) GenerateAccount()
    {
        var ecKey = Nethereum.Signer.EthECKey.GenerateKey();
        var publicKey = "0x" + ecKey.GetPubKeyNoPrefix().ToHex();
        var privateKey = ecKey.GetPrivateKey().RemoveHexPrefix();
        var address = new Account(privateKey).Address.ToLower();

        return (privateKey, publicKey, address);
    }
}
