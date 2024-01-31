using MetaPersona.Components.State;
using MetaPersona.Conf;
using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
using MudBlazor;
using Nethereum.Blazor;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.JsonRpc.Client.RpcMessages;
using Nethereum.Metamask;
using Nethereum.Metamask.Blazor;

namespace MetaPersona.Components.Auth;

public partial class ConnectMetamask
{
    private ILogger _logger;
    private bool MetamaskAvailable { get; set; }
    private string SelectedAccount { get; set; } = string.Empty;

    [Inject] public NetworkSettings NetworkSettings { get; set; }

    [Inject] public IDialogService DialogService { get; set; }

    [Inject] public IJSRuntime JsRuntime { get; set; }

    [Inject] public ILoggerFactory loggerFactory { get; set; }

    [Parameter]
    public string ConnectText { get; set; } = "Connect Metamask";

    [Parameter]
    public string InstallMetamaskText { get; set; } = "Install Metamask";

    [Parameter]
    public int SelectedAccountTruncateLength { get; set; } = 10;

    [CascadingParameter]
    public AppState AppState { get; set; }

    protected override void OnInitialized()
    {
        _logger = loggerFactory.CreateLogger<ConnectMetamask>();
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            _metamaskHostProvider.SelectedAccountChanged += MetamaskHostProvider_SelectedAccountChanged;

            MetamaskAvailable = await _metamaskHostProvider.CheckProviderAvailabilityAsync();
            if (MetamaskAvailable && !string.IsNullOrWhiteSpace(AppState.AccountAddress))
            {
                SelectedAccount = await _metamaskHostProvider.GetProviderSelectedAccountAsync();
                AppState.AccountAddress = SelectedAccount;
                await CheckChainId();
                if (!string.IsNullOrEmpty(SelectedAccount))
                {
                    await _selectedHostProvider.SetSelectedEthereumHostProvider(_metamaskHostProvider);
                }

            }
            StateHasChanged();
        }
    }

    public void Dispose()
    {
        _metamaskHostProvider.SelectedAccountChanged -= MetamaskHostProvider_SelectedAccountChanged;

    }

    private async Task MetamaskHostProvider_SelectedAccountChanged(string account)
    {
        SelectedAccount = account;
        AppState.AccountAddress = account;
        if (SelectedAccount != null)
        {
            await CheckChainId();
        }
        await InvokeAsync(() => this.StateHasChanged());
    }

    private async Task CheckChainId()
    {
        MetamaskBlazorInterop MMInterop = new(JsRuntime);
        var web3 = await _metamaskHostProvider.GetWeb3Async();
        if (!string.IsNullOrEmpty(SelectedAccount))
        {
            var response = await MMInterop.SendAsync(new MetamaskRpcRequestMessage(Guid.NewGuid().ToString(), "eth_chainId", SelectedAccount));
            if (response == null || !string.Equals("0x1ce", response.GetResult<string>(), StringComparison.CurrentCultureIgnoreCase))
            {
                // change network
                var request = web3.Eth.HostWallet.AddEthereumChain.BuildRequest(Constants.AreonTestnetChainParameters);
                var changeNetworkResponse = await MMInterop.SendAsync(new MetamaskRpcRequestMessage(Guid.NewGuid().ToString(), request.Method, SelectedAccount, request.RawParameters));
                if (changeNetworkResponse.GetResult<string>() == null)
                {
                    _logger.LogInformation("User cancelled network change");
                    AppState.AccountAddress = string.Empty;
                    // disconnect
                    await DisconnectAsync();
                }
            }
            else
            {
                // valid network is selected
                AppState.ChainId = Convert.ToInt64(response.GetResult<string>().RemoveHexPrefix(), 16);
            }
        }
    }

    protected async Task EnableEthereumAsync()
    {

        SelectedAccount = await _metamaskHostProvider.EnableProviderAsync();
        AppState.AccountAddress = SelectedAccount;
        if (SelectedAccount != null)
        {
            await CheckChainId();
        }
        await _selectedHostProvider.SetSelectedEthereumHostProvider(_metamaskHostProvider);


        if (_authenticationStateProvider is EthereumAuthenticationStateProvider provider)
        {
            provider?.NotifyStateHasChanged();
        }

        StateHasChanged();

    }

    public static string? Truncate(string? value, int maxLength, string truncationSuffix = "…")
    {
        return value?.Length > maxLength
            ? string.Concat(value.AsSpan(0, maxLength), truncationSuffix)
            : value;
    }

    private async Task DisconnectAsync()
    {
        AppState.AccountAddress = string.Empty;
        await MetamaskHostProvider.Current.ChangeSelectedAccountAsync(null);
    }
}
