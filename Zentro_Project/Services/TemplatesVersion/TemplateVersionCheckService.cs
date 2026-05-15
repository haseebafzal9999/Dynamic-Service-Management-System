using System.Security.Claims;
using Independentsoft.Office.Odf.Fields;
using Microsoft.EntityFrameworkCore;
using zentro.library;
using zentro.Models;
using zentro.Models;

namespace zentro.Services.TemplatesVersion
{
    public class TemplateVersionCheckService : ITemplateVersionCheckService
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public TemplateVersionCheckService(dbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }




        public async Task<int> CloneTemplateVersionAsync(int sourceTemplateVersionId , string modifiedById)
        {

            var sourceVersion = await GetSourceTemplateVersion(sourceTemplateVersionId);
            if (sourceVersion == null)
                throw new Exception("Source TemplateVersion not found.");

            var newVersion = await CreateNewTemplateVersion(sourceVersion , modifiedById);

            await CloneMetafields(sourceVersion, newVersion, modifiedById);
            //await CloneQuestionGroupsAndQuestions(sourceVersion, newVersion, modifiedById);
            // ✅ CRITICAL FIX: Clone all questions FIRST, collect mapping, THEN clone dependencies
            var questionGuidToNewIdMap = await CloneQuestionGroupsAndQuestionsWithMapping(sourceVersion, newVersion, modifiedById);
            // ✅ NOW clone all dependencies using the complete mapping
            await CloneAllDependentQuestionsWithMapping(sourceVersion, newVersion, questionGuidToNewIdMap, modifiedById);

            return newVersion.TempVersionId;
        }

        private async Task<TemplateVersion?> GetSourceTemplateVersion(int sourceTemplateVersionId)
        {
            return await _context.TemplateVersions
                .Include(tv => tv.QuestionGroups)
                    .ThenInclude(qg => qg.Questions)
                        .ThenInclude(q => q.QuestionOptions)
                            .ThenInclude(qo => qo.DependentQuestions)
                .Include(tv => tv.Metafields)
                .FirstOrDefaultAsync(tv => tv.TempVersionId == sourceTemplateVersionId);
        }

        private async Task<TemplateVersion> CreateNewTemplateVersion(TemplateVersion sourceVersion, string modifiedById)
        {
            // Get the highest existing version number for this template
            var maxVersion = await _context.TemplateVersions
                .Where(tv => tv.TemplateId == sourceVersion.TemplateId)
                .MaxAsync(tv => (int?)tv.TempVersion) ?? 0;

            // Find the next available version number
            int nextVersion = maxVersion + 1;

            // Double-check that this version doesn't already exist (in case of race conditions)
            while (await _context.TemplateVersions.AnyAsync(tv =>
                tv.TemplateId == sourceVersion.TemplateId &&
                tv.TempVersion == nextVersion))
            {
                nextVersion++;
            }
            var newVersion = new TemplateVersion
            {
                TemplateId = sourceVersion.TemplateId,
                TempValidFrom = DateTime.UtcNow,
                IsActive = true,
                TempVersion = nextVersion, // Use the next available version
                CreatedAt = DateTime.UtcNow,
                CreatedById = sourceVersion.CreatedById,
                ModifiedAt = DateTime.UtcNow,
                ModifiedById = modifiedById,
                BusinessId = GetCurrentBusinessId()
            };
            _context.TemplateVersions.Add(newVersion);
            await _context.SaveChangesAsync();
            return newVersion;
        }

        private async Task CloneMetafields(TemplateVersion sourceVersion, TemplateVersion newVersion, string modifiedById)
        {
            if (sourceVersion.Metafields == null) return;

            foreach (var meta in sourceVersion.Metafields.Where(m => m.IsActive).OrderBy(m => m.PID))
            {
                var newMeta = new zentro.Models.Metafield
                {
                    TempVersionId = newVersion.TempVersionId,
                    MetafieldGuid = meta.MetafieldGuid,  // KEEP SAME GUID
                    Name = meta.Name,
                    FieldType = meta.FieldType,
                    Tag = meta.Tag,
                    Visibility = meta.Visibility,
                    //TableStyle = meta.TableStyle,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    CreatedById = meta.CreatedById,
                    ModifiedAt = DateTime.UtcNow,
                    ModifiedById = modifiedById
                };
                _context.Metafields.Add(newMeta);
            }
            await _context.SaveChangesAsync();
        }
        private async Task<(Dictionary<Guid, int> QuestionMap, Dictionary<Guid, int> OptionMap)> CloneQuestionGroupsAndQuestionsWithMapping(
            TemplateVersion sourceVersion,
            TemplateVersion newVersion,
            string modifiedById)
        {
            var questionGuidToNewIdMap = new Dictionary<Guid, int>();
            var optionGuidToNewIdMap = new Dictionary<Guid, int>();

            if (sourceVersion.QuestionGroups == null)
                return (questionGuidToNewIdMap, optionGuidToNewIdMap);

            var activeGroups = sourceVersion.QuestionGroups
                .Where(g => g.IsActive)
                .OrderBy(g => g.DisplayOrder)
                .ToList();

            Console.WriteLine($"📦 Cloning {activeGroups.Count} groups for version {newVersion.TempVersionId}");

            foreach (var group in activeGroups)
            {
                var newGroup = await CloneQuestionGroup(group, newVersion, modifiedById);

                if (group.Questions == null) continue;

                var activeQuestions = group.Questions
                    .Where(q => q.IsActive)
                    .OrderBy(q => q.DisplayOrder)
                    .ToList();

                Console.WriteLine($"  📝 Cloning {activeQuestions.Count} questions in group '{group.Name}'");

                foreach (var question in activeQuestions)
                {
                    var newQuestion = await CloneQuestion(question, newGroup, newVersion, modifiedById);

                    // ✅ Store mapping: QuestionGuid -> New QuestionId
                    if (question.QuestionGuid != Guid.Empty)
                    {
                        questionGuidToNewIdMap[question.QuestionGuid] = newQuestion.QuestionId;
                        Console.WriteLine($"    ✅ Mapped QuestionGuid {question.QuestionGuid} -> NewId {newQuestion.QuestionId}");
                    }

                    if (question.QuestionOptions == null) continue;

                    var activeOptions = question.QuestionOptions
                        .Where(o => o.IsActive)
                        .OrderBy(o => o.DisplayOrder)
                        .ToList();

                    foreach (var option in activeOptions)
                    {
                        var newOption = await CloneQuestionOption(option, newQuestion, modifiedById);

                        // ✅ Store mapping: OptionGuid -> New OptionId
                        if (option.OptionGuid != Guid.Empty)
                        {
                            optionGuidToNewIdMap[option.OptionGuid] = newOption.QoptionId;
                        }
                    }
                }
            }

            Console.WriteLine($"📊 Total mappings: {questionGuidToNewIdMap.Count} questions, {optionGuidToNewIdMap.Count} options");

            return (questionGuidToNewIdMap, optionGuidToNewIdMap);
        }

        private async Task CloneAllDependentQuestionsWithMapping(
            TemplateVersion sourceVersion,
            TemplateVersion newVersion,
            (Dictionary<Guid, int> QuestionMap, Dictionary<Guid, int> OptionMap) mappings,
            string modifiedById)
        {
            if (sourceVersion.QuestionGroups == null) return;

            var questionGuidToNewIdMap = mappings.QuestionMap;
            var optionGuidToNewIdMap = mappings.OptionMap;

            Console.WriteLine($"🔗 Starting to clone dependencies for version {newVersion.TempVersionId}");

            // ✅ Build a lookup: OLD QuestionId -> QuestionGuid (for source version)
            var oldQuestionIdToGuidMap = new Dictionary<int, Guid>();

            var allSourceQuestions = sourceVersion.QuestionGroups
                .Where(g => g.IsActive)
                .SelectMany(g => g.Questions ?? Enumerable.Empty<Question>())
                .Where(q => q.IsActive)
                .ToList();

            foreach (var q in allSourceQuestions)
            {
                if (q.QuestionGuid != Guid.Empty)
                {
                    oldQuestionIdToGuidMap[q.QuestionId] = q.QuestionGuid;
                }
            }

            // ✅ Track which dependencies we've already created to prevent duplicates
            var createdDependencies = new HashSet<(int optionId, int questionId)>();

            foreach (var sourceQuestion in allSourceQuestions)
            {
                if (sourceQuestion.QuestionOptions == null) continue;

                foreach (var sourceOption in sourceQuestion.QuestionOptions.Where(o => o.IsActive))
                {
                    if (sourceOption.DependentQuestions == null || !sourceOption.DependentQuestions.Any(d => d.IsActive))
                        continue;

                    // ✅ Find the NEW option ID using OptionGuid mapping
                    if (sourceOption.OptionGuid == Guid.Empty)
                    {
                        Console.WriteLine($"⚠️ Source option {sourceOption.QoptionId} has empty OptionGuid, skipping");
                        continue;
                    }

                    if (!optionGuidToNewIdMap.TryGetValue(sourceOption.OptionGuid, out var newOptionId))
                    {
                        Console.WriteLine($"⚠️ Could not find new option for OptionGuid {sourceOption.OptionGuid}");
                        continue;
                    }

                    foreach (var dep in sourceOption.DependentQuestions.Where(d => d.IsActive))
                    {
                        if (dep.NextQuestionId == null) continue;

                        var oldNextQuestionId = dep.NextQuestionId.Value;

                        // ✅ STEP 1: Get the QuestionGuid from the OLD NextQuestionId
                        Guid targetQuestionGuid;

                        // First try our in-memory lookup
                        if (oldQuestionIdToGuidMap.TryGetValue(oldNextQuestionId, out targetQuestionGuid))
                        {
                            Console.WriteLine($"  Found GUID {targetQuestionGuid} for old QuestionId {oldNextQuestionId} from memory");
                        }
                        else
                        {
                            // Fallback: query DB for the question
                            var sourceTargetQuestion = await _context.Questions
                                .AsNoTracking()
                                .FirstOrDefaultAsync(q => q.QuestionId == oldNextQuestionId);

                            if (sourceTargetQuestion == null || sourceTargetQuestion.QuestionGuid == Guid.Empty)
                            {
                                Console.WriteLine($"⚠️ Source target question {oldNextQuestionId} not found or has empty GUID");
                                continue;
                            }

                            targetQuestionGuid = sourceTargetQuestion.QuestionGuid;
                            Console.WriteLine($"  Found GUID {targetQuestionGuid} for old QuestionId {oldNextQuestionId} from DB");
                        }

                        // ✅ STEP 2: Use mapping to find the NEW QuestionId in the new version
                        if (!questionGuidToNewIdMap.TryGetValue(targetQuestionGuid, out var newTargetQuestionId))
                        {
                            Console.WriteLine($"⚠️ Could not find new question for QuestionGuid {targetQuestionGuid} in mapping");
                            continue;
                        }

                        // ✅ STEP 3: Check if we already created this dependency (prevent duplicates)
                        var depKey = (newOptionId, newTargetQuestionId);
                        if (createdDependencies.Contains(depKey))
                        {
                            Console.WriteLine($"⚠️ Skipping duplicate: Option {newOptionId} -> Question {newTargetQuestionId}");
                            continue;
                        }

                        // ✅ STEP 4: Check if dependency already exists in DB
                        var existingDep = await _context.DependentQuestions
                            .AnyAsync(d =>
                                d.QoptionId == newOptionId &&
                                d.NextQuestionId == newTargetQuestionId);

                        if (existingDep)
                        {
                            Console.WriteLine($"⚠️ Dependency already exists in DB: Option {newOptionId} -> Question {newTargetQuestionId}");
                            createdDependencies.Add(depKey);
                            continue;
                        }

                        // ✅ STEP 5: Create the new dependency with CORRECT new IDs
                        var newDep = new DependentQuestion
                        {
                            QoptionId = newOptionId,
                            NextQuestionId = newTargetQuestionId,
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow,
                            ModifiedAt = DateTime.UtcNow,
                            ModifiedById = modifiedById
                        };

                        _context.DependentQuestions.Add(newDep);
                        createdDependencies.Add(depKey);

                        Console.WriteLine($"✅ Created dependency: Option {newOptionId} -> Question {newTargetQuestionId} (GUID: {targetQuestionGuid})");
                    }
                }
            }

            await _context.SaveChangesAsync();
            Console.WriteLine($"✅ Finished cloning {createdDependencies.Count} dependencies for version {newVersion.TempVersionId}");
        }

        private async Task CloneQuestionGroupsAndQuestions(TemplateVersion sourceVersion, TemplateVersion newVersion, string modifiedById)
        {
            if (sourceVersion.QuestionGroups == null) return;
            var activeGroups = sourceVersion.QuestionGroups.Where(g => g.IsActive).OrderBy(g => g.QuestionGroupId);

            foreach (var group in activeGroups)
            {
                var newGroup = await CloneQuestionGroup(group, newVersion, modifiedById);

                if (group.Questions == null)
                {
                    continue;
                }

                // ✅ Only clone active questions
                var activeQuestions = group.Questions
                    .Where(q => q.IsActive)
                    .OrderBy(q => q.QuestionId)
                    .ToList();
                foreach (var question in activeQuestions)
                    {
                        var newQuestion = await CloneQuestion(question, newGroup, newVersion, modifiedById);

                    if (question.QuestionOptions == null)
                    {
                        continue;
                    }

                    // ✅ Only clone active options
                    var activeOptions = question.QuestionOptions
                        .Where(o => o.IsActive)
                        .OrderBy(o => o.QoptionId)
                        .ToList();
                    foreach (var option in activeOptions)
                        {
                            var newOption = await CloneQuestionOption(option, newQuestion, modifiedById);

                            if (option.DependentQuestions != null)
                            {
                                await CloneDependentQuestions(option, newOption, group, newVersion, modifiedById);
                            }
                        }
                    }
                    
                
            }
        }



        private async Task<QuestionGroup> CloneQuestionGroup(QuestionGroup group, TemplateVersion newVersion , string modifiedById)
        {
            var businessId = GetCurrentBusinessId();

            var newGroup = new QuestionGroup
            {
                Name = group.Name,
                GroupGuid = group.GroupGuid,
                DisplayOrder = group.DisplayOrder,
                TemplateId = group.TemplateId,
                TemplateVersionId = newVersion.TempVersionId,
                IsActive = true,
                ModifiedAt = DateTime.UtcNow,
                ModifiedById = modifiedById,
                BusinessId = businessId 



            };
            _context.QuestionGroups.Add(newGroup);
            await _context.SaveChangesAsync();
            return newGroup;
        }

        private async Task<Question> CloneQuestion(Question question, QuestionGroup newGroup, TemplateVersion newVersion , string modifiedById)
        {
            var businessId = GetCurrentBusinessId();

            var newQuestion = new Question
            {
                Text = question.Text,
                IsRequired = question.IsRequired,
                DisplayOrder = question.DisplayOrder,
                QuestionGroupId = newGroup.QuestionGroupId,
                TemplateId = question.TemplateId,
                TemplateVersionId = newVersion.TempVersionId,
                FieldTypeId = question.FieldTypeId,
                IsActive = true,
                ModifiedAt = DateTime.UtcNow,
                ModifiedById = modifiedById,
                BusinessId = businessId,
                QuestionGuid = question.QuestionGuid == Guid.Empty
                    ? Guid.NewGuid()
                    : question.QuestionGuid
            };
            _context.Questions.Add(newQuestion);
            await _context.SaveChangesAsync();
            return newQuestion;
        }

        private async Task<QuestionOption> CloneQuestionOption(QuestionOption option, Question newQuestion, string modifiedById)
        {
            var newOption = new QuestionOption
            {
                OptionText = option.OptionText,
                QuestionId = newQuestion.QuestionId,
                DisplayOrder = option.DisplayOrder,
                FieldTypeId = option.FieldTypeId,
                MaterialCompId = option.MaterialCompId,
                MatCompName = option.MatCompName,
                IsActive = true,
                OptionGuid = option.OptionGuid == Guid.Empty ? Guid.NewGuid() : option.OptionGuid,
                //CreatedAt = DateTime.UtcNow,
                ModifiedAt = DateTime.UtcNow,
                ModifiedById = modifiedById,


            };
            _context.QuestionOptions.Add(newOption);
            await _context.SaveChangesAsync();
            return newOption;
        }


        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }
        private async Task CloneDependentQuestions(QuestionOption sourceOption, QuestionOption newOption, QuestionGroup sourceGroup, TemplateVersion newVersion, string modifiedById)
        {
            if (sourceOption.DependentQuestions == null)
            {
                return;
            }

            // ✅ Only clone active dependency links
            var activeDeps = sourceOption.DependentQuestions
                .Where(d => d.IsActive)
                .OrderBy(d => d.DependentQid)
                .ToList();

            foreach (var dep in activeDeps)
            {
                if (dep.NextQuestionId == null) continue;

                // ✅ STEP 1: Find the source target question to get its QuestionGuid
                var sourceTargetQuestion = sourceGroup.Questions?
                    .FirstOrDefault(q => q.QuestionId == dep.NextQuestionId && q.IsActive);

                // If not found in same group, search across ALL groups in source version
                if (sourceTargetQuestion == null)
                {
                    sourceTargetQuestion = await _context.Questions
                        .AsNoTracking()
                        .FirstOrDefaultAsync(q => q.QuestionId == dep.NextQuestionId && q.IsActive);
                }

                if (sourceTargetQuestion == null)
                {
                    Console.WriteLine($"⚠️ Source target question {dep.NextQuestionId} not found");
                    continue;
                }

                // ✅ STEP 2: Use QuestionGuid + new TempVersionId to find the cloned question
                var targetQuestionGuid = sourceTargetQuestion.QuestionGuid;

                if (targetQuestionGuid == Guid.Empty)
                {
                    Console.WriteLine($"⚠️ Source question {dep.NextQuestionId} has empty QuestionGuid");
                    continue;
                }

                // ✅ CRITICAL FIX: Find new question by QuestionGuid + new TemplateVersionId
                var newTargetQuestion = await _context.Questions
                    .FirstOrDefaultAsync(q =>
                        q.QuestionGuid == targetQuestionGuid &&
                        q.TemplateVersionId == newVersion.TempVersionId &&
                        q.IsActive);

                if (newTargetQuestion != null)
                {
                    // Check if dependency already exists to prevent duplicates
                    var existingDep = await _context.DependentQuestions
                        .AnyAsync(d =>
                            d.QoptionId == newOption.QoptionId &&
                            d.NextQuestionId == newTargetQuestion.QuestionId &&
                            d.IsActive);

                    if (existingDep)
                    {
                        Console.WriteLine($"⚠️ Dependency already exists: Option {newOption.QoptionId} -> Question {newTargetQuestion.QuestionId}");
                        continue;
                    }

                    var newDep = new DependentQuestion
                    {
                        QoptionId = newOption.QoptionId,
                        NextQuestionId = newTargetQuestion.QuestionId,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow,
                        ModifiedAt = DateTime.UtcNow,
                        ModifiedById = modifiedById
                    };

                    _context.DependentQuestions.Add(newDep);
                    await _context.SaveChangesAsync();

                    Console.WriteLine($"✅ Created dependency: Option {newOption.QoptionId} -> Question {newTargetQuestion.QuestionId} (GUID: {targetQuestionGuid}, Version: {newVersion.TempVersionId})");
                }
                else
                {
                    Console.WriteLine($"⚠️ Could not find new question with GUID {targetQuestionGuid} in version {newVersion.TempVersionId}");
                }
            }
        }
    }
}