using System.Threading.Tasks;
using zentro.Models;

namespace zentro.Services.TemplatesVersion
{
    public interface ITemplateVersionCheckService
    {
        Task<int> CloneTemplateVersionAsync(int sourceTemplateVersionId , string modifiedById);

    }
}
