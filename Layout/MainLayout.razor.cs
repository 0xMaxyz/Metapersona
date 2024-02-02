using MetaPersona.Dialogs;
using Microsoft.AspNetCore.Components;
using MudBlazor;
using Nethereum.Metamask;

namespace MetaPersona.Layout;

public partial class MainLayout
{
    [Inject] public MetamaskHostProvider HostProvider { get; set; }
    [Inject] public IDialogService DialogService { get; set; }

    private bool _isDarkMode = true;
    private MudThemeProvider _mudThemeProvider;

    protected override Task OnInitializedAsync()
    {
        HostProvider.NetworkChanged += OnNetworkChangedAsync;
        return base.OnInitializedAsync();
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            try
            {
                _isDarkMode = await _mudThemeProvider.GetSystemPreference();
                await _mudThemeProvider.WatchSystemPreference(OnSystemPreferenceChanged);
                StateHasChanged();
            }
            catch
            { }
        }
    }

    private async Task OnNetworkChangedAsync(long chainId)
    {
        if (chainId != 462)
        {
            var options = new DialogOptions { CloseOnEscapeKey = false, CloseButton = false, ClassBackground = "glass", DisableBackdropClick = true };
            await DialogService.ShowAsync<WrongNetwork>("Unsupported Network", options);
        }
    }

    private Task OnSystemPreferenceChanged(bool newValue)
    {
        _isDarkMode = newValue;
        return Task.CompletedTask;
    }

    public void Dispose()
    {
        HostProvider.NetworkChanged -= OnNetworkChangedAsync;

    }
}
