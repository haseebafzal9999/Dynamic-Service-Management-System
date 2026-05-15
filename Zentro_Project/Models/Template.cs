using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;    

public partial class Template
{
    public int TemplateId { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }

    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public string TemplateName { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? Description { get; set; }

    public DateTime? ModifiedAt { get; set; }
    public string? TemplatePath { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual ICollection<QuestionGroup> QuestionGroups { get; set; } = new List<QuestionGroup>();

    public virtual ICollection<Question> Questions { get; set; } = new List<Question>();

    public virtual ICollection<TemplateItem> TemplateItems { get; set; } = new List<TemplateItem>();

    public virtual ICollection<TemplateVersion> TemplateVersions { get; set; } = new List<TemplateVersion>();

    public virtual ICollection<UserRecord1> UserRecord1s { get; set; } = new List<UserRecord1>();
}
