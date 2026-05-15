using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using zentro.Models;

namespace zentro.Services.TemplateDocument
{
    public class TemplateDocumentService:ITemplateDocumentService
    {
        private readonly dbContext _context;
        private readonly IWebHostEnvironment _env;
       
        private static readonly Regex DoubleBracketRegex =
          new(@"\[\[(.*?)\]\]", RegexOptions.Compiled);

        private static readonly Regex SingleCurlyRegex =
            new(@"\{([^{}\s]+)\}", RegexOptions.Compiled);

        public TemplateDocumentService(dbContext context,
           IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }
        public IReadOnlyCollection<string> ExtractDoubleBracketTags(string filePath)
        {
            return ExtractTagsInternal(filePath, DoubleBracketRegex);
        }

        public IReadOnlyCollection<string> ExtractSingleCurlyTags(string filePath)
        {
            return ExtractTagsInternal(filePath, SingleCurlyRegex);
        }
        public async Task<(string name, string path)> GetDocumentByTemplateIdAsync(int templateId)
        {
            var template = await _context.Templates.FindAsync(templateId);
            if (template == null || string.IsNullOrEmpty(template.TemplatePath))
            {
                return (string.Empty, string.Empty);
            }

            var fileName = Path.GetFileName(template.TemplatePath);
            return (fileName, template.TemplatePath);
        }

        public async Task<bool> UploadDocumentAsync(IFormFile file, int templateId)
        {
            if (file == null || file.Length == 0)
            {
                return false;
            }

            var uploads = Path.Combine(_env.WebRootPath, "UploadTemplate");
            Directory.CreateDirectory(uploads);

            var fileName = Path.GetFileName(file.FileName);
            var filePath = Path.Combine(uploads, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var template = await _context.Templates.FindAsync(templateId);
            if (template == null)
            {
                return false;
            }

            template.TemplatePath = $"/UploadTemplate/{fileName}";
            await _context.SaveChangesAsync();

            return true;
        }

        private static IReadOnlyCollection<string> ExtractTagsInternal(
       string filePath,
       Regex regex)
        {
            var tags = new HashSet<string>();

            using var archive = ZipFile.OpenRead(filePath);
            var entry = archive.GetEntry("content.xml");
            if (entry == null)
                return tags;

            using var stream = entry.Open();
            var document = XDocument.Load(stream);

            var plainText = new StringBuilder();

            foreach (var textNode in document.DescendantNodes().OfType<XText>())
            {
                plainText.Append(textNode.Value);
            }

            foreach (Match match in regex.Matches(plainText.ToString()))
            {
                tags.Add(match.Groups[1].Value.Trim());
            }

            return tags;
        }

    }
}
