namespace MetaPersona.Conf;

public class NetworkSettings
{
    public Dictionary<string, NetworkInfo> Networks { get; set; }
}

public class NetworkInfo
{
    public string Name { get; set; }
    public string Explorer { get; set; }
}
