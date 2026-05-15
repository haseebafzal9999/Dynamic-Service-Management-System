using Independentsoft.Office.Odf;
using Independentsoft.Office.Odf.Charts;
using Independentsoft.Office.Odf.Styles;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Build.Framework;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Globalization;
using System.Net.Http;
using System.Security.Claims;
using System.Text;
using zentro.Api.TemplateApi;
using zentro.View_Model;
using zentro.Areas.Identity.Data;
using zentro.library;
using zentro.Models;
using zentro.Templates;
//using zentro.View_Model;
using System.Net.Http;
using System.Net.Http.Json;
using zentro.Quote;
using zentro.Services;
using zentro.TemplateItems;
using Independentsoft.Office.Odf.Fields;
namespace zentro.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        private readonly IQuoteService _quoteService;

        private readonly ILogger<HomeController> _logger;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly dbContext _context;
        private static ConcurrentDictionary<int, DateTime> LastLoadTimes = new ConcurrentDictionary<int, DateTime>();
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ITemplateItemsService _templateItemsService;


        public HomeController(ILogger<HomeController> logger, UserManager<ApplicationUser> userManager, dbContext context,
            IHttpClientFactory httpClientFactory, IConfiguration configuration, IQuoteService quoteService, ITemplateItemsService templateItemsService)
       
        {
            _logger = logger;
            _userManager = userManager;
            _context = context;
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _quoteService = quoteService;
            _templateItemsService = templateItemsService;


        }

        public async Task<IActionResult> Index()
        {
            ViewData["PageName"] = "Home";
            return View(await Common.UserInfo(_userManager, User.Identity.Name));
        }

        public async Task<IActionResult> Quotes()
        {
            //add business logic

            ViewData["PageName"] = "Quotes";
            return View("Views/Quotes/QuotesIndex.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }
        [HttpGet]
        [Route("page/quote/{id}")]
        public async Task<IActionResult> QuoteDetails(int id)
        {
            return View("Views/Quotes/QuoteDetails.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }



        public async Task<IActionResult> Customer()
        {
            ViewData["PageName"] = "Customers";
            return View("Views/Customers/CustomerIndex.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }

        public async Task<IActionResult> Components()
        {
            ViewData["PageName"] = "Components";
            return View("Views/Components/ComponentIndex.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }

        public async Task<IActionResult> Materials()
        {
            ViewData["PageName"] = "Materials";
            return View("Views/Materials/MaterialIndex.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }

        public async Task<IActionResult> Templates()
        {
            ViewData["PageName"] = "Templates";
            return View("Views/Templates/TemplateIndex.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }

        public async Task<IActionResult> TemplateDetail(int? id)
        {
            ViewData["TempVersionId"] = id;

            ViewData["PageName"] = "Templates";

            return View("Views/Templates/TemplateDetail.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }

        public async Task<IActionResult> TemplatePreview(int? id)
        {
            ViewData["PageName"] = "Template";
            ViewData["TemplateVersionId"] = id.Value;
            
            return View("Views/Templates/TemplatePreview.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }
        
        [AllowAnonymous]
        [HttpGet("page/template/default/{token}")]
        public async Task<IActionResult> TemplateDefault(string token)
        {
            ViewData["Token"] = token;

            var iframe = await _context.Iframes.FirstOrDefaultAsync(i => i.Link.Contains(token));

            if (iframe == null || !iframe.IsActive)
            {
                return RedirectToAction("NotFoundError", "Error");
            }

            return View("Views/Templates/Default.cshtml");
        }

        public async Task<IActionResult> CreateQuote(int id, int customerId)
        {
            ViewData["QuoteId"] = id;
            ViewData["CustomerId"] = customerId;
            ViewData["PageName"] = "Quotes";

            return View("Views/Quotes/CreateQuote.cshtml", await Common.UserInfo(_userManager, User.Identity.Name));
        }


        public static string FormatCurrency(decimal? amount, string cultureName)
        {
            var culture = new CultureInfo(cultureName);
            return string.Format(culture, "{0:C}", amount);
        }


        public IActionResult SubmitQuestionnaire(string quoteRef, int recordId)
        {
            ViewBag.QuoteRef = quoteRef;
            ViewBag.RecordId = recordId;
            return View();
        }
        [HttpGet]
        public async Task<IActionResult> SubmitQuestionnaireJson(int recordId)
        {
            var userRecord = await _context.UserRecords.FindAsync(recordId);
            if (userRecord == null)
                return NotFound();

            var customerName = await _context.Customers
                .Where(c => c.CustomerId == userRecord.CustomerId)
                .Select(c => c.FirstName + " " + c.LastName)
                .FirstOrDefaultAsync();

            return Json(new
            {
                RecStatusId = userRecord.RecStatusId,
                TemplateId = userRecord.TemplateId,
                TemplateVersion = userRecord.TempVersionId,
                CustomerId = userRecord.CustomerId,
                CustomerName = customerName ?? "Unknown Customer"
            });
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

    }
}
