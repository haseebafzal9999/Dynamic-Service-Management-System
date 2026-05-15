namespace zentro.DTOs
{
    // Request DTO for creating quote
    public class CreateQuoteForDefaultRequest
    {
        public int TemplateId { get; set; }
        public int TemplateVersion { get; set; }
    }

    // Request DTO for saving answers
    public class SaveDefaultAnswersRequest
    {
        public int RecStatusId { get; set; }
        public int TemplateId { get; set; }
        public int TemplateVersion { get; set; }
        public List<DefaultAnswerDto> Answers { get; set; }
    }

    // Answer DTO
    public class DefaultAnswerDto
    {
        public int QuestionId { get; set; }
        public int? SelectedOptionId { get; set; }
        public string AnswerText { get; set; }
        public int Quantity { get; set; } = 1;
    }

    // Request DTO for dependent questions
    public class GetDependentForDefaultRequest
    {
        public int TemplateVersionId { get; set; }
        public int QuestionOptionId { get; set; }
    }

    public class CreateAndSaveQuoteRequest
    {
        public int TemplateId { get; set; }
        public int TemplateVersion { get; set; }
        public List<AnswerDto> Answers { get; set; }
        public int? CustomerId { get; set; }
    }

    public class AnswerDto
    {
        public int QuestionId { get; set; }
        public int? SelectedOptionId { get; set; }
        public string? AnswerText { get; set; }
        public int Quantity { get; set; }
        public int? ParentOptionId { get; set; }  // ✅ NEW: Add this property

    }

}
