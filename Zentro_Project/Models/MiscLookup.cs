using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class MiscLookup
{
    public int CodeEnum { get; set; }

    public string CodeName { get; set; } = null!;

    public string CodeText { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual User? CreatedBy { get; set; }

    public virtual User? ModifiedBy { get; set; }

    public virtual ICollection<UserRecord1> UserRecord1s { get; set; } = new List<UserRecord1>();
}
