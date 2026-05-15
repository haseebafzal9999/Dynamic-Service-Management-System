using zentro.DTOs;

namespace zentro.Services.Metafield
{
    public interface IMetafieldService
    {
        Task<object> GetMetafieldsForCreateQuoteAsync(int quoteId);
        Task<bool> SaveMetafieldAnswerAsync(MetafieldAnswerDto dto);
        Task<object> GetMetafieldsForQuoteDetailAsync(int quoteId);
        Task<object> GetMetafieldsForPreviewAsync(int templateVersionId);
        Task<bool> SaveMetafieldAnswersBulkAsync(MetafieldAnswerBulkDto dto);

        Task<object> AddMetaFieldAsync(MetafieldDto dto, string userName);
        Task<object> UpdateMetaFieldAsync(MetafieldDto dto, string userName);



    }
}
