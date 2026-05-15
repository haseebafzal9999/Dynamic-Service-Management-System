namespace Vscale_Fleet_Solutions.DTOs
{
    public class QuoteAnswerResponse
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public int primaryId { get; set; }

        public int QuoteVersionId { get; set; }

    }
}
