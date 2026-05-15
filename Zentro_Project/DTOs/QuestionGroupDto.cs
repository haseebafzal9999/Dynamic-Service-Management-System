namespace zentro.DTOs
{
    public class QuestionGroupDto
    {
        public int QuestionGroupId { get; set; }
        public string QuestionGroupName { get; set; }
        public int QuestionGroupDisplayOrder { get; set; }
        public Guid GroupGuid { get; set; }
        public List<QuestionDto> Questions { get; set; } = new();
    }
}
