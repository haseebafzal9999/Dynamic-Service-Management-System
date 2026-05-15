using Microsoft.EntityFrameworkCore;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
using zentro.library;
using zentro.Models;

namespace zentro.Services.Group
{
    public class GroupService : IGroupService
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;



        public GroupService(dbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }


        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }

        public async Task<GroupResponse> CreateOrUpdateGroupAsync(GroupRequest request)
        {
            try
            {
                // 1️⃣ Validate Template Version
                var templateVersion = await _context.TemplateVersions
                    .AsNoTracking()
                    .FirstOrDefaultAsync(tv => tv.TempVersionId == request.TemplateVersionId);

                if (templateVersion == null)
                    throw new Exception($"TemplateVersion {request.TemplateVersionId} not found");

                QuestionGroup group;

                Guid? groupGuid = null;
                if (!string.IsNullOrWhiteSpace(request.GroupGuid) &&
                    Guid.TryParse(request.GroupGuid, out var parsedGuid))
                {
                    groupGuid = parsedGuid;
                }

                // 2️⃣ CASE: NEW GROUP (no GUID)
                if (groupGuid == null)
                {
                    group = new QuestionGroup
                    {
                        Name = request.Name,
                        DisplayOrder = request.Order,
                        TemplateVersionId = request.TemplateVersionId,
                        TemplateId = templateVersion.TemplateId,
                        GroupGuid = Guid.NewGuid(),
                        CreatedAt = DateTime.UtcNow,
                        IsActive = true,
                        BusinessId = GetCurrentBusinessId()
                    };

                    _context.QuestionGroups.Add(group);
                    await _context.SaveChangesAsync();

                    return BuildResponse(group);
                }

                // 3️⃣ CASE: UPDATE OR CLONE

                // 🔥 MOST IMPORTANT QUERY
                var groupInCurrentVersion = await _context.QuestionGroups
                    .FirstOrDefaultAsync(g =>
                        g.GroupGuid == groupGuid &&
                        g.TemplateVersionId == request.TemplateVersionId &&
                        g.IsActive
                    );

                if (groupInCurrentVersion != null)
                {
                    // ✅ UPDATE (no clone)
                    groupInCurrentVersion.Name = request.Name;
                    groupInCurrentVersion.DisplayOrder = request.Order;
                    groupInCurrentVersion.ModifiedAt = DateTime.UtcNow;

                    await _context.SaveChangesAsync();
                    return BuildResponse(groupInCurrentVersion);
                }

                // 4️⃣ CLONE FROM LATEST PREVIOUS VERSION
                var previousGroup = await _context.QuestionGroups
                    .Where(g => g.GroupGuid == groupGuid && g.IsActive)
                    .OrderByDescending(g => g.TemplateVersionId)
                    .FirstOrDefaultAsync();

                if (previousGroup == null)
                    throw new Exception("Previous group not found for cloning");

                group = new QuestionGroup
                {
                    Name = request.Name,
                    DisplayOrder = request.Order,
                    TemplateVersionId = request.TemplateVersionId,
                    TemplateId = templateVersion.TemplateId,
                    GroupGuid = previousGroup.GroupGuid,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true,
                    BusinessId = GetCurrentBusinessId()
                };

                _context.QuestionGroups.Add(group);
                await _context.SaveChangesAsync();

                return BuildResponse(group);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"CreateOrUpdateGroupAsync ERROR: {ex}");
                throw;
            }
        }


        public async Task<bool> DeleteGroupAsync(int groupId)
        {
            // Keep this method for backward compatibility with ID-based calls
            var group = await _context.QuestionGroups
                .FirstOrDefaultAsync(g => g.QuestionGroupId == groupId);

            if (group != null)
            {
                group.IsActive = false;
                group.ModifiedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
                return true;
            }

            return false;
        }

        // Add new method for GUID-based deletion
        public async Task<bool> DeleteGroupByGuidAsync(string groupGuid, int templateVersionId)
        {
            if (!Guid.TryParse(groupGuid, out var guid))
                return false;

            var group = await _context.QuestionGroups
                .FirstOrDefaultAsync(g =>
                    g.GroupGuid == guid &&
                    g.TemplateVersionId == templateVersionId &&
                    g.IsActive
                );

            if (group == null)
                return false;

            group.IsActive = false;
            group.ModifiedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        private static GroupResponse BuildResponse(QuestionGroup group)
        {
            return new GroupResponse
            {
                Success = true,
                GroupId = group.QuestionGroupId,
                GroupGuid = group.GroupGuid.ToString(),
                Name = group.Name,
                DisplayOrder = group.DisplayOrder
            };
        }
    }

    public class GroupRequest
    {
        public int Id { get; set; }
        public string GroupGuid { get; set; } // This is string from frontend
        public string Name { get; set; }
        public int Order { get; set; }
        public int TemplateVersionId { get; set; }
    }

    public class GroupResponse
    {
        public bool Success { get; set; }
        public int GroupId { get; set; }
        public string GroupGuid { get; set; } // Return as string
        public string Name { get; set; }
        public int DisplayOrder { get; set; }
    }

}
