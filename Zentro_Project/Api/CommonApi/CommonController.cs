using Microsoft.AspNetCore.Mvc;
using zentro.DTOs;
using zentro.Templates;
using zentro.View_Model;

namespace Vscale_Fleet_Solutions.Api.CommonApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class CommonController : ControllerBase
    {
        private readonly ITemplateService _templateService;
        public CommonController( ITemplateService templateService)
        {
            _templateService = templateService;
        }

        [HttpGet("GetTemplateDetais")]
        public IActionResult GetTemplateDetais(int templateVersionId = 0)
        {
           var result = GetNormalizedList(GetFlatTemplateDetails(templateVersionId));
           return Ok(result);
        }

        [HttpGet("GetDependentQuestionDetais")]
        public IActionResult GetDependentQuestionDetais(int templateVersionId = 0, int dependentQuestionId=0)
        {
            var result = GetNormalizedList(GetFlatDependentQuestionDetails(templateVersionId,dependentQuestionId));
            return Ok(result);
        }

        private List<TemplateDetails> GetFlatTemplateDetails(int templateVersionId)
        {
           return _templateService.FlatTemplateDetails(templateVersionId);
        }

        private List<TemplateDetails> GetFlatDependentQuestionDetails(int templateVersionId, int questionOptionId)
        {
            return _templateService.FlatDependentQuestionDetails(templateVersionId, questionOptionId);
        }

        private List<QuestionGroupDto> GetNormalizedList( List<TemplateDetails> flatList)
        {
            return _templateService.NormalizedList(flatList);
        }

    }
}
