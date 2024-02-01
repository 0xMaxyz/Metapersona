namespace MetaPersonaApi;

public static class Constants
{
    // System
    public static string AllowAnyOrigin => "AllowAnyOrigin";

    // Auth
    public static Guid AdminUserId => Guid.Parse("8c748df8-6148-45f8-b286-f0a74078aeb0");
    public static Guid AdminRoleId => Guid.Parse("8c748df8-6148-45f8-b286-f0a74078aeb1");
    public static Guid SpawnerRoleId => Guid.Parse("8c748df8-6148-45f8-b286-f0a74078aeb2");
    public static string AdminPassword => "P@ssW0rd";
    // Wallet
    public static string WalletAddress => "WalletAddress";
    public static Guid WalletAddressId => Guid.Parse("53264ca4-0adb-47aa-8f27-20bea645636e");
    public static string WalletPublicKey => "WalletPublicKey";
    public static Guid WalletPublicKeyId => Guid.Parse("b3cbe892-2af8-42b6-97e2-5eecf7fa8e44");
    public static string WalletPrivateKey => "WalletPrivateKey";
    public static Guid WalletPrivateKeyId => Guid.Parse("8419af8a-bde9-496e-b8f9-76d90adbfaa4");
    public static string ContractAddress => "ContractAddress";
    public static Guid ContractAddressId => Guid.Parse("927ed149-f4a1-4cd7-8fcb-d94084f9f1e3");

}
