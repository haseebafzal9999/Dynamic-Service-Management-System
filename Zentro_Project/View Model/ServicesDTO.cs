using  zentro.Models;
namespace zentro.View_Model
{
    public class ServicesDTO
    {
        public int? RecStatusId { get; set; }
        public List<TemplateItem> Items { get; set; } = new List<TemplateItem>();
    }
}
