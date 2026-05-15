namespace zentro.View_Model
{
    public class ComponentFiltersModel
    {
        public string? sT { get; set; }        // search term, same 'q' convention as customers
        public string? Supplier { get; set; }  // supplier filter (list)
        public decimal? MinPrice { get; set; } // optional
        public decimal? MaxPrice { get; set; } // optional
        public string? PriceField { get; set; }
    }
}
