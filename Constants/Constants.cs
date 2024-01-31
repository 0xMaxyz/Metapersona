using Nethereum.RPC.HostWallet;
using System.Numerics;

namespace MetaPersona;

public class Constants
{
    public static string MetamaskIconAsImgTag => "<image width=\"24\" height=\"24\" xlink:href=\"img/metamask-fox.svg\" />";
    public static readonly AddEthereumChainParameter AreonTestnetChainParameters = new()
    {
        ChainId = new Nethereum.Hex.HexTypes.HexBigInteger(new BigInteger(462)),
        ChainName = "Areon Network Testnet",
        BlockExplorerUrls = ["https://areonscan.com/"],
        RpcUrls = [
            "https://testnet-rpc.areon.network",
            "https://testnet-rpc2.areon.network",
            "https://testnet-rpc3.areon.network",
            "https://testnet-rpc4.areon.network",
            "https://testnet-rpc5.areon.network"
            ],
        NativeCurrency = new NativeCurrency()
        {
            Decimals = 18,
            Name = "TAREA",
            Symbol = "TAREA"
        }

    };
}
