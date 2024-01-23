using Microsoft.AspNetCore.Authorization;
using MetaPersonaApi.Data.Contracts;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.Web3.Accounts;
using MetaPersonaApi.Entities.Configuration;
using MetaPersonaApi.Entities.Config;
using Nethereum.Util;
using MetaPersonaApi.Utils;

namespace MetaPersonaApi.Endpoints.Administration;


public static class AdministrationEndpoints
{

    public static void MapAdministrationEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapGet("/api/admin/wallet", [Authorize(Roles = "Administrator")] async (IConfigEntityRepository configRepository) =>
        {
            // check if a wallet is created
            var walletAddress = await configRepository.GetConfigAsync(Constants.WalletAddress);

            if ((!string.IsNullOrWhiteSpace(walletAddress)) && walletAddress.Length == 42)
            {
                return Results.Ok(walletAddress);
            }
            else
            {
                // create a wallet and save it in db and then return the wallet address
                var wallet = GenerateAccount();

                var WalletAdd = await configRepository.GetAsync(Guid.Parse(Constants.WalletAddressId));
                WalletAdd?.SetValue(wallet.address);

                var walletPrvKey = await configRepository.GetAsync(Guid.Parse(Constants.WalletPrivateKeyId));
                walletPrvKey?.SetValue(wallet.privateKey);

                var walletPubKey = await configRepository.GetAsync(Guid.Parse(Constants.WalletPublicKeyId));
                walletPubKey?.SetValue(wallet.publicKey);

                await configRepository.UpdateRangeAsync(WalletAdd, walletPrvKey, walletPubKey);
                return Results.Ok(wallet.address);
            }
        })
            .WithTags("Administration")
            .WithName("WalletAddress")
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized);

        routes.MapPost("/api/admin/contract", [Authorize(Roles = "Administrator")] async (string contractAddress, IConfigEntityRepository configRepository) =>
        {
            if (!string.IsNullOrWhiteSpace(contractAddress) && (contractAddress.Length == 40 || contractAddress.Length == 42) && contractAddress.IsValidAddress())
            {
                var contractConfig = await configRepository.GetAsync(Guid.Parse(Constants.ContractAddressId));
                contractConfig?.SetValue(contractAddress);
                await configRepository.UpdateAsync(contractConfig);
                return Results.Ok();
            }

            return Results.BadRequest();
        })
            .WithTags("Administration")
            .WithName("ContractAddress")
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest)
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
