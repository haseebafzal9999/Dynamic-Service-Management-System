using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models
{
    [Table("Iframes", Schema = "templates")]
    public class Iframe
    {
        [Key]
        public int PID { get; set; }

        [Required]
        public string WebsiteName { get; set; } = string.Empty;

        [Required]
        public string Link { get; set; } = string.Empty;

        [Required]
        public int TempVersionId { get; set; }
        public int TemplateId { get; set; }
        public int? BusinessId { get; set; }


        public string? Status { get; set; }
        public string? Full_key { get; set; }
        public string? Partial_key { get; set; }


        public bool IsActive { get; set; } = false;

        public DateTime? CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }

        public string? CreatedById { get; set; }
        public string? ModifiedById { get; set; }

        // --- Navigation property ---
        [ForeignKey("TempVersionId")]
        public TemplateVersion? TemplateVersion { get; set; }
    }
}
