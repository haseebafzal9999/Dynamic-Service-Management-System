using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class Menu
{
    public int MenuId { get; set; }

    public int ParentId { get; set; }

    public string Name { get; set; } = null!;

    public string Link { get; set; } = null!;

    public int LinkType { get; set; }

    public string? ImageRef { get; set; }

    public bool ShowAlways { get; set; }

    public bool ShowInToolbar { get; set; }

    public int SequenceNumber { get; set; }

    public DateTime CreatedOn { get; set; }

    public DateTime? LastUpdatedOn { get; set; }
}
