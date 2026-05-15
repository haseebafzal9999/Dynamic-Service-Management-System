using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models
{
    [Table("Metafields", Schema = "templates")]
    public class Metafield
    {
        [Key]
        public int PID { get; set; }

        public int TempVersionId { get; set; }

        public Guid MetafieldGuid { get; set; } = Guid.NewGuid();


        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string FieldType { get; set; } = string.Empty;

        public string? Tag { get; set; }   // nullable in DB

        [Required]
        public string Visibility { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public DateTime? CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
        public string? CreatedById { get; set; }
        public string? ModifiedById { get; set; }
        public string? TableStyle { get; set; }


        // Navigation property (will be set by EF)
        [ForeignKey("TempVersionId")]
        public TemplateVersion? TemplateVersion { get; set; }
    }
}
