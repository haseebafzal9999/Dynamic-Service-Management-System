using System.Security.Claims;
using zentro.DTOs;
using zentro.Models;
using zentro.View_Model;

namespace zentro.IFrames
{
    public interface IIFrameService
    {
        Task<Iframe> CreateAndSaveIframeAsync(string websiteName, int businessId, int templateVersionId, string token, string key);
        Task<List<IframeViewModel>> GetAllIframesAsync(int tempVersionID);
        Task<int> GetLatestVersion(int incomingTempVersionID);
        string GenerateToken(string websiteName, string key);
        bool TryValidateToken(string token, out string websiteName);
        int GetTemplateId(string websiteName);
        Task<int> GetLatestVersionUsingTemplateID(int templateId);

        Task<Iframe> GetIframeByIdAsync(int id);
        Task DeleteIframeAsync(int id);
        Task UpdateIframeAsync(Iframe iframe);
    }
}
