using Nethereum.RPC.Eth.DTOs;
using System.Numerics;

namespace MetaPersona.Services;

public interface IWeb3Interop
{
    Task<List<BigInteger>> GetPersonasQueryAsync(BlockParameter blockParameter = null);
}