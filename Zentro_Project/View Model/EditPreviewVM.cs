using zentro.Models;
using zentro.View_Model;

namespace zentro.View_Model
{
    public class EditPreviewVM
    {
        public int? TemplateId { get; set; }
        public string? TemplateName { get; set; }
        public int RecStatusId { get; set; }

        public int? TemplateVersion { get; set; }
        public string UserId { get; set; }
        public int? statusId { get; set; }
        public List<QuestionGroup> QuestionGroups { get; set; } = new();
        public List<Question> Questions { get; set; } = new();
        public List<TemplateItem> Items { get; set; } = new(); // For quote table, if needed
        public Dictionary<int, EditPreviewAnswerVM> Answers { get; set; } = new();
        public List<OptionPriceVM> OptionPrices { get; set; } = new List<OptionPriceVM>();

        public int? CustomerId { get; set; }
    }

    public class EditPreviewAnswerVM
    {
        public List<int> SelectedOptionIds { get; set; } = new(); // for checkboxes
        public int? SelectedOptionId { get; set; } // for radio/select
        public string AnswerText { get; set; } // for input
        public List<TableLineItemVM> LineItems { get; set; } = new(); // For table
    }

}
