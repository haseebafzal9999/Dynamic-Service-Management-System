using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using zentro.Areas.Identity.Data;
using zentro.DTOs;
using zentro.library;
using zentro.Models;
using zentro.Services.Metafield;
using zentro.Templates;
using zentro.View_Model;
namespace zentro.Api.MetafieldApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class MetafieldController : Controller
    {
        private readonly dbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IMetafieldService _metafieldService;


        public MetafieldController(dbContext context, IMetafieldService metafieldService, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
            _metafieldService = metafieldService;

        }

        //  Bulk upload extracted metafields
        [HttpPost("BulkUploadExtracted")]
        public async Task<IActionResult> BulkUploadExtracted([FromBody] BulkMetafieldRequest request)
        {
            if (request?.Metafields == null || !request.Metafields.Any())
            {
                return BadRequest(new { success = false, message = "No metafields provided" });
            }

            try
            {
                var templateVersionId = request.TemplateVersionId;

                // Validate template version exists
                var templateVersion = await _context.TemplateVersions
                    .FindAsync(templateVersionId);

                if (templateVersion == null)
                {
                    return NotFound(new { success = false, message = "Template version not found" });
                }

                var createdById = await Common.UserInfo(_userManager, User.Identity.Name);

                var createdMetafields = new List<object>();

                foreach (var meta in request.Metafields)
                {
                    var entity = new Metafield
                    {
                        Name = meta.Name,
                        Tag = meta.Tag ?? meta.Name, 
                        FieldType = meta.FieldType ?? "Single Line Text",
                        Visibility = meta.Visibility ?? "Admin only",
                        TempVersionId = templateVersionId,
                        CreatedAt = DateTime.UtcNow,
                        CreatedById = createdById.UserId.ToString(),
                        IsActive = true
                    };

                    _context.Metafields.Add(entity);
                    await _context.SaveChangesAsync();

                    createdMetafields.Add(new
                    {
                        id = entity.PID,
                        name = entity.Name,
                        tag = entity.Tag,
                        fieldType = entity.FieldType,
                        visibility = entity.Visibility
                    });
                }

                return Ok(new
                {
                    success = true,
                    message = $"{createdMetafields.Count} metafields uploaded successfully",
                    metafields = createdMetafields
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Failed to upload metafields",
                    error = ex.Message
                });
            }
        }

        [HttpPost("SaveMetafieldAnswersBulk")]
        public async Task<IActionResult> SaveMetafieldAnswersBulk([FromBody] MetafieldAnswerBulkDto dto)
        {
            if (dto == null || dto.QuoteId == 0 || dto.TemplateVersionId == 0 || dto.Answers == null)
                return BadRequest("Invalid data");

            var result = await _metafieldService.SaveMetafieldAnswersBulkAsync(dto);
            return Ok(new { success = result });
        }


        [HttpPost("GetMetafieldsForCreateQuote")]
        public async Task<IActionResult> GetMetafieldsForCreateQuote([FromBody] IdRequest request)
        {
            var result = await _metafieldService.GetMetafieldsForCreateQuoteAsync(request.Id);
            return Ok(result);
        }

        [HttpPost("SaveMetafieldAnswer")]
        public async Task<IActionResult> SaveMetafieldAnswer([FromBody] MetafieldAnswerDto dto)
        {
            if (dto == null || dto.QuoteId == 0 || dto.TemplateVersionId == 0 || dto.MetafieldId == 0)
                return BadRequest("Invalid data");

            var result = await _metafieldService.SaveMetafieldAnswerAsync(dto);
            return Ok(new { success = result });
        }

        [HttpPost("GetMetafieldsForQuoteDetail")]
        public async Task<IActionResult> GetMetafieldsForQuoteDetail([FromBody] IdRequest request)
        {
            var result = await _metafieldService.GetMetafieldsForQuoteDetailAsync(request.Id);
            return Ok(result);
        }

        [HttpPost("GetMetafieldsForPreview")]
        public async Task<IActionResult> GetMetafieldsForPreview([FromBody] TemplateVersionRequest request)
        {
            var result = await _metafieldService.GetMetafieldsForPreviewAsync(request.TemplateVersionId);
            return Ok(result);
        }


 
        [HttpGet("GetByTemplateVersion/{templateVersionId:int}")]
        public async Task<IActionResult> GetByTemplateVersion(int templateVersionId)
        {
            if (templateVersionId <= 0)
                return BadRequest("Invalid TemplateVersionId");

            // Optional: Check if TemplateVersion exists
            var templateVersionExists = await _context.TemplateVersions
                .AnyAsync(tv => tv.TempVersionId == templateVersionId);

            if (!templateVersionExists)
                return NotFound("TemplateVersion not found");

            var metafields = await GetMetaFields(templateVersionId);

            return Ok(metafields);
        }


        [HttpPost("AddMetaField")]
        public async Task<IActionResult> AddMetaField([FromBody] MetafieldDto dto)
        {
            try
            {
                var result = await _metafieldService.AddMetaFieldAsync(dto, User.Identity.Name);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        [HttpPut("UpdateMetaField")]
        public async Task<IActionResult> UpdateMetaField([FromBody] MetafieldDto dto)
        {
            try
            {
                var result = await _metafieldService.UpdateMetaFieldAsync(dto, User.Identity.Name);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        [HttpDelete("DeleteMetaField")]
        public async Task<IActionResult> DeleteMetaField([FromBody] MetafieldDeleteRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.MetafieldGuid))
                return BadRequest("MetafieldGuid is required");

            if (!Guid.TryParse(request.MetafieldGuid, out var metafieldGuid))
                return BadRequest("Invalid MetafieldGuid format");

            var metafield = await _context.Metafields
                .FirstOrDefaultAsync(m =>
                    m.MetafieldGuid == metafieldGuid &&
                    m.TempVersionId == request.TemplateVersionId &&
                    m.IsActive);

            if (metafield == null)
                return NotFound("Metafield not found");

            var user = await Common.UserInfo(_userManager, User.Identity.Name);

            metafield.IsActive = false;
            metafield.ModifiedAt = DateTime.UtcNow;
            metafield.ModifiedById = user.UserId.ToString();

            await _context.SaveChangesAsync();

            return Ok(new { message = "Metafield deleted successfully" });
        }

        // Helper method - update to include MetafieldGuid
        private async Task<List<MetafieldDto>> GetMetaFields(int templateVersionId)
        {
            return await _context.Metafields
                .Where(m => m.TempVersionId == templateVersionId && m.IsActive)
                .OrderBy(m => m.PID)
                .Select(m => new MetafieldDto
                {
                    Id = m.PID,
                    MetafieldGuid = m.MetafieldGuid.ToString(),  // ADD THIS
                    Name = m.Name,
                    FieldType = m.FieldType,
                    Tag = m.Tag ?? "",
                    Visibility = m.Visibility
                    //TableStyle = m.TableStyle
                })
                .ToListAsync();
        }

      

    }
}
