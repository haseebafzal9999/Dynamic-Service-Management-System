using zentro.DTOs;
using zentro.View_Model;

namespace zentro.Templates
{
    public interface ITemplateService
    {
        List<TemplateDetails> FlatTemplateDetails(int templateVersionId);
        List<TemplateDetails> FlatDependentQuestionDetails(int templateVersionId, int questionOptionId);
        List<QuestionGroupDto> NormalizedList(List<TemplateDetails> flatList);

        Task<TemplateBuilderVM> GetTemplateDetail(int? id);
    }
}
