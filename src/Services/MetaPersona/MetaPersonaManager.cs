using AutoMapper;
using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Data.DTOs;
using MetaPersonaApi.Data.Repositories;
using MetaPersonaApi.Services.MetaPersona.DTOs;
using MetaPersonaApi.Services.MetaPersona.Functions;
using MetaPersonaApi.Services.MetaPersona.Genetics;
using MetaPersonaApi.Services.MetaPersona.Genetics.Enums;
using MetaPersonaApi.Services.MetaPersona.SolidityStructs;
using Nethereum.Contracts.Standards.ERC1155.ContractDefinition;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;
using System.Numerics;

namespace MetaPersonaApi.Services.MetaPersona;

public class MetaPersonaManager : IMetaPersonaManager
{
    public MetaPersonaManager(IConfigEntityRepository configEntityRepository, IConfiguration configuration, ILoggerFactory loggerFactory, IMapper mapper)
    {
        _configEntityRepository = configEntityRepository;
        _configuration = configuration;
        _mapper = mapper;
        _logger = loggerFactory.CreateLogger<MetaPersonaManager>();
    }
    private readonly ILogger<MetaPersonaManager> _logger;
    private readonly IConfigEntityRepository _configEntityRepository;
    private readonly IConfiguration _configuration;
    private readonly IMapper _mapper;
    private static string? contractAddress;
    private Nethereum.Web3.Web3? _web3;

    private async Task<Web3> InitializeWeb3()
    {
        if (_web3 == null)
        {
            // get prvKey
            var prvKey = await _configEntityRepository.GetConfigAsync(Constants.WalletPrivateKey);
            // get RPC_URL
            var rpcUrl = _configuration["RPC_URL"];

            Account sender = new(prvKey);

            _web3 = new Nethereum.Web3.Web3(sender, rpcUrl, _logger);
        }
        return _web3;
    }

    public async Task<BigInteger> SpawnAsync(SpawnDto spawnDto)
    {
        _ = await InitializeWeb3();

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
            Chromosomes = [.. fertilizeResult],
        };
        var contractAddress = await GetContractAddress();

        var spawnHandler = _web3.Eth.GetContractTransactionHandler<SpawnFunction>();
        var transactionReceipt = await spawnHandler.SendRequestAndWaitForReceiptAsync(contractAddress, spawnFunction);

        var id = transactionReceipt.Logs[1]["topics"][1];

        return BigInteger.Parse(id.ToString()[2..], System.Globalization.NumberStyles.HexNumber);
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

            //ChromosomeDto[] persona1ChromosomeDtp = new ChromosomeDto[persona1Chromosomes.Length];
            //ChromosomeDto[] persona2ChromosomeDtp = new ChromosomeDto[persona2Chromosomes.Length];

            ChromosomeDto[] persona1ChromosomeDto = _mapper.Map<Chromosome[], ChromosomeDto[]>(persona1Chromosomes);
            ChromosomeDto[] persona2ChromosomeDto = _mapper.Map<Chromosome[], ChromosomeDto[]>(persona2Chromosomes);

            // check gender
            var persona1Gender = Meiosis.GetGender(persona1ChromosomeDto);
            var persona2Gender = Meiosis.GetGender(persona2ChromosomeDto);

            if (IsGendersValid(persona1Gender, persona2Gender))
            {
                var gametes1 = Meiosis.DoMeiosis(persona1ChromosomeDto, _mapper);
                var gametes2 = Meiosis.DoMeiosis(persona2ChromosomeDto, _mapper);

                return [_mapper.Map<ChromosomeDto, Chromosome>(gametes1[Genetics.Utils.Random.RandBetween(0, 3)]), _mapper.Map<ChromosomeDto, Chromosome>(gametes2[Genetics.Utils.Random.RandBetween(0, 3)])];
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
        return [.. chromosomes.Chromosomes];
    }
}
