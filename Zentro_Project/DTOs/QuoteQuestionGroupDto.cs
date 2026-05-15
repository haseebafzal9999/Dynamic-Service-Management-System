namespace zentro.DTOs
{
    public class QuoteQuestionGroupDto
    {
        public int QuestionGroupId { get; set; }
        public string QuestionGroupName { get; set; }
        public int QuestionGroupDisplayOrder { get; set; }
        public List<QuoteQuestionDto> Questions { get; set; } = new();
    }
}