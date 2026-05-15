using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class BusinessMenu
{
    public int BusinessId { get; set; }

    public int MenuId { get; set; }

    public DateTime CreatedOn { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? LastUpdatedOn { get; set; }

    public int? LastUpdatedBy { get; set; }
}
