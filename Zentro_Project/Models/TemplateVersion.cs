using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class TemplateVersion
{
    public int TempVersionId { get; set; }

    public int TemplateId { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }
    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public DateTime? TempValidFrom { get; set; }

    public DateTime? TempValidTo { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? TempVersion { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual ICollection<QuestionGroup> QuestionGroups { get; set; } = new List<QuestionGroup>();

    public virtual ICollection<Question> Questions { get; set; } = new List<Question>();

    public virtual Template Template { get; set; } = null!;

    public virtual ICollection<UserRecord1> UserRecord1s { get; set; } = new List<UserRecord1>();
    public virtual ICollection<Metafield> Metafields { get; set; } = new List<Metafield>();

}
