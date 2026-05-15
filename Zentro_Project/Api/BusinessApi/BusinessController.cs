using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using zentro.Areas.Identity.Data;
using zentro.library;
using zentro.Models;
using zentro.Models;

namespace zentro.Api.BusinessApi
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class BusinessController : Controller
    {
        private  dbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;

        public BusinessController(dbContext context, UserManager<ApplicationUser> userManager, IConfiguration configuration)
        {
            _context = context;
            _userManager = userManager; 
            _configuration = configuration;
        }


        [HttpGet("GetBusinessData")]
        public async Task<IActionResult> GetBusinessData()
        {
            int currentUserId = Common.GetUserId(_context, User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
            int businessId = Common.GetUserBusinessId(_context, currentUserId);

            var businessData = await _context.Businesses
                .Where(x => x.BusinessId == businessId)
                .Select(x => new
                {
                    Name = x.Name,
                })
                .FirstOrDefaultAsync();
            if (businessData == null)
                return NotFound("Business data not found.");

            return Ok(businessData);
        }

        [HttpGet("GetBusinessCurrency")]
        public async Task<IActionResult> GetBusinessCurrency()
        {
            int currentUserId = Common.GetUserId(_context, User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
            int businessId = Common.GetUserBusinessId(_context, currentUserId);

            var businessCurrency = await _context.Businesses
                .Where(x => x.BusinessId == businessId)
                .Select(x => new
                {
                    currencyIdentity = x.CurrencyIdentity,
                    currency =x.Currency
                })
                .FirstOrDefaultAsync();
            if (businessCurrency == null)
                return NotFound("Business data not found.");

            return Ok(businessCurrency);
        }
    }
}
