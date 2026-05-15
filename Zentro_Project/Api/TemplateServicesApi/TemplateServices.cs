using Microsoft.AspNetCore.Mvc;
using zentro.TemplateItems;
using zentro.View_Model;

[Route("api/[controller]")]
[ApiController]
public class TemplateItemsController : ControllerBase
{
    private readonly ITemplateItemsService _service;

    public TemplateItemsController(ITemplateItemsService service)
    {
        _service = service;
    }

    [HttpGet("GetItems")]
    public async Task<IActionResult> GetItems(int quoteId)
    {
        var items = await _service.GetItemsByTemplateIdAsync(quoteId);
        return Ok(items);
    }
    [HttpPost("CreateQuote")]
    public async Task<IActionResult> CreateQuote([FromBody] UserAnswerVM model, string currency = "en-GB")
    {
        if (model.TemplateId == null || model.TemplateVersion == null)
        {
            return BadRequest(new
            {
                success = false,
                message = "TemplateId or TemplateVersion missing."
            });

        }

        var (success, message) = await _service.CreateQuotePostAsync(model, currency);

        return Ok(new { success, message });

    }
    [HttpGet("GetTemplateItemSuggestions")]
    public IActionResult GetTemplateItemSuggestions(string type, string query, int recStatusId, int customerId)
    {
        var suggestions = _service.GetTemplateItemSuggestions(type, query, recStatusId, customerId);
        return Ok(suggestions);
    }
    [HttpGet ("CheckTemplateItems")]
    public async Task<IActionResult> CheckTemplateItems(int quoteId)
    {
        bool exists = await _service.CheckTemplatesAsync(quoteId);
        return new JsonResult(new { exists }); // or Ok(new { exists })
    }
    [HttpGet("{id}")]
    public async Task<IActionResult> GetQuoteDetails(int id)
    {
        var result = await _service.GetQuoteDetailsAsync(id);

        if (!result.Exists)
            return NotFound(new { message = "Quote not found" });

        return Ok(result);
    }
    [HttpGet("DownloadPDF/{quoteId}")]
    public async Task<IActionResult> DownloadPDF(int quoteId)
    {
        var result = await _service.DownloadQuoteAsync(quoteId);

        if (!result.Success)
            return Ok(new { success = false, message = result.Message });

        return File(result.FileBytes, "application/pdf", result.FileName);
    }

}
