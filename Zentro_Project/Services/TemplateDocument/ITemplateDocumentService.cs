using Microsoft.AspNetCore.Mvc;
using System.Text.RegularExpressions;

namespace zentro.Services.TemplateDocument
{
    public interface ITemplateDocumentService
    {
        IReadOnlyCollection<string> ExtractDoubleBracketTags(string filePath);
        IReadOnlyCollection<string> ExtractSingleCurlyTags(string filePath);
        Task<(string name, string path)> GetDocumentByTemplateIdAsync(int templateId);
        Task<bool> UploadDocumentAsync(IFormFile file, int templateId);
    }
}
