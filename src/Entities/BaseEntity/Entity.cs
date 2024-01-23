namespace MetaPersonaApi.Entities;
public class Entity : IEntity
{
    public Guid Id { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? ModifiedAt { get; set; }
    public string? Creater { get; set; }
    public Guid? CreaterId { get; set; }
    public string? Modifier { get; set; }
    public Guid? ModifierId { get; set; }
}