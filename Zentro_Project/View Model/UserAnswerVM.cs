using zentro.DTOs;
using zentro.Models;

namespace zentro.View_Model
{
    public class UserAnswerVM
    {
        public string? TemplateName { get; set; }

        public int RecordId { get; set; }
        public Dictionary<int, AnswerSubmissionVM> Answers { get; set; } = new();
        public int? TemplateId { get; set; }

        public int? CustomerId { get; set; }
        public int? RecStatusId { get; set; }
        public List<TemplateItem> Items { get; set; } = new List<TemplateItem>();
        public List<MetafieldForPdfDTO>? Metafields { get; set; } = new List<MetafieldForPdfDTO>();

        public int? TemplateVersion { get; set; }

        public List<Question> dbQuestions { get; set; } = new();
        public List<QuestionGroup> dbQuestionGroups { get; set; } = new();
        public List<OptionPriceVM> OptionPrices { get; set; } = new List<OptionPriceVM>();

        public string? CurrencyType { get; set; }
        public string? CustomerName { get; set; }
    }
}

public class OptionPriceVM
{
    public int OptionId { get; set; }
    public decimal? SellPrice { get; set; }
    public decimal? CostPrice { get; set; }
}

public class DeleteQuoteItemDto
{
    public int TemplateId { get; set; } // to scope deletion to a template
    public string RowId { get; set; }   // hierarchical id e.g., "1.2.1"
}
public class ReorderQuoteItemsDto
{
    public int TemplateId { get; set; }
    public int TemplateVersion { get; set; }
    public List<ReorderItemDto> Items { get; set; }
}

public class ReorderItemDto
{
    public string OldRowId { get; set; }
    public string NewRowId { get; set; }
}
public class UserDto
{
    public string Id { get; set; } = default!;
    public string? PhoneNumber { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
}
