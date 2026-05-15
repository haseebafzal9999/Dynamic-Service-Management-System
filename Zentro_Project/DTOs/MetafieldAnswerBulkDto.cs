namespace zentro.DTOs
{
    public class MetafieldAnswerBulkDto
    {
        public int QuoteId { get; set; }
        public int TemplateVersionId { get; set; }
        public List<MetafieldAnswerDto> Answers { get; set; } = new();
    }
}
