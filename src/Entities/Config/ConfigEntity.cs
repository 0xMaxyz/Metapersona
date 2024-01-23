namespace MetaPersonaApi.Entities.Configuration;
using MetaPersonaApi.Entities;
using System.MetaPersona;

public class ConfigEntity : Entity
{
    protected ConfigEntity() { } // For ORM
    public ConfigEntity(string key, string value)
    {
        Key = key;
        NormalizedKey = key.UNormalize() ?? string.Empty;
        Value = value;
        NormalizedValue = value.UNormalize() ?? string.Empty;
    }

    public string Key { get; set; } = string.Empty;
    public string NormalizedKey { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string NormalizedValue { get; set; } = string.Empty;
}