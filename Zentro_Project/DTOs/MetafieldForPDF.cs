namespace zentro.DTOs
{
    public class MetafieldForPdfDTO
    {
        public int MetafieldId { get; set; }

        public string Name { get; set; }

        public string Value { get; set; }

        public int PID { get; set; }

        public int TemplateId { get; set; }

        public int TemplateVersion { get; set; }
    }
}
