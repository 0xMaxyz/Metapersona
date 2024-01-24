using System.Numerics;

namespace MetaPersonaApi.Data.DTOs;

public class SpawnDto
{
    public BigInteger Persona1Id { get; set; }
    public string Persona1OwnerAddress { get; set; } = string.Empty;
    public BigInteger Persona2Id { get; set; }
    public string Persona2OwnerAddress { get; set; } = string.Empty;
    public string ReceiverAddress { get; set; } = string.Empty;
}
