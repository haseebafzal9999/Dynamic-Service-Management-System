

namespace zentro.DTOs
{
    public class GenerateIframeTokenRequestDto
    {
        public string WebsiteName { get; set; } = string.Empty;

        public int BusinessId { get; set; }

        public int TemplateVersionId { get; set; }
    }
}
