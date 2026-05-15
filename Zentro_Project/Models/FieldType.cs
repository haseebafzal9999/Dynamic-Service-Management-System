using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class FieldType
{
    public int FieldTypeId { get; set; }

    public string FieldName { get; set; } = null!;
    public string DisplayName { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual ICollection<QuestionOption> QuestionOptions { get; set; } = new List<QuestionOption>();

    public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
}
