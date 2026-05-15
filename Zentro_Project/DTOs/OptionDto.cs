namespace zentro.DTOs
{
    public class OptionDto
    {
        public int? QOptionId { get; set; }
        public string OptionText { get; set; }
        public int? OptionDisplayOrder { get; set; }
        public int? OptionFieldTypeId { get; set; }

        public string MatCompName { get; set; }
        public int? MaterialCompId { get; set; }
        public string Name { get; set; }
        public decimal? SellPrice { get; set; }
        public decimal? CostPrice { get; set; }
    }
}
