namespace zentro.DTOs
{
    public class QuestionDto
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; }
        public bool? IsRequired { get; set; }
        public int? QuestionDisplayOrder { get; set; }
        public int? QuestionFieldTypeId { get; set; }
        public string FieldTypeName { get; set; }
        public string FieldTypeDisplayName { get; set; }

        public List<OptionDto> Options { get; set; } = new();
    }
}
