using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class SecurityGroup
{
    public int SecurityGroupId { get; set; }

    public int ParentId { get; set; }

    public string SecurityGroupName { get; set; } = null!;

    public string ApiPath { get; set; } = null!;

    public DateTime LastModified { get; set; }

    public DateTime DateCreated { get; set; }
}
