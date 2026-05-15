namespace Vscale_Fleet_Solutions.DTOs
{
    public class QuoteAnswerRequest
    {
        public int QuoteId { get; set; }
        public int PrimaryId { get; set; }
        public int QuestionId { get; set; }  
        public int OptionId { get; set; }  
        public string? Value { get; set; }
        public string? fieldType { get; set; }

        public int QuoteVersionId { get; set; } = 1;
        public int? ParentOptionId { get; set; }

    }
}
