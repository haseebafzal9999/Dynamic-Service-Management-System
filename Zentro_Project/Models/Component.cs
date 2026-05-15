using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class Component
{
    public int ComponentId { get; set; }

    public string Name { get; set; } = null!;

    public string Description { get; set; } = null!;

    public decimal BuildCost { get; set; }

    public bool IsActive { get; set; }
    [Column("business_id")]
    public int? BusinessId { get; set; }

    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string PartNo { get; set; } = null!;

    public decimal SellPrice { get; set; }

    public string? Supplier { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? CreatedById { get; set; }

    public string? ModifiedById { get; set; }


    public virtual ICollection<MaterialComponent> MaterialComponents { get; set; } = new List<MaterialComponent>();
}
