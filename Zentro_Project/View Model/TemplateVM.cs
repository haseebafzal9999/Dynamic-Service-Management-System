
namespace zentro.View_Model
{
    public class TemplateVm
    {
        public int TemplateId { get; set; }
        public string TemplateName { get; set; }
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime? CreatedAt { get; set; }
        public string? CreatedBy { get; set; }
        public int? Id { get; set; }
        public string? Link { get;set;}
    }
}
