using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class Role
{
    public string Id { get; set; } = null!;

    public string? Name { get; set; }

    public string? NormalizedName { get; set; }

    public string? ConcurrencyStamp { get; set; }

    public virtual ICollection<RolesClaim> RolesClaims { get; set; } = new List<RolesClaim>();

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
