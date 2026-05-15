using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class BusinessDocument
{
    public int BusinessDocumentId { get; set; }

    public int BusinessId { get; set; }

    public int? DocumentType { get; set; }

    public string? DocumentName { get; set; }

    public DateTime? ExpiryDate { get; set; }

    public string? Actions { get; set; }

    public DateTime CreatedOn { get; set; }

    public int CreatedBy { get; set; }
}
