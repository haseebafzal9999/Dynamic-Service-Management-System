using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace   zentro.Models;

public partial class UserAnswer
{
    public int UanswerId { get; set; }

    public int QuestionId { get; set; }

    public int? QoptionId { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }

    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public int? ParentOptionId { get; set; }


    public string? AnswerText { get; set; }

    public int? DisplayOrder { get; set; }

    public DateTime DateTime { get; set; }

    public int? RecordId { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public int? CustomerId { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual QuestionOption? Qoption { get; set; }

    public virtual Question Question { get; set; } = null!;

    public int QuoteVersionId { get; set; } = 1;
}
