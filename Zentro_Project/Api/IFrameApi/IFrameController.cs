using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using zentro.Areas.Identity.Data;
using zentro.DTOs;
using zentro.IFrames;
using zentro.Infrastructure.Security;
using zentro.library;
using zentro.Models;
using zentro.Templates;
using zentro.View_Model;
namespace zentro.Api.IFrameApi
{
    [ApiController]
    [Route("api/[controller]")]
    public class IFrameController : ControllerBase
    {
        private readonly IIFrameService _iframeService;

        public IFrameController(IIFrameService iframeService)
        {
            _iframeService = iframeService;
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> DeleteIframe(int id)
        {
            var iframe = await _iframeService.GetIframeByIdAsync(id);
            if (iframe == null)
                return NotFound();

            await _iframeService.DeleteIframeAsync(id);
            return Ok(new { success = true });
        }

        [HttpPost("deactivate/{id}")]
        public async Task<IActionResult> DeactivateIframe(int id)
        {
            var iframe = await _iframeService.GetIframeByIdAsync(id);
            if (iframe == null)
                return NotFound();

            iframe.IsActive = false;
            await _iframeService.UpdateIframeAsync(iframe);

            return Ok(new { success = true });
        }


        [HttpPost("generate")]
        public async Task<IActionResult> GenerateToken([FromBody] GenerateIframeTokenRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.WebsiteName))
                return BadRequest("WebsiteName is required.");

            string key = KeyGenerator.GenerateKey();

            var token = _iframeService.GenerateToken(
                request.WebsiteName,
                key
            );

            var iframe = await _iframeService.CreateAndSaveIframeAsync(
                request.WebsiteName,
                request.BusinessId,
                request.TemplateVersionId,
                token,
                key
            );

            return Ok(new
            {
                id = iframe.PID,
                websiteName = iframe.WebsiteName,
                link = iframe.Link,
                createdAt = iframe.CreatedAt,
                status = iframe.Status
            });
        }


        [HttpGet("GetAllIframes")]
        public async Task<IActionResult> GetAllIframes(int tempVersionID)
        {
            var items = await _iframeService.GetAllIframesAsync(tempVersionID);
            return Ok(items);
        }
        [HttpGet("DecodeToken")]
        public IActionResult DecodeToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
                return BadRequest(new { error = "Token is required" });

            token = System.Net.WebUtility.UrlDecode(token);

            bool isValid = _iframeService.TryValidateToken(token, out string websiteName);

            if (!isValid)
                return BadRequest(new { error = "Invalid token" });

            // ✅ Extract keyPart from token and use it
            string keyPart = token.Length > 32 ? token.Substring(token.Length - 32) : "";
            int templateVersionId = _iframeService.GetTemplateId(keyPart);

            if (templateVersionId == 0)
                return BadRequest(new { error = "Template not found" });

            return Ok(templateVersionId);
        }

    }
}
