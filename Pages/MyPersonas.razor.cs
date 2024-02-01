using MetaPersona.Components.State;
using MetaPersona.Services;
using Microsoft.AspNetCore.Components;

namespace MetaPersona.Pages;

public partial class MyPersonas
{
    [CascadingParameter]
    public AppState AppState { get; set; }

    [Inject]
    public IWeb3Interop Web3Interop { get; set; }
    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            var p = await Web3Interop.GetPersonasQueryAsync();
        }
    }
}
