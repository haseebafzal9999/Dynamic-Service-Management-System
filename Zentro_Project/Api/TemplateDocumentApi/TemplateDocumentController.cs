using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using zentro.Models;
using zentro.Services.TemplateDocument;

namespace zentro.Api.TemplateDocumentApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class TemplateDocumentController : ControllerBase
    {
        private readonly ITemplateDocumentService _templateDocumentService;
        private readonly dbContext _context;
        private readonly IWebHostEnvironment _env;

        public TemplateDocumentController(dbContext context,
            ITemplateDocumentService templateDocumentService,
            IWebHostEnvironment env)
        {
            _context = context;
            _templateDocumentService = templateDocumentService;
            _env = env;
        }

        [HttpGet("GetDocumentByTemplateId")]
        public async Task<IActionResult> GetDocumentByTemplateId(int templateId)
        {
            var (name, path) = await _templateDocumentService.GetDocumentByTemplateIdAsync(templateId);
            return Ok(new { name, path });
        }

        [HttpPost("UploadDocument")]
        public async Task<IActionResult> UploadDocument([FromForm] IFormFile file, [FromForm] int templateId)
        {
            var uploadSuccess = await _templateDocumentService.UploadDocumentAsync(file, templateId);
            if (!uploadSuccess)
                return BadRequest("File upload failed.");

            return Ok(new { success = true });
        }

        [HttpGet("extract-tags")]
        public IActionResult ExtractMetaFields(string fileName = "file_main.odt")
        {
            var validationResult = ValidateFileNameAndPath(fileName);
            if (validationResult.Result != null)
                return validationResult.Result;
             
            var filePath = validationResult.FilePath!;

            var extractionResult = ExtractTagsSafely(filePath);
            if (extractionResult.Result != null)
                return extractionResult.Result;

            if (extractionResult.Value == null)
                return StatusCode(StatusCodes.Status500InternalServerError);

            var (doubleBracketTags, singleCurlyTags) = extractionResult.Value.Value;

            var businessRuleResult = ValidateExtractedTags(doubleBracketTags, singleCurlyTags);
            if (businessRuleResult != null)
                return businessRuleResult;

            return Ok(BuildDoubleBracketOnlyResponse(doubleBracketTags));
        }

        private (IActionResult? Result, string? FilePath)
    ValidateFileNameAndPath(string fileName)
        {
            if (string.IsNullOrWhiteSpace(fileName))
                return (BadRequest("File name is required."), null);

            fileName = Path.GetFileName(fileName);

            if (!Path.GetExtension(fileName)
                .Equals(".odt", StringComparison.OrdinalIgnoreCase))
                return (BadRequest("Only .odt files are supported."), null);

            var filePath = Path.Combine(
                _env.WebRootPath,
                "UploadTemplate",
                fileName
            );

            if (!System.IO.File.Exists(filePath))
                return (NotFound($"Template file '{fileName}' not found."), null);

            return (null, filePath);
        }

        private (IActionResult? Result,
        (IReadOnlyCollection<string> Double,
         IReadOnlyCollection<string> Single)? Value)
    ExtractTagsSafely(string filePath)
        {
            try
            {
                var doubleTags = _templateDocumentService.ExtractDoubleBracketTags(filePath);
                var singleTags = _templateDocumentService.ExtractSingleCurlyTags(filePath);

                return (null, (doubleTags, singleTags));
            }
            catch
            {
                return (StatusCode(
                    StatusCodes.Status500InternalServerError,
                    "Failed to extract tags from template."
                ), null);
            }
        }

        private IActionResult? ValidateExtractedTags(
    IReadOnlyCollection<string> doubleBracketTags,
    IReadOnlyCollection<string> singleCurlyTags)
        {
            if (!doubleBracketTags.Any() && !singleCurlyTags.Any())
            {
                return UnprocessableEntity(new
                {
                    Message = "No metadata tags were found in the template.",
                    ExpectedFormats = new[]
                    {
                "[[metafieldName]]",
                "{tagName}"
            }
                });
            }

            return null;
        }

        private object BuildDoubleBracketOnlyResponse(
    IReadOnlyCollection<string> doubleBracketTags)
        {
            return new
            {
                doubleBracketTags
            };
        }
    }
}
