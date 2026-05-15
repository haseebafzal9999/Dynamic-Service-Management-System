using zentro.View_Model;

namespace zentro.View_Model
{
    public class TemplatePreviewResponse
    {
        public int TemplateVersionId { get; set; }
        public string TemplateName { get; set; }
        public UserAnswerVM TemplateDetail { get; set; }
    }
}
