namespace MetaPersonaApi.Data.DTOs;

public class ErrorResponseDto
{
    public string Code { get; set; } = string.Empty;
    public string? Description { get; set; }
}
