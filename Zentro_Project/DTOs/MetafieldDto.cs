namespace zentro.DTOs
{
    public class MetafieldDto
    {
        public int Id { get; set; } = 0;

        public string? MetafieldGuid { get; set; }  // ADD THIS

        public string Name { get; set; } = string.Empty;
        public string FieldType { get; set; } = string.Empty;
        public string? Tag { get; set; }
        public string Visibility { get; set; } = string.Empty;
        public int TemplateVersionId { get; set; }
        //public string? TableStyle { get; set; }

    }

    public class MetafieldDeleteRequest
    {
        public string MetafieldGuid { get; set; } = string.Empty;
        public int TemplateVersionId { get; set; }
    }
}
