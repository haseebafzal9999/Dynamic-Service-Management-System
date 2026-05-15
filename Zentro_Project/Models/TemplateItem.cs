using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class TemplateItem
{
    public int TemplateItemId { get; set; }

    public int TemplateId { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }
    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public string? ServiceName { get; set; }

    public string? Description { get; set; }

    public int? Quantity { get; set; }

    public string? Unit { get; set; }

    public decimal? ItemPrice { get; set; }

    public decimal? Total { get; set; }

    public int? TemplateVersion { get; set; }

    public string RowId { get; set; } = null!;

    public DateTime? CreatedAt { get; set; }

    public bool IsActive { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual Template Template { get; set; } = null!;
    public int? QuoteId { get; set; }
    public int? CustomerId { get; set; }
}
