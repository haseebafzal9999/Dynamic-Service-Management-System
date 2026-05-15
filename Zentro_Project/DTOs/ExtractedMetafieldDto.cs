namespace zentro.DTOs
{
    public class ExtractedMetafieldDto
    {
        public string Name { get; set; }
        public string Tag { get; set; }
        public string FieldType { get; set; }
        public string Visibility { get; set; }
    }
    public class BulkMetafieldRequest
    {
        public int TemplateVersionId { get; set; }
        public List<ExtractedMetafieldDto> Metafields { get; set; }
    }


}
