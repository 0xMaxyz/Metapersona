namespace MetaPersonaApi.Entities.Configuration;
using MetaPersonaApi.Entities;

public class ConfigEntity : Entity
{
    public string Key { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
}