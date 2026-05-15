namespace zentro.DTOs
{
    public class QuoteQuestionDto
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; }
        public bool? IsRequired { get; set; }
        public int? QuestionDisplayOrder { get; set; }
        public int? QuestionFieldTypeId { get; set; }
        public string FieldTypeName { get; set; }
        public string FieldTypeDisplayName { get; set; }

        // Answer Information for Prefill
        public string AnswerText { get; set; }
        public int? SelectedOptionId { get; set; }
        public int? PrimaryId { get; set; }

        // ✅ NEW: Parent context for dependent questions
        public int? ParentOptionId { get; set; }


        public List<TableLineItemDto> LineItems { get; set; } = new();

        public List<QuoteOptionDto> Options { get; set; } = new();
    }
}