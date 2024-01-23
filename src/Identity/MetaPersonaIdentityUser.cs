using Microsoft.AspNetCore.Identity;

namespace MetaPersonaApi.Identity;

public class MetaPersonaIdentityUser : IdentityUser<Guid>
{
    public string? WalletAddress { get; set; }
}
