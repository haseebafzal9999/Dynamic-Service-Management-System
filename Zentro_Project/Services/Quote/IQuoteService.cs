using zentro.View_Model;
using System.Threading.Tasks;
using zentro.DTOs;
using Vscale_Fleet_Solutions.DTOs;

namespace zentro.Quote
{
    public interface IQuoteService
    {
        Task<UserAnswerVM> CreateRevisionAsync(int templateId, int customerId);
        
        //CreateQuote Interfaces:
        Task<int> CreateQuoteRecordAsync(CreateQuoteRequest request);
        Task<object> GetTemplateDataForCreateQuoteAsync(int quoteId);
        Task<object> GetDependentQuestionsForCreateQuoteAsync(int quoteId, int questionOptionId);
 
        Task<(bool allAnswered, bool hasRequired)> IsAllRequiredAnsweredAsync(int quoteId, int quoteVersionId = 1);
        Task<QuoteAnswerResponse> AddQuoteAnswerAsync(QuoteAnswerRequest request);
        Task<QuoteAnswerResponse> RemoveQuoteAnswerAsync(QuoteAnswerRequest request);

        Task<QuoteAnswerResponse> AddQuoteDetailAnswerAsync(QuoteAnswerRequest request);
        Task<QuoteAnswerResponse> RemoveQuoteDetailAnswerAsync(QuoteAnswerRequest request);


        Task<object> GetQuoteDetailsAsync(int recStatusId);
        object GetDependentQuestionsForQuote(int recStatusId, int questionOptionId);

        Task<object> GetLatestTemplateForDefaultAsync(int templateVersionId = 0);
        object GetDependentQuestionsForDefault(int templateVersionId, int questionOptionId);
        Task<object> IsAllRequiredAnsweredForDefaultAsync(int templateVersionId, int[] answeredQuestionIds);
        Task<object> CreateAndSaveQuoteAsync(CreateAndSaveQuoteRequest request);



    }
}