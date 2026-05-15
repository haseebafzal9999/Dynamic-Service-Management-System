using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class Material
{
    public int MaterialId { get; set; }

    public string? Name { get; set; }

    public string? Description { get; set; }

    public decimal? SellPrice { get; set; }

    public bool? IsActive { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }

    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }

    public DateTime? CreatedAt { get; set; }

    public decimal? CostPrice { get; set; }

    public string? PartNo { get; set; }

    public string? Supplier { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public int? CreatedById { get; set; }

    public int? ModifiedById { get; set; }

    public virtual ICollection<MaterialComponent> MaterialComponents { get; set; } = new List<MaterialComponent>();
}
