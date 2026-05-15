namespace zentro.DTOs
{
    public class OptionQuantityDto
    {
        public int optionId { get; set; }
        public int quantity { get; set; }

        public decimal costPrice { get; set; }
        public decimal sellPrice { get; set; }
    }
}
