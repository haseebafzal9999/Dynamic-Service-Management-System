namespace zentro.View_Model
{
    // zentro.View_Model/ComponentIndexModel.cs
    public class ComponentIndexModel
    {
        public int? ComponentId { get; set; }
        public string? PartNo { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public decimal? BuildCost { get; set; }
        public decimal? SellPrice { get; set; }
        public string? Supplier { get; set; }
        public bool? IsActive { get; set; }

        // Add this 👇
        public List<int>? SelectedMaterialIds { get; set; }

        // Optional: if you’re returning materials with names
        public List<string>? Materials { get; set; }

        public DateTime? CreatedAt { get; set; }
        public int? Id { get; set; }
    }


}
