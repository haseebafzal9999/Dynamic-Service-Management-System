namespace zentro.View_Model
{
    public class ComponentModel
    {
        public int? ComponentId { get; set; }
        public int MaterialId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal? CostPrice { get; set; }
        public decimal? SellPrice { get; set; }
        public string Supplier { get; set; }
        public string PartNo { get; set; }
        public bool? IsActive { get; set; }
        public string? CreatedById { get; set; }
        public string? ModifiedById { get; set; }
        public List<string> Materials { get; set; } = new List<string>();
    }
}
