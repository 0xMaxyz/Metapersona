using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using MudBlazor.Services;
using Nethereum.Metamask.Blazor;
using Nethereum.Metamask;
using Microsoft.AspNetCore.Components.Authorization;
using Nethereum.Blazor;
using Nethereum.UI;
using MetaPersona.Conf;

namespace MetaPersona
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            var builder = WebAssemblyHostBuilder.CreateDefault(args);
            builder.RootComponents.Add<App>("#app");
            builder.RootComponents.Add<HeadOutlet>("head::after");

            builder.Services.AddAuthorizationCore();

            builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

            builder.Services.AddSingleton<IMetamaskInterop, MetamaskBlazorInterop>();
            builder.Services.AddSingleton<MetamaskHostProvider>();

            builder.Services.AddSingleton(services =>
            {
                var metamaskHostProvider = services.GetService<MetamaskHostProvider>();
                var selectedHostProvider = new SelectedEthereumHostProviderService();
                selectedHostProvider.SetSelectedEthereumHostProvider(metamaskHostProvider);
                return selectedHostProvider;
            });


            builder.Services.AddSingleton<AuthenticationStateProvider, EthereumAuthenticationStateProvider>();

            builder.Services.AddMudServices();

            var networkSettings = new NetworkSettings
            {
                Networks = []
            };

            var networks = builder.Configuration.GetSection("Networks");
            var children = networks.GetChildren();
            foreach (var section in children)
            {
                var key = section.Key;
                var networkInfo = section.Get<NetworkInfo>();
                networkSettings.Networks.Add(key, networkInfo);
            }

            builder.Services.AddSingleton(networkSettings);

            await builder.Build().RunAsync();
        }
    }
}
