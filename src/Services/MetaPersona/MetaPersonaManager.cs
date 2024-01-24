using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Services.MetaPersona.DTOs;
using MetaPersonaApi.Services.MetaPersona.Functions;
using MetaPersonaApi.Services.MetaPersona.SolidityStructs;
using MetaPersonaApi.Utils;
using Nethereum.Contracts.Standards.ERC1155.ContractDefinition;
using Nethereum.Web3;
using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona;

public class MetaPersonaManager : IMetaPersonaManager
{
    public MetaPersonaManager(IConfigEntityRepository configEntityRepository, IConfiguration configuration, ILoggerFactory loggerFactory)
    {
        _configEntityRepository = configEntityRepository;
        _configuration = configuration;
        _logger = loggerFactory.CreateLogger<MetaPersonaManager>();

        // get RPC_URL
        var rpcUrl = _configuration["RPC_URL"];

        _web3 = new Web3(rpcUrl, _logger);
    }
    private readonly ILogger<MetaPersonaManager> _logger;
    private readonly IConfigEntityRepository _configEntityRepository;
    private readonly IConfiguration _configuration;
    private static string? contractAddress;
    private readonly Nethereum.Web3.Web3? _web3;


    public async Task<BigInteger> SpawnAsync(SpawnDto spawnDto)
    {
        // Check ownership of personas
        var ownership1 = await IsOwnedByRequesterAsync(spawnDto.Persona1OwnerAddress, spawnDto.Persona1Id);
        var ownership2 = await IsOwnedByRequesterAsync(spawnDto.Persona2OwnerAddress, spawnDto.Persona2Id);

        if (ownership1 && ownership2)
        {
            // get chromosomes of persona1 and persona2
            var persona1Chromosomes = await GetChromosomes(spawnDto.Persona1OwnerAddress, spawnDto.Persona1Id);
            var persona2Chromosomes = await GetChromosomes(spawnDto.Persona2OwnerAddress, spawnDto.Persona2Id);
        }
        return BigInteger.Zero;
    }

    private async Task<bool> IsOwnedByRequesterAsync(string ownerAddress, BigInteger personaId)
    {
        var contractAddress = await GetContractAddress();

        var balanceOfFunction = new BalanceOfFunction
        {
            Id = personaId,
            Account = ownerAddress
        };

        var balanceHandler = _web3.Eth.GetContractQueryHandler<BalanceOfFunction>();
        var balance = await balanceHandler.QueryAsync<BigInteger>(contractAddress, balanceOfFunction);
        return balance.IsOne;
    }

    private async Task<string> GetContractAddress(CancellationToken cancellationToken = default)
    {
        if (contractAddress == null)
        {
            var result = await _configEntityRepository.GetConfigAsync(Constants.ContractAddress, cancellationToken);
            if (result == null)
            {
                throw new Exception("Contract address not available");
            }
            else
            {
                contractAddress = result;
                return result;
            }
        }
        else
        {
            return contractAddress;
        }
    }

    private async Task<List<Chromosome>> GetChromosomes(string ownerAddress, BigInteger personaId)
    {
        var getChromosomesFunction = new GetChromosomesFunction
        {
            Owner = ownerAddress,
            PersonaId = personaId
        };
        var contractAddress = await GetContractAddress();

        var getChromosomeHandler = _web3.Eth.GetContractQueryHandler<GetChromosomesFunction>();
        var chromosomes = await getChromosomeHandler.QueryAsync<GetChromosomesOutputDTO>(contractAddress, getChromosomesFunction); 
        return chromosomes.Chromosomes;
    }
}
