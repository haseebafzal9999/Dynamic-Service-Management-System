namespace zentro.View_Model
{
    public class QuoteDetailsVM
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public EditPreviewVM? Details { get; set; }
        public string? CustomerName { get; set; }
        public int? QuoteId { get; set; }

    }
}
