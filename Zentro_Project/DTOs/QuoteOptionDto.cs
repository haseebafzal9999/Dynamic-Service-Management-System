namespace zentro.DTOs
{
    public class QuoteOptionDto
    {
        public int QOptionId { get; set; }
        public string OptionText { get; set; }
        public int? OptionDisplayOrder { get; set; }
        public int? OptionFieldTypeId { get; set; }

        public string MatCompName { get; set; }
        public int? MaterialCompId { get; set; }
        public string Name { get; set; }
        public decimal? SellPrice { get; set; }
        public decimal? CostPrice { get; set; }

        // Answer info (is this option selected?)
        public bool IsSelected { get; set; }
        public int? Quantity { get; set; }
    }
}