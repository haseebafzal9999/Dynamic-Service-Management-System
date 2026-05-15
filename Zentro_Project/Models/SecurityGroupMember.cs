using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class SecurityGroupMember
{
    public int SecurityGroupId { get; set; }

    public int UserId { get; set; }

    public DateTime LastModified { get; set; }

    public DateTime DateCreated { get; set; }
}
