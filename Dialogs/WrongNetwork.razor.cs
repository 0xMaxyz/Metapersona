using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
using MudBlazor;
using Nethereum.Metamask;
using Nethereum.Metamask.Blazor;

namespace MetaPersona.Dialogs;

public partial class WrongNetwork
{
    [CascadingParameter] MudDialogInstance MudDialog { get; set; }

    [Inject] public MetamaskHostProvider HostProvider { get; set; }

    [Inject] public IJSRuntime JsRuntime { get; set; }

    private async Task Disconnect()
    {
        await HostProvider.ChangeSelectedAccountAsync(null);
        MudDialog.Cancel();
    }

    private async Task Switch()
    {
        MetamaskBlazorInterop MMInterop = new(JsRuntime);
        var web3 = await HostProvider.GetWeb3Async();
        var account = await HostProvider.GetProviderSelectedAccountAsync();
        var request = web3.Eth.HostWallet.AddEthereumChain.BuildRequest(Constants.AreonTestnetChainParameters);
        await MMInterop.SendAsync(new MetamaskRpcRequestMessage(Guid.NewGuid().ToString(), request.Method, account, request.RawParameters));
        MudDialog.Close();
    }
}
