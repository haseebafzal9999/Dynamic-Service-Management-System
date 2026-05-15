using zentro.Models;

namespace zentro.Services.Questions
{
    namespace zentro.Services.Questions
    {
        public interface IQuestionService
        {
            public Task<QuestionResponse> CreateOrUpdateQuestionAsync(QuestionRequest request);
            public Task<bool> DeleteQuestionAsync(int questionId);
            public Task<bool> DeleteQuestionbyGuidAsync(string questionGuid, int templateVersionId);
        }
    }
}
