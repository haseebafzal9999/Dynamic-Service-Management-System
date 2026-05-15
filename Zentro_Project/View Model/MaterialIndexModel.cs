namespace zentro.View_Model
{
    public class MaterialIndexModel
    {
        public int? MaterialId { get; set; }

        public string? Name { get; set; }

        public string? Description { get; set; }

        public decimal? SellPrice { get; set; }

        public bool? IsActive { get; set; }

        public DateTime? CreatedAt { get; set; }

        public decimal? CostPrice { get; set; }

        public string? PartNo { get; set; }

        public string? Supplier { get; set; }

        public DateTime? ModifiedAt { get; set; }

        public int? CreatedById { get; set; }

        public int? ModifiedById { get; set; }
        public int? Id { get; set; }
        public int? Link { get; set; }
    }
}
