using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class QuestionOption
{
    public int QoptionId { get; set; }
    public Guid OptionGuid { get; set; }

    public string OptionText { get; set; } = null!;

    public int QuestionId { get; set; }

    public int DisplayOrder { get; set; }

    public int? FieldTypeId { get; set; }

    public int? MaterialCompId { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? MatCompName { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual ICollection<DependentQuestion> DependentQuestions { get; set; } = new List<DependentQuestion>();

    public virtual FieldType? FieldType { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual Question Question { get; set; } = null!;

    public virtual ICollection<UserAnswer> UserAnswers { get; set; } = new List<UserAnswer>();
}
