using MetaPersonaApi.Entities.Configuration;
using System.MetaPersona;

namespace MetaPersonaApi.Entities.Config;

public static class ConfigEntityExtensions
{
    public static ConfigEntity SetValue(this ConfigEntity configEntity, string value)
    {
        if (configEntity == null)
        {
            return null;
        }

        configEntity.Value = value;
        configEntity.NormalizedValue = value.UNormalize();
        
        return configEntity;
    }
}
