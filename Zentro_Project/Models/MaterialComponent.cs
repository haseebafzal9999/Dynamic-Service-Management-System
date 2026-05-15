using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class MaterialComponent
{
    public int MatCompId { get; set; }

    public int MaterialId { get; set; }

    public int ComponentId { get; set; }

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }

    public virtual Component Component { get; set; } = null!;

    public virtual Material Material { get; set; } = null!;
}
