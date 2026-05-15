namespace zentro.DTOs
{

    public class QuoteTemplateDetails
    {
        // Question Group
        public int QuestionGroupId { get; set; }
        public string QuestionGroupName { get; set; }
        public int QuestionGroupDisplayOrder { get; set; }

        // Question
        public int? QuestionId { get; set; }
        public string QuestionText { get; set; }
        public bool? IsRequired { get; set; }
        public int? QuestionDisplayOrder { get; set; }
        public int? QuestionFieldTypeId { get; set; }

        // Field Type
        public string FieldTypeName { get; set; }
        public string FieldTypeDisplayName { get; set; }

        // Option
        public int? QOptionId { get; set; }
        public string OptionText { get; set; }
        public int? OptionDisplayOrder { get; set; }
        public int? OptionFieldTypeId { get; set; }

        // Material / Component Info
        public string MatCompName { get; set; }
        public int? MaterialCompId { get; set; }
        public string Name { get; set; }
        public decimal? SellPrice { get; set; }
        public decimal? CostPrice { get; set; }

        // User Answers (for prefill)
        public int? UserAnswerId { get; set; }
        public string AnswerText { get; set; }
        public int? AnswerQuantity { get; set; }
        public bool IsAnswered { get; set; }
        // ✅ NEW: Parent context for dependent questions
        public int? ParentOptionId { get; set; }

    }
}
