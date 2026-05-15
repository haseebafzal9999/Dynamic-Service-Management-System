using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class MenuAccess
{
    public int SecurityGroupId { get; set; }

    public int MenuId { get; set; }

    public DateTime LastModified { get; set; }

    public DateTime DateCreated { get; set; }
}
