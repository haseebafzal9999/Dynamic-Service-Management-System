using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class DependentQuestion
{
    public int DependentQid { get; set; }

    public int? QoptionId { get; set; }

    public int? NextQuestionId { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual Question? NextQuestion { get; set; }

    public virtual QuestionOption? Qoption { get; set; }
}
