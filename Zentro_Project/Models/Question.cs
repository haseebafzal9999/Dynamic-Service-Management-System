using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class Question
{
    public int QuestionId { get; set; }

    public Guid QuestionGuid { get; set; }

    [Column("business_id")]

    public int? BusinessId { get; set; }
    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }
    public string Text { get; set; } = null!;

    public bool IsRequired { get; set; }

    public int DisplayOrder { get; set; }

    public int QuestionGroupId { get; set; }

    public int TemplateId { get; set; }

    public int? ParentId { get; set; }

    public DateTime? ValidFrom { get; set; }

    public DateTime? ValidTo { get; set; }

    public string? TagId { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? TemplateVersionId { get; set; }

    public int? FieldTypeId { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual ICollection<DependentQuestion> DependentQuestions { get; set; } = new List<DependentQuestion>();

    public virtual FieldType? FieldType { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual QuestionGroup QuestionGroup { get; set; } = null!;

    public virtual ICollection<QuestionOption> QuestionOptions { get; set; } = new List<QuestionOption>();

    public virtual Template Template { get; set; } = null!;

    public virtual TemplateVersion? TemplateVersion { get; set; }

    public virtual ICollection<UserAnswer> UserAnswers { get; set; } = new List<UserAnswer>();
}
