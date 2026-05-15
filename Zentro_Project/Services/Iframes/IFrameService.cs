using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using zentro.Infrastructure.Security;
using zentro.Areas.Identity.Data;
using zentro.DTOs;
using zentro.IFrames;
using zentro.library;
using zentro.Models;
using zentro.Templates;
using zentro.View_Model;
using Microsoft.IdentityModel.Tokens;
using Microsoft.VisualBasic;
using System.Threading.Tasks;
namespace zentro.Services.Iframes
{
    public class IFrameService : IIFrameService
    {
        private readonly dbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public IFrameService(dbContext context,
                             IConfiguration configuration,
                             IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _configuration = configuration;
            _httpContextAccessor = httpContextAccessor;
        }

        public async Task<Iframe> GetIframeByIdAsync(int id)
        {
            return await _context.Iframes.FindAsync(id);
        }

        public async Task DeleteIframeAsync(int id)
        {
            var iframe = await _context.Iframes.FindAsync(id);
            if (iframe != null)
            {
                _context.Iframes.Remove(iframe);
                await _context.SaveChangesAsync();
            }
        }

        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }

        public async Task UpdateIframeAsync(Iframe iframe)
        {
            _context.Iframes.Update(iframe);
            await _context.SaveChangesAsync();
        }

        public async Task<Iframe> CreateAndSaveIframeAsync(
                                                            string websiteName,
                                                            int businessId,
                                                            int templateVersionId,
                                                            string token,
                                                            string key
)
        {
            var (part1, part2) = KeyGenerator.SplitKey(key);
            string baseUrl = _configuration["AppSettings:WebsiteBaseUrl"];
            string iframeUrl = $"{baseUrl}/page/template/default/{token+part2}";
            

            var iframe = new Iframe
            {
                WebsiteName = websiteName,
                Link = iframeUrl,
                TemplateId = await GetTemplateIdUsingVersionId(templateVersionId),
                TempVersionId = templateVersionId,
                Status = "Active",
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                Full_key = key,
                Partial_key = part1,
                BusinessId = GetCurrentBusinessId()

                // CreatedById = userId
            };

            _context.Iframes.Add(iframe);
            await _context.SaveChangesAsync();

            return iframe;
        }



        public async Task<int> GetLatestVersion(int incomingTempVersionID)
        {
            var templateVersion = await _context.TemplateVersions
                .FirstOrDefaultAsync(x => x.TempVersionId == incomingTempVersionID);

            if (templateVersion == null)
                throw new Exception("TempVersionID not found.");

            int templateId = templateVersion.TemplateId;

            var latest = await _context.TemplateVersions
                .Where(x => x.TemplateId == templateId)
                .OrderByDescending(x => x.TempVersion) 
                .FirstOrDefaultAsync();

            if (latest == null)
                throw new Exception("No versions found for TemplateID " + templateId);

            return latest.TempVersionId;
        }

        public async Task<int> GetLatestVersionUsingTemplateID(int templateId)
        {
            var latest = await _context.TemplateVersions
                .Where(x => x.TemplateId == templateId)
                .OrderByDescending(x => x.TempVersion) // or CreatedDate / Id if you prefer
                .FirstOrDefaultAsync();

            if (latest == null)
                throw new Exception("No versions found for TemplateID " + templateId);

            return latest.TempVersionId;
        }

        private async Task<int> GetTemplateIdUsingVersionId(int tempVersionID)
        {
            var templateVersion = await _context.TemplateVersions
                .FirstOrDefaultAsync(x => x.TempVersionId == tempVersionID);

            if (templateVersion == null)
                throw new Exception("TempVersionID not found.");

            return templateVersion.TemplateId;

        }


        public async Task<List<IframeViewModel>> GetAllIframesAsync(int tempVersionID)
        {
            var templateID = await GetTemplateIdUsingVersionId(tempVersionID);

            return await _context.Iframes
                .Where(i => i.TemplateId == templateID)
                .OrderByDescending(i => i.CreatedAt)
                .Select(i => new IframeViewModel
                {
                    Id = i.PID,
                    WebsiteName = i.WebsiteName,
                    Link = i.Link,
                    CreatedAt = i.CreatedAt,
                    Status = i.IsActive ? "Active" : "Inactive"
                })
                .ToListAsync();
        }
        public string GenerateToken(string websiteName, string key)
        {
            var payload = $"{websiteName}";
            var keyBytes = Encoding.UTF8.GetBytes(key);

            var payloadBytes = Encoding.UTF8.GetBytes(payload);

            using var hmac = new HMACSHA256(keyBytes);
            var hash = hmac.ComputeHash(payloadBytes);

            return Convert.ToBase64String(payloadBytes.Concat(hash).ToArray())
                .Replace("+", "-")
                .Replace("/", "_")
                .Replace("=", "");
        }

        public bool TryValidateToken(string token, out string websiteName)
        {
            websiteName = string.Empty;

            try
            {
                if (string.IsNullOrWhiteSpace(token))
                {
                    return false;
                }

                var (extractedToken, extractedKey) = SplitTokenAndKey(token);


                var part1 = GetDbPartOfKey(extractedKey);

                if (string.IsNullOrEmpty(part1))
                {
                    return false;
                }

                var padded = extractedToken.Replace("-", "+").Replace("_", "/");
                padded += new string('=', (4 - padded.Length % 4) % 4);

                var tokenBytes = Convert.FromBase64String(padded);

                if (tokenBytes.Length <= 32)
                {
                    return false;
                }

                var payloadBytes = tokenBytes[..^32];
                var sentHash = tokenBytes[^32..];

                var fullKey = part1 + extractedKey;
                Console.WriteLine($"[TryValidateToken] Full key for HMAC: {fullKey}");

                using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(fullKey));
                var computedHash = hmac.ComputeHash(payloadBytes);

                if (!sentHash.SequenceEqual(computedHash))
                {
                    return false;
                }

                var payloadString = Encoding.UTF8.GetString(payloadBytes);

                var parts = payloadString.Split('|');
                websiteName = parts[0];

                if (!IsThisValidKeyPart(extractedKey, websiteName))
                {
                    return false;
                }

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        private string GetDbPartOfKey(string secondPart)
        {
            if (string.IsNullOrWhiteSpace(secondPart))
            {
                return string.Empty;
            }
            // Check ALL iframes first (without IsActive filter)
            var allIframes = _context.Iframes
                .Where(r => r.Full_key != null && r.Full_key.Contains(secondPart))
                .Select(r => new { r.PID, r.WebsiteName, r.Full_key, r.Partial_key, r.IsActive })
                .ToList();

            var iframe = allIframes.FirstOrDefault(r => r.IsActive);

            if (iframe == null)
            {
                return string.Empty;
            }

            return iframe.Partial_key ?? string.Empty;
        }

        private bool IsThisValidKeyPart(string keyPart, string websiteName)
        {
            Console.WriteLine($"[IsThisValidKeyPart] keyPart: {keyPart}, websiteName: {websiteName}");

            if (string.IsNullOrWhiteSpace(keyPart) || keyPart.Length != 32)
            {
                Console.WriteLine($"[IsThisValidKeyPart] FAILED: keyPart is invalid. Length: {keyPart?.Length ?? 0}");
                return false;
            }

            var iframe = _context.Iframes
                .Where(r => r.Full_key != null && r.Full_key.EndsWith(keyPart) && r.IsActive)
                .Select(r => new { r.Full_key, r.Partial_key, r.WebsiteName, r.IsActive })
                .FirstOrDefault();

            if (iframe == null)
            {
                return false;
            }


            // Verify the websiteName matches
            if (iframe.WebsiteName != websiteName)
            {
                return false;
            }

            if (string.IsNullOrEmpty(iframe.Full_key) || string.IsNullOrEmpty(iframe.Partial_key))
            {
                return false;
            }

            var expected = iframe.Partial_key + keyPart;
            var matches = iframe.Full_key == expected;


            return matches;
        }
        public int GetTemplateId(string keyPart)
        {
            if (string.IsNullOrWhiteSpace(keyPart) || keyPart.Length != 32)
                return 0;

            var templateId = _context.Iframes
                .Where(r => r.Full_key != null && r.Full_key.EndsWith(keyPart) && r.IsActive)
                .Select(r => r.TemplateId)  
                .FirstOrDefault();

            return templateId;
        }

        //public int GetTemplateId(string websiteName)
        //{
        //    var lnk = _context.Iframes.Where(r => r.WebsiteName == websiteName).FirstOrDefault();

        //    if (lnk == null) return 0;

        //    return lnk.TempVersionId;
        //}
        private (string Token, string KeyPart) SplitTokenAndKey(string combined)
        {
            const int KeyPartLength = 32;

            if (string.IsNullOrWhiteSpace(combined))
                throw new ArgumentException("Combined value cannot be null or empty.");

            if (combined.Length <= KeyPartLength)
                throw new ArgumentException("Combined value is too short to contain a key part.");

            string keyPart = combined.Substring(combined.Length - KeyPartLength, KeyPartLength);
            string token = combined.Substring(0, combined.Length - KeyPartLength);

            return (token, keyPart);
        }

    }
}
