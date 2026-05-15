using Microsoft.AspNetCore.Http.HttpResults;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;
using zentro.DTOs;
namespace zentro.View_Model
{
    public class TemplateBuilderVM
    {
        public IEnumerable<SelectListItem>? FieldTypes { get; set; }
        public TemplateVM Template { get; set; } = new();

        public TemplateVersionVM? SelectedVersion { get; set; }
        public TemplateVersionVM? LatestVersion { get; set; }
        public List<TemplateVersionVM>? AllVersions { get; set; } = new();
        public bool IsActive { get; set; }  
        //public bool IsNewTemplate { get; set; }

        // use to save to db
        public TemplateVersionVM? TemplateVersion { get; set; } = new();
        public List<QuestionGroupVM> QuestionGroups { get; set; } = new();
        public List<QuestionViewModel> QuestionAnswers { get; set; } = new();
        public List<MetafieldDto> MetaFields { get; set; } = new();

    }
    public class TemplateDetailViewModel
    {
        public string TemplateName { get; set; }
        public string Description { get; set; }
        public List<FieldTypeItem> FieldTypes { get; set; }
    }



    public class FieldTypeItem
    {
        public int FieldTypeId { get; set; }
        public string FieldName { get; set; }
    }
    public class TemplateListVM
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
        public string CreatedBy { get; set; }
        public bool IsActive { get; set; }
        public int? LatestTempVersionId { get; set; } // ✅ new
    }

    
}
