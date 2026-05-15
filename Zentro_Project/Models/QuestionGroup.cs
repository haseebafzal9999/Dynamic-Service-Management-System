using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class QuestionGroup
{
    public int QuestionGroupId { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }
    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public string Name { get; set; } = null!;

    public int DisplayOrder { get; set; }

    public int TemplateId { get; set; }

    public Guid GroupGuid { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? TemplateVersionId { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual ICollection<Question> Questions { get; set; } = new List<Question>();

    public virtual Template Template { get; set; } = null!;

    public virtual TemplateVersion? TemplateVersion { get; set; }
}
