using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class UserRecord1
{
    public int RecStatusId { get; set; }

    public string QuoteReference { get; set; } = null!;

    public int TempVersionId { get; set; }

    public int TemplateId { get; set; }

    public int MiscCodeEnum { get; set; }

    public string MiscCodeName { get; set; } = null!;

    public decimal TotalCost { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? MiscLookupCodeEnum { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string Pdflink { get; set; } = null!;

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual MiscLookup? MiscLookupCodeEnumNavigation { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual TemplateVersion TempVersion { get; set; } = null!;

    public virtual Template Template { get; set; } = null!;
}
