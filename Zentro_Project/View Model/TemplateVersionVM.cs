using Microsoft.AspNetCore.Http.HttpResults;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
namespace zentro.View_Model
{
    public class TemplateVersionVM
    {
        public int TemplateVersionId { get; set; }
        public DateTime? TempValidFrom { get; set; }
        public DateTime? TempValidTo { get; set; }
        public int TempVersion { get; set; }
        public string? CreatedBy { get; set; }
    }
    public class AnswerViewModel
    {
        public int Id { get; set; }          // from dataset.id or generated
        public int Order { get; set; }          // index + 1
        public string? Option { get; set; }
        public string? SelectedOption { get; set; }
        public int? SelectedMatComId { get; set; }
        public string? SelectedValue { get; set; }
        public string? SelectedQuestions { get; set; }
        public List<string> SelectedQuestionsList { get; set; } = new List<string>(); // contain list of id (QuestionViewModel.Id) of dependent questions
        public string? AnswerGuid { get; set; }
        public string OptionGuid { get; set; } = string.Empty;

    }
    public class QuestionGroupVM
    {
        public int Id { get; set; }          // from dataset.id
        public int Order { get; set; }          // from dataset.order
        public Guid GroupGuid { get; set; }
        public string Name { get; set; }
    }
    // Question now stores id + order
    public class QuestionViewModel
    {
        public int Id { get; set; }          // from dataset.id
        public int Order { get; set; }          // from dataset.order
        public string? Question { get; set; }
        public string? QuestionText { get; set; }
        public string? QuestionGroup { get; set; }   // group id
        public int? QuestionGrpId { get; set; }
        public int? FieldTypeId { get; set; }
        public bool IsRequired { get; set; }
        public string? FieldType { get; set; }
        public string? QuestionGuid { get; set; }
        public string? GroupGuid { get; set; } // NEW: Group GUID (from QuestionGroup) for resolving groups after clone
        //public bool IsRequired { get; set; }
        public List<AnswerViewModel> Answers { get; set; } = new();
    }
    public class TemplateVM
    {
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [JsonPropertyName("templateVersionId")]
        public int TemplateVersionId { get; set; }

        [JsonPropertyName("name")]
        public string Name { get; set; }

        [JsonPropertyName("description")]
        public string Description { get; set; }

        [JsonPropertyName("createdBy")]
        public string CreatedBy { get; set; }
    }

}
