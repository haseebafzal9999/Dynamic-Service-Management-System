namespace zentro.View_Model
{
    public class IframeViewModel
    {
        public int Id { get; set; }
        public string WebsiteName { get; set; } = string.Empty;
        public string Link { get; set; } = string.Empty;
        public DateTime? CreatedAt { get; set; }
        public string Status { get; set; } = string.Empty;
    }
}
