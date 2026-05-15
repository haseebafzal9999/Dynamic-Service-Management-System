using System.Text.Json.Serialization;

namespace zentro.View_Model
{
    public class QuoteIndexVM
    {
        [JsonPropertyName("QuoteNumber")]
        public string? QuoteNumber { get; set; }

        [JsonPropertyName("Name")]
        public string? Name { get; set; }

        [JsonPropertyName("Email")]
        public string? Email { get; set; }

        [JsonPropertyName("PhoneNumber")]
        public string? PhoneNumber { get; set; }

        [JsonPropertyName("TemplateName")]
        public string? TemplateName { get; set; }

        [JsonPropertyName("CostPrice")]
        public decimal? CostPrice { get; set; }

        [JsonPropertyName("SellPrice")]
        public decimal? SellPrice { get; set; }

        [JsonPropertyName("Status")]
        public string? Status { get; set; }
        [JsonPropertyName("id")]
        public int? id { get; set; }
        [JsonPropertyName("link")]
        public int? link { get; set; }
    }
}