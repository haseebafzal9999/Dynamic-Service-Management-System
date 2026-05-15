namespace zentro.View_Model
{
    public class QuoteDetailsResult
    {
        public bool Exists { get; set; }
        public string TemplateName { get; set; }
        public int? TemplateId { get; set; }
        public int? TemplateVersionId { get; set; }
        public int? CustomerId { get; set; }
    }

}
