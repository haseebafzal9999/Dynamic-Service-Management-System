using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

[Table("MetafieldAnswers", Schema = "templates")]
public class MetafieldAnswer
{
    [Key]
    public int MetafieldAnswerId { get; set; }

    public int TemplateVersionId { get; set; }
    public int QuoteId { get; set; }
    public int MetafieldId { get; set; }

    public string? MetafieldInput { get; set; } 

    [ForeignKey("TemplateVersionId")]
    public virtual TemplateVersion? TemplateVersion { get; set; }

    [ForeignKey("QuoteId")]
    public virtual UserRecord? UserRecord { get; set; }

    [ForeignKey("MetafieldId")]
    public virtual Metafield? Metafield { get; set; }
}