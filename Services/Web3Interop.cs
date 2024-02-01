using Nethereum.Contracts.ContractHandlers;
using Nethereum.Metamask;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Web3;

namespace MetaPersona.Services;

public class Web3Interop(Conf.Contract contract) : IWeb3Interop
{
    private readonly Conf.Contract _contract = contract;

    private IWeb3? _web3;
    protected ContractHandler ContractHandler => _web3.Eth.GetContractHandler(_contract.Address);

    private async Task GetWeb3()
    {
        _web3 = await MetamaskHostProvider.Current.GetWeb3Async();
    }

    public virtual async Task<List<BigInteger>> GetPersonasQueryAsync(BlockParameter blockParameter = null)
    {
        if (_web3 is null)
        {
            await GetWeb3();
        }
        return await ContractHandler.QueryAsync<GetPersonasFunction, List<BigInteger>>(null, blockParameter);
    }

    public virtual async Task<GetParentsOutputDTO> GetParentsQueryAsync(GetParentsFunction getParentsFunction, BlockParameter blockParameter = null)
    {
        return await ContractHandler.QueryDeserializingToObjectAsync<GetParentsFunction, GetParentsOutputDTO>(getParentsFunction, blockParameter);
    }

    public virtual async Task<List<BigInteger>> GetChildrenQueryAsync(BigInteger pid1, BigInteger pid2, BlockParameter blockParameter = null)
    {
        var getChildrenFunction = new GetChildrenFunction
        {
            Pid1 = pid1,
            Pid2 = pid2
        };

        return await ContractHandler.QueryAsync<GetChildrenFunction, List<BigInteger>>(getChildrenFunction, blockParameter);
    }

    public virtual async Task<byte> GetGenderQueryAsync(BigInteger pId, BlockParameter blockParameter = null)
    {
        var getGenderFunction = new GetGenderFunction
        {
            PId = pId
        };

        return await ContractHandler.QueryAsync<GetGenderFunction, byte>(getGenderFunction, blockParameter);
    }
}
