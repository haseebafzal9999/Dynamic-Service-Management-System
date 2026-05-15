using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using zentro.Areas.Identity.Data;
using zentro.Models;
using zentro.View_Model;
using zentro.library;

namespace zentro.Api.TemplateApi
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class QuestionController : Controller
    {
        private readonly dbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public QuestionController(dbContext context, UserManager<ApplicationUser> userManager, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _userManager = userManager;
            _httpContextAccessor = httpContextAccessor;
        }
        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }

        
        [HttpGet]
        public async Task<IActionResult> GetComponents()
        {
            var businessId = GetCurrentBusinessId();
            var components = await _context.Components
                .Where(c => c.IsActive == true && c.BusinessId == businessId)
                .Select(c => new { value = c.ComponentId, text = c.Name })
                .ToListAsync();

            return Json(components);
        }

        [HttpGet]
        public async Task<IActionResult> GetMaterials()
        {
            var businessId = GetCurrentBusinessId();
            var materials = await _context.Materials
                .Where(m => m.IsActive == true && m.BusinessId == businessId)
                .Select(m => new { value = m.MaterialId, text = m.Name })
                .ToListAsync();

            return Json(materials);
        }
    }
}
