namespace MetaPersonaApi.Data.DTOs;

public class SpawnInputDto
{
    public string Persona1Id { get; set; } = string.Empty;
    public string Persona1OwnerAddress { get; set; } = string.Empty;
    public string Persona2Id { get; set; } = string.Empty;
    public string Persona2OwnerAddress { get; set; } = string.Empty;
    public string ReceiverAddress { get; set; } = string.Empty;
}
