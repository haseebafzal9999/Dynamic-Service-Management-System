using zentro.Models;
using zentro.View_Model;

namespace zentro.TemplateItems
{
    public interface ITemplateItemsService
    {
        Task<(bool Success, string Message)> CreateQuotePostAsync(UserAnswerVM model, string currency = "en-GB");

        List<string> GetTemplateItemSuggestions(string type, string query, int recStatusId, int customerId);
        Task<List<TemplateItem>> GetItemsByTemplateIdAsync(int templateId);
        Task<bool> CheckTemplatesAsync(int quoteId);
        Task<QuoteDetailsResult> GetQuoteDetailsAsync(int id);
        Task<(bool Success, string Message, byte[] FileBytes, string FileName)> DownloadQuoteAsync(int quoteId);
    }
}
