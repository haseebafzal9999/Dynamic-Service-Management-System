using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class UserRecord
{
    public int RecStatusId { get; set; }

    public string QuoteReference { get; set; } = null!;

    public int TempVersionId { get; set; }

    public int TemplateId { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }
    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public int MiscCodeEnum { get; set; }

    public string MiscCodeName { get; set; } = null!;

    public decimal TotalCost { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? MiscLookupCodeEnum { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public string Pdflink { get; set; } = null!;

    public string? Status { get; set; }

    public decimal TotalCostPrice { get; set; }

    public decimal TotalSellPrice { get; set; }
    public int? CustomerId { get; set; }
}
