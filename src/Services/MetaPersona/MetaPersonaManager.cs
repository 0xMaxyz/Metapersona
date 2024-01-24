using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Services.MetaPersona.DTOs;
using MetaPersonaApi.Services.MetaPersona.Functions;
using MetaPersonaApi.Services.MetaPersona.Genetics;
using MetaPersonaApi.Services.MetaPersona.Genetics.Enums;
using MetaPersonaApi.Services.MetaPersona.SolidityStructs;
using Nethereum.Contracts.Standards.ERC1155.ContractDefinition;
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

        _web3 = new Nethereum.Web3.Web3(rpcUrl, _logger);
    }
    private readonly ILogger<MetaPersonaManager> _logger;
    private readonly IConfigEntityRepository _configEntityRepository;
    private readonly IConfiguration _configuration;
    private static string? contractAddress;
    private readonly Nethereum.Web3.Web3? _web3;


    public async Task<BigInteger> SpawnAsync(SpawnDto spawnDto)
    {
        var fertilizeResult = await Fertilize(spawnDto);
        if (fertilizeResult.Length == 0)
        {
            throw new Exception("Not spawned, check input");
        }

        var spawnFunction = new SpawnFunction
        {
            PersonaId1 = spawnDto.Persona1Id,
            PersonaId2 = spawnDto.Persona2Id,
            PersonaOwner1 = spawnDto.Persona1OwnerAddress,
            PersonaOwner2 = spawnDto.Persona2OwnerAddress,
            Receiver = spawnDto.ReceiverAddress,
            Chromosomes = fertilizeResult
        };
        var contractAddress = await GetContractAddress();

        var spawnHandler = _web3.Eth.GetContractQueryHandler<SpawnFunction>();
        var newId = await spawnHandler.QueryAsync<BigInteger>(contractAddress, spawnFunction);

        return newId;
    }

    private async Task<Chromosome[]> Fertilize(SpawnDto spawnDto)
    {
        // Check ownership of personas
        var ownership1 = await IsOwnedByRequesterAsync(spawnDto.Persona1OwnerAddress, spawnDto.Persona1Id);
        var ownership2 = await IsOwnedByRequesterAsync(spawnDto.Persona2OwnerAddress, spawnDto.Persona2Id);

        if (ownership1 && ownership2)
        {
            // get chromosomes of persona1 and persona2
            var persona1Chromosomes = await GetChromosomes(spawnDto.Persona1OwnerAddress, spawnDto.Persona1Id);
            var persona2Chromosomes = await GetChromosomes(spawnDto.Persona2OwnerAddress, spawnDto.Persona2Id);

            // check gender
            var persona1Gender = Meiosis.GetGender(persona1Chromosomes);
            var persona2Gender = Meiosis.GetGender(persona2Chromosomes);

            if (IsGendersValid(persona1Gender, persona2Gender))
            {
                var gametes1 = Meiosis.DoMeiosis(persona1Chromosomes);
                var gametes2 = Meiosis.DoMeiosis(persona2Chromosomes);

                return [gametes1[Random.Shared.Next(0, 3)], gametes2[Random.Shared.Next(0, 3)]];
            }
        }
        return [];
    }

    private static bool IsGendersValid(Gender g1, Gender g2)
    {

        return (g1 == Gender.Female && g2 == Gender.Male) || (g1 == Gender.Male && g2 == Gender.Female);

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

    private async Task<Chromosome[]> GetChromosomes(string ownerAddress, BigInteger personaId)
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
