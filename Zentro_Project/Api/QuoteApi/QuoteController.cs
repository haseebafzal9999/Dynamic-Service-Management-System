using Azure.Core;
using Independentsoft.Office.Odf.Fields;
using Independentsoft.Office.Odf;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Concurrent;
using System.Linq;
using System.Security.Claims;
//using zentro.DTOs;
using zentro.Areas.Identity.Data;
using zentro.Controllers;
using zentro.DTOs;
using zentro.Models;
using zentro.Templates;
using zentro.View_Model;
using Microsoft.AspNetCore.Authorization;
using zentro.Quote;
using zentro.library;

namespace zentro.Api.QuoteApi

{
    [Route("api/[controller]")]
    [ApiController]
    public class QuoteController : ControllerBase
    {
        private readonly ILogger<HomeController> _logger;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly dbContext _context;
        private static ConcurrentDictionary<int, DateTime> LastLoadTimes = new ConcurrentDictionary<int, DateTime>();
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ITemplateService _templateService;
        private readonly IQuoteService _quoteService;

        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            // This handles both admin and customer users according to your shared logic
            return Common.GetUserBusinessId(_context, userId);
        }
        public QuoteController(ILogger<HomeController> logger, UserManager<ApplicationUser> userManager, dbContext context,
            IHttpClientFactory httpClientFactory, IConfiguration configuration, IHttpContextAccessor httpContextAccessor,
            ITemplateService templateService, IQuoteService quoteService)
        {
            _logger = logger;
            _userManager = userManager;
            _context = context;
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _httpContextAccessor = httpContextAccessor;
            _templateService = templateService;
            _quoteService = quoteService;
        }


        [HttpGet("QuoteTable")]
        public IActionResult GetQuoteTable()
        {
            var businessId = GetCurrentBusinessId();
            var data = (from r in _context.UserRecords
                        join c in _context.Customers on r.CustomerId equals c.CustomerId
                        join t in _context.Templates on r.TemplateId equals t.TemplateId
                        where c.BusinessId == businessId
                        orderby r.CreatedAt descending
                        select new
                        {
                            quoteNumber = r.QuoteReference,
                            name = c.FirstName + " " + c.LastName,
                            email = c.Email,
                            phoneNumber = c.PhoneNumber,
                            templateName = t.TemplateName,
                            costPrice = r.TotalCostPrice,
                            sellPrice = r.TotalSellPrice,
                            status = r.Status,
                            id = r.RecStatusId,
                            link = r.RecStatusId
                        })
               .ToList();

            return Ok(data);
        }

        [HttpGet("LatestTemplate")]
        public IActionResult LatestTemplate()
        {
            var latestTemplateVersions = (
                                       from t in _context.Templates
                                       join v in (
                                           from tv in _context.TemplateVersions
                                           group tv by tv.TemplateId into g
                                           select new
                                           {
                                               TemplateId = g.Key,
                                               LatestVersionId = g.Max(x => x.TempVersionId)
                                           }
                                       ) on t.TemplateId equals v.TemplateId
                                       where t.IsActive
                                       select new
                                       {
                                           t.TemplateId,
                                           t.TemplateName,
                                           v.LatestVersionId
                                       }
                                   ).ToList();


            return Ok(latestTemplateVersions);
        }

        [HttpGet("Customers")]
        public IActionResult GetCustomers()
        {
            var businessId = GetCurrentBusinessId();
            var customers = _context.Customers//.Where(r=>r.IsActive==true)
                .Where(c => c.BusinessId == businessId)
                .Select(c => new { c.CustomerId, Name = c.FirstName + " " + c.LastName })
                .ToList();
            return Ok(customers);
        }

        [HttpGet("FilterQuoteIndex")]
        public IActionResult FilterQuoteIndex([FromQuery] string[] Status)
        {
            var businessId = GetCurrentBusinessId();
            var query = from r in _context.UserRecords
                        join c in _context.Customers on r.CustomerId equals c.CustomerId
                        join t in _context.Templates on r.TemplateId equals t.TemplateId
                        where c.BusinessId == businessId
                        select new
                        {
                            QuoteNumber = r.QuoteReference,
                            Name = c.FirstName + " " + c.LastName,
                            Email = c.Email,
                            PhoneNumber = c.PhoneNumber,
                            TemplateName = t.TemplateName,
                            CostPrice = r.TotalCostPrice,
                            SellPrice = r.TotalSellPrice,
                            Status = r.Status,
                            id = r.RecStatusId,
                            link = r.RecStatusId,
                            CreatedAt = r.CreatedAt
                        };

            if (Status != null && Status.Length > 0)
            {
                var statusList = Status
                    .Where(s => !string.IsNullOrWhiteSpace(s))
                    .Select(s => s.Trim().ToLower())
                    .ToList();

                query = query.Where(x => !string.IsNullOrEmpty(x.Status) && statusList.Contains(x.Status.ToLower()));
            }

            var results = query.OrderByDescending(x => x.CreatedAt).ToList();

            string? search = null;

            if (Request.Query.TryGetValue("search", out var searchVal) && !string.IsNullOrWhiteSpace(searchVal))
                search = searchVal.ToString();
            else if (Request.Query.TryGetValue("sT", out var sTVal) && !string.IsNullOrWhiteSpace(sTVal))
                search = sTVal.ToString();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.Trim();
                if (s.StartsWith("q", System.StringComparison.OrdinalIgnoreCase))
                    s = s.Substring(1).Trim();

                s = s.ToLower();

                results = results.Where(x =>
                    (!string.IsNullOrEmpty(x.QuoteNumber) && x.QuoteNumber.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.Name) && x.Name.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.Email) && x.Email.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.PhoneNumber) && x.PhoneNumber.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.TemplateName) && x.TemplateName.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.Status) && x.Status.ToLower().Contains(s))
                ).ToList();
            }

            var formattedResults = results.Select(x => new
            {
                QuoteNumber = x.QuoteNumber,
                Name = x.Name,
                Email = x.Email,
                PhoneNumber = x.PhoneNumber,
                TemplateName = x.TemplateName,
                CostPrice = x.CostPrice,
                SellPrice = x.SellPrice,
                Status = x.Status,
                id = x.id,
                link = x.link,
                CreatedAt = x.CreatedAt
            }).ToList();

            return Ok(new { lists = formattedResults });


        }

        // GET: api/Quote/QuoteFilterLists
        [HttpGet("QuoteFilterLists")]
        public IActionResult QuoteFilterLists()
        {
            var statusList = _context.UserRecords
                .Where(r => !string.IsNullOrEmpty(r.Status))
                .Select(r => r.Status)
                .Distinct()
                .OrderBy(s => s)
                .Select(s => new { value = s, name = s })
                .ToList();

            var lists = new
            {
                statusLists = statusList
            };

            return new JsonResult(new { lists = new List<object> { lists } });
        }



        [HttpPost("CreateQuoteOnly")]
        public async Task<ActionResult<UserAnswerVM>> CreateQuoteOnlyAsync([FromBody] CreateQuoteRequest request)
        {
            var recStatusId = await _quoteService.CreateQuoteRecordAsync(request);
            return Ok(recStatusId);
        }

        //  CREATE QUOTE ENDPOINTS 

        [HttpPost("GetTemplateForCreateQuote")]
        public async Task<IActionResult> GetTemplateForCreateQuote([FromBody] IdRequest request)
        {
            var result = await _quoteService.GetTemplateDataForCreateQuoteAsync(request.Id);
            return Ok(result);
        }

        [HttpPost("GetDependentQuestionsForCreateQuote")]
        public async Task<IActionResult> GetDependentQuestionsForCreateQuote([FromBody] GetDependentRequest request)
        {
            var result = await _quoteService.GetDependentQuestionsForCreateQuoteAsync(request.QuoteId, request.QuestionOptionId);
            return Ok(result);
        }


        //  QUOTE DETAIL ENDPOINTS 

        [HttpPost("GetQuoteDetails")]
        public async Task<IActionResult> GetQuoteDetails([FromBody] IdRequest request)
        {
            try
            {
                var result = await _quoteService.GetQuoteDetailsAsync(request.Id);
                // Use dynamic to access 'success' property of anonymous object
                var dyn = result as dynamic;
                if (dyn != null && dyn.success == false)
                    return BadRequest(result);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("GetDependentQuestionsForQuote")]
        public IActionResult GetDependentQuestionsForQuote([FromBody] GetDependentRequest request)
        {
            try
            {
                var result = _quoteService.GetDependentQuestionsForQuote(request.QuoteId, request.QuestionOptionId);
                var dyn = result as dynamic;
                if (dyn != null && dyn.success == false)
                    return BadRequest(result);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        // DEFAULT TEMPLATE ENDPOINTS

        [HttpGet("GetLatestTemplateForDefault")]
        [AllowAnonymous]
        public async Task<IActionResult> GetLatestTemplateForDefault()
        {
            var result = await _quoteService.GetLatestTemplateForDefaultAsync();
            var dyn = result as dynamic;
            if (dyn != null && dyn.success == false)
                return BadRequest(result);
            return Ok(result);
        }
        [HttpGet("GetTemplateForDefaultToken")]
        [AllowAnonymous]
        public async Task<IActionResult> GetTemplateForDefaultToken([FromQuery] int templateId)
        {
            var result = await _quoteService.GetLatestTemplateForDefaultAsync(templateId);

            var dyn = result as dynamic;
            if (dyn != null && dyn.success == false)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("GetDependentQuestionsForDefault")]
        [AllowAnonymous]
        public IActionResult GetDependentQuestionsForDefault([FromBody] GetDependentForDefaultRequest request)
        {
            var result = _quoteService.GetDependentQuestionsForDefault(request.TemplateVersionId, request.QuestionOptionId);
            var dyn = result as dynamic;
            if (dyn != null && dyn.success == false)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpGet("IsAllRequiredAnsweredForDefault")]
        [AllowAnonymous]
        public async Task<IActionResult> IsAllRequiredAnsweredForDefault(int templateVersionId, [FromQuery] int[] answeredQuestionIds)
        {
            // ✅ DEBUG: Log incoming parameters
            _logger.LogInformation($"IsAllRequiredAnsweredForDefault called with templateVersionId={templateVersionId}");
            _logger.LogInformation($"Answered Question IDs: {string.Join(", ", answeredQuestionIds ?? Array.Empty<int>())}");

            // Get all required questions for this template
            var requiredQuestions = await _context.Questions
                .Where(q => q.TemplateVersionId == templateVersionId && q.IsRequired)
                .Select(q => q.QuestionId)
                .ToListAsync();

            // ✅ DEBUG: Log required questions found
            _logger.LogInformation($"Required Questions for Version {templateVersionId}: {string.Join(", ", requiredQuestions)}");

            if (requiredQuestions.Count == 0)
                return Ok(new { allAnswered = true, hasRequired = false });

            // Check if every required question is answered
            bool allAnswered = requiredQuestions.All(qid => answeredQuestionIds.Contains(qid));

            // ✅ DEBUG: Log result
            _logger.LogInformation($"All Answered: {allAnswered}");

            return Ok(new { allAnswered, hasRequired = true });
        }

        [HttpPost("CreateAndSaveQuote")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateAndSaveQuote([FromBody] CreateAndSaveQuoteRequest request)
        {
            var result = await _quoteService.CreateAndSaveQuoteAsync(request);
            var dyn = result as dynamic;
            if (dyn != null && dyn.success == false)
                return BadRequest(result);
            return Ok(result);
        }

        // End of Default Page

        [HttpPost("CreateRevision")]
        public async Task<IActionResult> CreateRevision(int templateId, int customerId, int recStatusId)
        {
            var userAnswerVM = await _quoteService.CreateRevisionAsync(templateId, customerId);
            return Ok(new
            {
                success = true,
                message = "Revision data prepared successfully.",
                recStatusId = userAnswerVM.RecStatusId
            });
        }
    }
}