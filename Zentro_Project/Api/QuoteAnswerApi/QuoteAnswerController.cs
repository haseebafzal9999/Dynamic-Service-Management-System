using System.Collections.Concurrent;
using System.Security.Claims;
using Azure.Core;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Vscale_Fleet_Solutions.DTOs;
using zentro.Areas.Identity.Data;
using zentro.Controllers;
using zentro.DTOs;
using zentro.Models;
using zentro.Quote;
using zentro.Templates;
using zentro.library;

namespace Vscale_Fleet_Solutions.Api.QuoteAnswerApi
{
    [Route("api/[controller]")]
    [ApiController]


    public class QuoteAnswerController : ControllerBase
    {
        //private readonly dbContext _context;
        //private readonly IQuoteService _quoteService;


        //public QuoteAnswerController(dbContext context, IQuoteService quoteService)
        //{
        //    _context = context;
        //    _quoteService = quoteService;
        //}

        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IQuoteService _quoteService;
        public QuoteAnswerController( dbContext context,
           IHttpContextAccessor httpContextAccessor,
            IQuoteService quoteService)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _quoteService = quoteService;
        }

        [HttpGet("IsAllRequiredAnswered")]
        public async Task<IActionResult> IsAllRequiredAnswered(int quoteId, int quoteVersionId = 1)
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            int businessId = Common.GetUserBusinessId(_context, userId);
            var (allAnswered, hasRequired) = await _quoteService.IsAllRequiredAnsweredAsync(quoteId, quoteVersionId);
            return Ok(new { allAnswered, hasRequired });

        }


        [HttpPost("AddQuoteAnswer")]
        public async Task<IActionResult> AddQuoteAnswer([FromBody] QuoteAnswerRequest request)
        {
            var response = await _quoteService.AddQuoteAnswerAsync(request);
            return Ok(response);
        }

        [HttpPost("RemoveQuoteAnswer")]
        public async Task<IActionResult> RemoveQuoteAnswer([FromBody] QuoteAnswerRequest request)
        {
            var response = await _quoteService.RemoveQuoteAnswerAsync(request);
            return Ok(response);
        }

        // QuoteDetail (QuoteVersionId = 2)

        [HttpPost("AddQuoteDetailAnswer")]
        public async Task<IActionResult> AddQuoteDetailAnswer([FromBody] QuoteAnswerRequest request)
        {
            var response = await _quoteService.AddQuoteDetailAnswerAsync(request);
            if (response.Success)
                return Ok(response);
            return BadRequest(response);
        }

        [HttpPost("RemoveQuoteDetailAnswer")]
        public async Task<IActionResult> RemoveQuoteDetailAnswer([FromBody] QuoteAnswerRequest request)
        {
            var response = await _quoteService.RemoveQuoteDetailAnswerAsync(request);
            if (response.Success)
                return Ok(response);
            return BadRequest(response);

        }

    }
}