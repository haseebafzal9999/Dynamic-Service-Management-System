using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using zentro.library;
using zentro.Models;
using zentro.Services.Questions.zentro.Services.Questions;

namespace zentro.Services.Questions
{
    public class QuestionService : IQuestionService
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public QuestionService(dbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }
        public async Task<QuestionResponse> CreateOrUpdateQuestionAsync(QuestionRequest request)
        {
            // ✅ CRITICAL: Verify if QuestionGuid is actually coming from frontend
            if (string.IsNullOrWhiteSpace(request.QuestionGuid))
                            {
                                Console.WriteLine("❌ WARNING: QuestionGuid is EMPTY in request!");
                            }
                            else
                            {
                                Console.WriteLine($"✅ QuestionGuid received: {request.QuestionGuid}");
                            }
            try
            {
                Console.WriteLine($"=== CREATE/UPDATE QUESTION DEBUG ===");
                Console.WriteLine($"Question Text: {request.Text}");
                Console.WriteLine($"Question ID: {request.Id}");
                Console.WriteLine($"Group ID: {request.GroupId}");
                Console.WriteLine($"Group GUID: {request.GroupGuid}");
                Console.WriteLine($"TemplateVersionId: {request.TemplateVersionId}");
                Console.WriteLine($"QuestionGuid: {request.QuestionGuid}");

                // 1️⃣ Validate Template Version
                var templateVersion = await _context.TemplateVersions
                    .AsNoTracking()
                    .FirstOrDefaultAsync(tv => tv.TempVersionId == request.TemplateVersionId);

                if (templateVersion == null)
                    throw new Exception($"TemplateVersion with ID {request.TemplateVersionId} not found");

                // 2️⃣ ✅ CRITICAL FIX: Resolve GroupId from GroupGuid in the CORRECT version
                int resolvedGroupId = request.GroupId;

                if (!string.IsNullOrWhiteSpace(request.GroupGuid) &&
                    Guid.TryParse(request.GroupGuid, out var groupGuidParsed))
                {
                    var groupInVersion = await _context.QuestionGroups
                        .Where(g => g.GroupGuid == groupGuidParsed &&
                                   g.TemplateVersionId == request.TemplateVersionId &&
                                   g.IsActive)
                        .FirstOrDefaultAsync();

                    if (groupInVersion != null)
                    {
                        resolvedGroupId = groupInVersion.QuestionGroupId;
                        Console.WriteLine($"✅ Resolved GroupGuid={request.GroupGuid} to GroupId={resolvedGroupId} in version {request.TemplateVersionId}");
                    }
                    else
                    {
                        Console.WriteLine($"⚠️ Group with GUID={request.GroupGuid} not found in version {request.TemplateVersionId}");
                        throw new Exception($"Group with GUID {request.GroupGuid} not found in version {request.TemplateVersionId}");
                    }
                }
                else if (resolvedGroupId <= 0)
                {
                    throw new Exception("GroupId or GroupGuid must be provided");
                }

                // 3️⃣ Parse incoming QuestionGuid
                Guid? questionGuid = null;
                if (!string.IsNullOrWhiteSpace(request.QuestionGuid) &&
                    Guid.TryParse(request.QuestionGuid, out var parsedGuid))
                {
                    questionGuid = parsedGuid;
                }

                Question question;
                if (questionGuid == null && request.Id > 0)
                {
                    try
                    {
                        var existingById = await _context.Questions
                            .AsNoTracking()
                            .FirstOrDefaultAsync(q => q.QuestionId == request.Id);

                        if (existingById != null && existingById.QuestionGuid != Guid.Empty)
                        {
                            questionGuid = existingById.QuestionGuid;
                            Console.WriteLine($"Resolved QuestionGuid from Id: request.Id={request.Id} => QuestionGuid={questionGuid}");
                        }
                        else
                        {
                            Console.WriteLine($"Could not resolve QuestionGuid from Id={request.Id} (not found or empty GUID).");
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error resolving QuestionGuid from Id={request.Id}: {ex.Message}");
                    }
                }

                // 4️⃣ CASE: NEW QUESTION (no GUID)
                if (questionGuid == null)
                {
                    Console.WriteLine("➕ Creating NEW question (no GUID provided)");

                    question = new Question
                    {
                        Text = request.Text,
                        QuestionGroupId = resolvedGroupId,  // ✅ Use resolved ID
                        FieldTypeId = request.FieldTypeId,
                        DisplayOrder = request.Order,
                        IsRequired = request.IsRequired,
                        TemplateVersionId = request.TemplateVersionId,
                        TemplateId = templateVersion.TemplateId,
                        QuestionGuid = Guid.NewGuid(),
                        CreatedAt = DateTime.UtcNow,
                        ModifiedAt = DateTime.UtcNow,
                        IsActive = true,
                        BusinessId = GetCurrentBusinessId()
                    };

                    _context.Questions.Add(question);
                    await _context.SaveChangesAsync();

                    await UpdateQuestionOptionsAsync(question.QuestionId, request.Answers);

                    var newQuestion = await _context.Questions
                        .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                        .FirstOrDefaultAsync(q => q.QuestionId == question.QuestionId);

                    return BuildResponse(newQuestion);
                }

                // 5️⃣ CASE: UPDATE OR CLONE - Find question by GUID + TemplateVersionId
                // IMPORTANT: don't restrict to IsActive only — we may need to reactivate or update inactive record.
                var questionInCurrentVersion = await _context.Questions
                    .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                    .FirstOrDefaultAsync(q =>
                        q.QuestionGuid == questionGuid.Value &&
                        q.TemplateVersionId == request.TemplateVersionId
                    );

                if (questionInCurrentVersion != null)
                {
                    // If it was inactive (soft deleted) reactivate only in this version
                    if (!questionInCurrentVersion.IsActive)
                    {
                        Console.WriteLine($"🔁 Reactivating question ID={questionInCurrentVersion.QuestionId} in version {request.TemplateVersionId}");
                        questionInCurrentVersion.IsActive = true;
                    }

                    // ✅ UPDATE existing question in the CURRENT/NEW version
                    Console.WriteLine($"✏️ Updating existing question ID={questionInCurrentVersion.QuestionId} in version {request.TemplateVersionId}");

                    questionInCurrentVersion.Text = request.Text;
                    questionInCurrentVersion.QuestionGroupId = resolvedGroupId;  // ✅ Use resolved ID
                    questionInCurrentVersion.FieldTypeId = request.FieldTypeId;
                    questionInCurrentVersion.DisplayOrder = request.Order;
                    questionInCurrentVersion.IsRequired = request.IsRequired;
                    questionInCurrentVersion.ModifiedAt = DateTime.UtcNow;

                    await _context.SaveChangesAsync();
                    await UpdateQuestionOptionsAsync(questionInCurrentVersion.QuestionId, request.Answers);

                    var updatedQuestion = await _context.Questions
                        .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                        .FirstOrDefaultAsync(q => q.QuestionId == questionInCurrentVersion.QuestionId);

                    return BuildResponse(updatedQuestion);
                }

                // 6️⃣ Question not found in current version — defensive handling to avoid duplicates
                Console.WriteLine($"⚠️ Question with GUID={questionGuid} not found in version {request.TemplateVersionId}");

                // 6.a) Try a signature match in target version (same group + text + order)
                var signatureMatch = await _context.Questions
                    .Where(q => q.TemplateVersionId == request.TemplateVersionId)
                    .FirstOrDefaultAsync(q =>
                        q.QuestionGroupId == resolvedGroupId &&
                        q.Text == request.Text &&
                        q.DisplayOrder == request.Order);

                if (signatureMatch != null)
                {
                    Console.WriteLine($"ℹ️ Found signature match QuestionId={signatureMatch.QuestionId} in target version; updating instead of creating duplicate.");
                    signatureMatch.Text = request.Text;
                    signatureMatch.QuestionGroupId = resolvedGroupId;
                    signatureMatch.FieldTypeId = request.FieldTypeId;
                    signatureMatch.DisplayOrder = request.Order;
                    signatureMatch.IsRequired = request.IsRequired;
                    signatureMatch.ModifiedAt = DateTime.UtcNow;

                    await _context.SaveChangesAsync();

                    await UpdateQuestionOptionsAsync(signatureMatch.QuestionId, request.Answers);

                    var updatedSig = await _context.Questions
                        .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                        .FirstOrDefaultAsync(q => q.QuestionId == signatureMatch.QuestionId);

                    return BuildResponse(updatedSig);
                }

                // 6.b) Fallback: get most recent previous version of this question by GUID (source for OptionGuids)
                var previousQuestion = await _context.Questions
                    .Where(q => q.QuestionGuid == questionGuid.Value && q.IsActive)
                    .OrderByDescending(q => q.TemplateVersionId)
                    .FirstOrDefaultAsync();

                if (previousQuestion == null)
                {
                    // No prior record — fail so frontend can refresh and retry (prevents silent duplicates)
                    Console.WriteLine($"❌ No previous question record found for GUID={questionGuid}; aborting to avoid duplication.");
                    throw new Exception($"Question with GUID {questionGuid} not found in previous versions. Refresh the page and try again.");
                }

                // Extra defensive check: ensure no question with same GUID got created meanwhile (race)
                var maybeCreated = await _context.Questions
                    .FirstOrDefaultAsync(q => q.QuestionGuid == questionGuid.Value && q.TemplateVersionId == request.TemplateVersionId);

                if (maybeCreated != null)
                {
                    Console.WriteLine($"⚠️ Race detected: question with GUID already created in target version (Id={maybeCreated.QuestionId}). Updating it.");
                    if (!maybeCreated.IsActive) maybeCreated.IsActive = true;
                    maybeCreated.Text = request.Text;
                    maybeCreated.QuestionGroupId = resolvedGroupId;
                    maybeCreated.FieldTypeId = request.FieldTypeId;
                    maybeCreated.DisplayOrder = request.Order;
                    maybeCreated.IsRequired = request.IsRequired;
                    maybeCreated.ModifiedAt = DateTime.UtcNow;

                    await _context.SaveChangesAsync();
                    await UpdateQuestionOptionsAsync(maybeCreated.QuestionId, request.Answers);

                    var updatedMaybe = await _context.Questions
                        .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                        .FirstOrDefaultAsync(q => q.QuestionId == maybeCreated.QuestionId);

                    return BuildResponse(updatedMaybe);
                }

                // Proceed with creating a cloned record in the target version (use previous GUID)
                question = new Question
                {
                    Text = request.Text,
                    QuestionGroupId = resolvedGroupId,  // ✅ Use resolved ID
                    FieldTypeId = request.FieldTypeId,
                    DisplayOrder = request.Order,
                    IsRequired = request.IsRequired,
                    TemplateVersionId = request.TemplateVersionId,
                    TemplateId = templateVersion.TemplateId,
                    QuestionGuid = previousQuestion?.QuestionGuid ?? questionGuid.Value,
                    CreatedAt = DateTime.UtcNow,
                    ModifiedAt = DateTime.UtcNow,
                    IsActive = true,
                    BusinessId = GetCurrentBusinessId()
                };

                _context.Questions.Add(question);
                await _context.SaveChangesAsync();

                var prevOptions = await _context.QuestionOptions
                   .Where(o => o.QuestionId == previousQuestion.QuestionId && o.IsActive)
                   .Select(o => new { o.OptionGuid, o.OptionText, o.DisplayOrder })
                   .ToListAsync();

                if ((request.Answers?.Any() ?? false) && prevOptions.Any())
                {
                    foreach (var ans in request.Answers)
                    {
                        if (string.IsNullOrWhiteSpace(ans.OptionGuid))
                        {
                            // match by order+text first, then by text
                            var match = prevOptions.FirstOrDefault(po =>
                                (po.DisplayOrder == ans.Order && string.Equals(po.OptionText?.Trim(), ans.Text?.Trim(), StringComparison.OrdinalIgnoreCase)) ||
                                string.Equals(po.OptionText?.Trim(), ans.Text?.Trim(), StringComparison.OrdinalIgnoreCase));

                            if (match != null && match.OptionGuid != Guid.Empty)
                            {
                                ans.OptionGuid = match.OptionGuid.ToString();
                            }
                        }
                    }
                }
                await UpdateQuestionOptionsAsync(question.QuestionId, request.Answers);

                var finalQuestion = await _context.Questions
                    .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                    .FirstOrDefaultAsync(q => q.QuestionId == question.QuestionId);

                return BuildResponse(finalQuestion);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"CreateOrUpdateQuestionAsync ERROR: {ex}");
                throw;
            }
        }


        private void UpdateQuestion(Question question, QuestionRequest request, int templateId)
        {
            question.Text = request.Text;
            question.QuestionGroupId = request.GroupId;
            question.FieldTypeId = request.FieldTypeId;
            question.DisplayOrder = request.Order;
            question.IsRequired = request.IsRequired;
            question.TemplateId = templateId;
            question.ModifiedAt = DateTime.UtcNow;
            question.BusinessId = GetCurrentBusinessId();
        }

        private async Task UpdateQuestionOptionsAsync(int questionId, List<AnswerRequest> answers)
        {
            if (answers == null || !answers.Any())
                return;

            var existingOptions = await _context.QuestionOptions
                .Where(o => o.QuestionId == questionId)
                .ToListAsync();

            var userId = _httpContextAccessor.HttpContext?.User
                .FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);

            foreach (var answer in answers)
            {
                Guid? incomingOptionGuid = null;
                if (!string.IsNullOrWhiteSpace(answer.OptionGuid) &&
                    Guid.TryParse(answer.OptionGuid, out var parsedGuid) &&
                    parsedGuid != Guid.Empty)
                {
                    incomingOptionGuid = parsedGuid;
                }

                // Resolve existing option once (by Id or OptionGuid)
                QuestionOption existingOption = null;
                if (answer.Id > 0)
                {
                    existingOption = existingOptions.FirstOrDefault(o => o.QoptionId == answer.Id);
                }
                if (existingOption == null && incomingOptionGuid.HasValue)
                {
                    existingOption = existingOptions.FirstOrDefault(o => o.OptionGuid == incomingOptionGuid.Value);
                }

                var status = (answer.OptionStatus ?? string.Empty).Trim().ToLowerInvariant();

                // If no explicit status, fall back to legacy behavior (IsDeleted/existence)
                if (string.IsNullOrEmpty(status))
                {
                    if (answer.IsDeleted)
                    {
                        if (existingOption != null && existingOption.IsActive)
                        {
                            existingOption.IsActive = false;
                            existingOption.ModifiedAt = DateTime.UtcNow;
                            existingOption.ModifiedById = userId;

                            var dependentQuestions = await _context.DependentQuestions
                                .Where(d => d.QoptionId == existingOption.QoptionId && d.IsActive)
                                .ToListAsync();

                            foreach (var dep in dependentQuestions)
                            {
                                dep.IsActive = false;
                                dep.ModifiedAt = DateTime.UtcNow;
                                dep.ModifiedById = userId;
                            }
                        }
                        continue;
                    }

                    if (existingOption != null && existingOption.IsActive)
                    {
                        UpdateQuestionOption(existingOption, answer);
                        existingOption.ModifiedById = userId;

                        await _context.SaveChangesAsync();
                        await UpdateDependentQuestionsAsync(existingOption, answer.SelectedQuestionsList);
                    }
                    else
                    {
                        var newOption = new QuestionOption
                        {
                            QuestionId = questionId,
                            OptionText = answer.Text,
                            DisplayOrder = answer.Order,
                            MatCompName = answer.SelectedOption,
                            MaterialCompId = answer.SelectedMatComId,
                            CreatedAt = DateTime.UtcNow,
                            ModifiedAt = DateTime.UtcNow,
                            ModifiedById = userId,
                            IsActive = true,
                            OptionGuid = incomingOptionGuid ?? Guid.NewGuid()
                        };

                        _context.QuestionOptions.Add(newOption);
                        await _context.SaveChangesAsync();

                        await UpdateDependentQuestionsAsync(newOption, answer.SelectedQuestionsList);
                    }

                    continue;
                }

                // New algorithm using optionStatus
                switch (status)
                {
                    case "new":
                        if (existingOption == null)
                        {
                            var newOption = new QuestionOption
                            {
                                QuestionId = questionId,
                                OptionText = answer.Text,
                                DisplayOrder = answer.Order,
                                MatCompName = answer.SelectedOption,
                                MaterialCompId = answer.SelectedMatComId,
                                CreatedAt = DateTime.UtcNow,
                                ModifiedAt = DateTime.UtcNow,
                                ModifiedById = userId,
                                IsActive = true,
                                OptionGuid = incomingOptionGuid ?? Guid.NewGuid()
                            };

                            _context.QuestionOptions.Add(newOption);
                            await _context.SaveChangesAsync();

                            await UpdateDependentQuestionsAsync(newOption, answer.SelectedQuestionsList);
                        }
                        // If already persisted, keep as "new" locally, no server change
                        break;

                    case "updated":
                        if (existingOption != null && existingOption.IsActive)
                        {
                            UpdateQuestionOption(existingOption, answer);
                            existingOption.ModifiedById = userId;

                            await _context.SaveChangesAsync();
                            await UpdateDependentQuestionsAsync(existingOption, answer.SelectedQuestionsList);
                        }
                        else
                        {
                            // Treat as new if not found persisted
                            var newOption = new QuestionOption
                            {
                                QuestionId = questionId,
                                OptionText = answer.Text,
                                DisplayOrder = answer.Order,
                                MatCompName = answer.SelectedOption,
                                MaterialCompId = answer.SelectedMatComId,
                                CreatedAt = DateTime.UtcNow,
                                ModifiedAt = DateTime.UtcNow,
                                ModifiedById = userId,
                                IsActive = true,
                                OptionGuid = incomingOptionGuid ?? Guid.NewGuid()
                            };

                            _context.QuestionOptions.Add(newOption);
                            await _context.SaveChangesAsync();

                            await UpdateDependentQuestionsAsync(newOption, answer.SelectedQuestionsList);
                        }
                        break;

                    case "deleted":
                        if (existingOption != null && existingOption.IsActive)
                        {
                            existingOption.IsActive = false;
                            existingOption.ModifiedAt = DateTime.UtcNow;
                            existingOption.ModifiedById = userId;

                            var dependentQuestions = await _context.DependentQuestions
                                .Where(d => d.QoptionId == existingOption.QoptionId && d.IsActive)
                                .ToListAsync();

                            foreach (var dep in dependentQuestions)
                            {
                                dep.IsActive = false;
                                dep.ModifiedAt = DateTime.UtcNow;
                                dep.ModifiedById = userId;
                            }
                        }
                        // If not persisted (local "new"), do nothing server-side
                        break;

                    default:
                        // Unknown flag → do nothing special; rely on legacy flow
                        if (answer.IsDeleted)
                        {
                            if (existingOption != null && existingOption.IsActive)
                            {
                                existingOption.IsActive = false;
                                existingOption.ModifiedAt = DateTime.UtcNow;
                                existingOption.ModifiedById = userId;

                                var dependentQuestions = await _context.DependentQuestions
                                    .Where(d => d.QoptionId == existingOption.QoptionId && d.IsActive)
                                    .ToListAsync();

                                foreach (var dep in dependentQuestions)
                                {
                                    dep.IsActive = false;
                                    dep.ModifiedAt = DateTime.UtcNow;
                                    dep.ModifiedById = userId;
                                }
                            }
                            continue;
                        }

                        if (existingOption != null && existingOption.IsActive)
                        {
                            UpdateQuestionOption(existingOption, answer);
                            existingOption.ModifiedById = userId;

                            await _context.SaveChangesAsync();
                            await UpdateDependentQuestionsAsync(existingOption, answer.SelectedQuestionsList);
                        }
                        else
                        {
                            var newOption = new QuestionOption
                            {
                                QuestionId = questionId,
                                OptionText = answer.Text,
                                DisplayOrder = answer.Order,
                                MatCompName = answer.SelectedOption,
                                MaterialCompId = answer.SelectedMatComId,
                                CreatedAt = DateTime.UtcNow,
                                ModifiedAt = DateTime.UtcNow,
                                ModifiedById = userId,
                                IsActive = true,
                                OptionGuid = incomingOptionGuid ?? Guid.NewGuid()
                            };

                            _context.QuestionOptions.Add(newOption);
                            await _context.SaveChangesAsync();

                            await UpdateDependentQuestionsAsync(newOption, answer.SelectedQuestionsList);
                        }
                        break;
                }
            }

            await _context.SaveChangesAsync();
        }

        private async Task UpdateDependentQuestionsAsync(QuestionOption option, List<int> selectedQuestionIds)
        {
            Console.WriteLine($"🔗 UpdateDependentQuestionsAsync called for Option {option.QoptionId}");
            Console.WriteLine($"🔗 Selected Question IDs: [{string.Join(",", selectedQuestionIds ?? new List<int>())}]");

            // ✅ Get the template version from the parent question
            var parentQuestion = await _context.Questions
                .AsNoTracking()
                .FirstOrDefaultAsync(q => q.QuestionId == option.QuestionId);

            if (parentQuestion == null)
            {
                Console.WriteLine($"❌ Parent question not found for option {option.QoptionId}");
                return;
            }

            var templateVersionId = parentQuestion.TemplateVersionId ?? 0;
            Console.WriteLine($"📋 Working with TemplateVersionId: {templateVersionId}");

            // ✅ Handle null or empty list - remove all dependencies
            if (selectedQuestionIds == null || !selectedQuestionIds.Any())
            {
                var existingDeps = await _context.DependentQuestions
                    .Where(d => d.QoptionId == option.QoptionId && d.IsActive)
                    .ToListAsync();

                if (existingDeps.Any())
                {
                    Console.WriteLine($"🗑️ Removing {existingDeps.Count} existing dependencies (no questions selected)");
                    foreach (var dep in existingDeps)
                    {
                        dep.IsActive = false;
                        dep.ModifiedAt = DateTime.UtcNow;
                    }
                    await _context.SaveChangesAsync();
                }
                return;
            }

            // ✅ NEW: Check for circular dependencies
            var wouldCreateCircular = await WouldCreateCircularDependency(
                option.QoptionId,
                selectedQuestionIds,
                templateVersionId
            );

            if (wouldCreateCircular)
            {
                throw new InvalidOperationException(
                    "Cannot create circular dependency: One or more selected questions already have this question as their dependent. " +
                    "This would create an infinite loop where questions depend on each other."
                );
            }

            // ✅ CRITICAL FIX: Resolve all QuestionIds to the CURRENT version
            var resolvedQuestionIds = new List<int>();

            foreach (var questionId in selectedQuestionIds)
            {
                // Get the source question
                var sourceQuestion = await _context.Questions
                    .AsNoTracking()
                    .FirstOrDefaultAsync(q => q.QuestionId == questionId && q.IsActive);

                if (sourceQuestion == null)
                {
                    Console.WriteLine($"⚠️ Question {questionId} not found, skipping");
                    continue;
                }

                // ✅ If question is in SAME version, use it directly
                if (sourceQuestion.TemplateVersionId == templateVersionId)
                {
                    resolvedQuestionIds.Add(questionId);
                    Console.WriteLine($"✅ Question {questionId} is in current version, using directly");
                    continue;
                }

                // ✅ If question is from DIFFERENT version, find it by QuestionGuid in current version
                if (sourceQuestion.QuestionGuid == Guid.Empty)
                {
                    Console.WriteLine($"⚠️ Question {questionId} has empty GUID, cannot resolve to current version");
                    continue;
                }

                var targetQuestion = await _context.Questions
                    .AsNoTracking()
                    .FirstOrDefaultAsync(q =>
                        q.QuestionGuid == sourceQuestion.QuestionGuid &&
                        q.TemplateVersionId == templateVersionId &&
                        q.IsActive);

                if (targetQuestion != null)
                {
                    resolvedQuestionIds.Add(targetQuestion.QuestionId);
                    Console.WriteLine($"✅ Resolved Question {questionId} (GUID: {sourceQuestion.QuestionGuid}) to {targetQuestion.QuestionId} in version {templateVersionId}");
                }
                else
                {
                    Console.WriteLine($"⚠️ Could not find question with GUID {sourceQuestion.QuestionGuid} in version {templateVersionId}");
                }
            }

            if (!resolvedQuestionIds.Any())
            {
                Console.WriteLine($"⚠️ No valid questions resolved for dependencies");
                return;
            }

            Console.WriteLine($"📋 Resolved {resolvedQuestionIds.Count} questions for current version: [{string.Join(",", resolvedQuestionIds)}]");

            // Get current dependencies
            var currentDeps = await _context.DependentQuestions
                .Where(d => d.QoptionId == option.QoptionId && d.IsActive)
                .ToListAsync();

            Console.WriteLine($"📋 Current active dependencies: {currentDeps.Count}");

            var existingQuestionIds = currentDeps
                .Where(d => d.NextQuestionId.HasValue)
                .Select(d => d.NextQuestionId.Value)
                .ToList();

            Console.WriteLine($"📋 Existing NextQuestionIds: [{string.Join(",", existingQuestionIds)}]");

            // Remove dependencies that are no longer selected
            var depsToRemove = currentDeps
                .Where(d => d.NextQuestionId.HasValue && !resolvedQuestionIds.Contains(d.NextQuestionId.Value))
                .ToList();

            foreach (var dep in depsToRemove)
            {
                Console.WriteLine($"🗑️ Deactivating dependency: Option {option.QoptionId} -> Question {dep.NextQuestionId}");
                dep.IsActive = false;
                dep.ModifiedAt = DateTime.UtcNow;
            }

            // Find NEW question IDs to add
            var newQuestionIds = resolvedQuestionIds
                .Where(id => !existingQuestionIds.Contains(id))
                .ToList();

            Console.WriteLine($"➕ New question IDs to add: [{string.Join(",", newQuestionIds)}]");

            foreach (var questionId in newQuestionIds)
            {
                // Verify the question exists and is active IN THE CURRENT VERSION
                var questionExists = await _context.Questions
                    .AnyAsync(q =>
                        q.QuestionId == questionId &&
                        q.TemplateVersionId == templateVersionId &&
                        q.IsActive);

                if (!questionExists)
                {
                    Console.WriteLine($"⚠️ Question ID {questionId} not found in version {templateVersionId}. Skipping dependency.");
                    continue;
                }

                // Check if there's an inactive dependency to reactivate
                var existingInactiveDep = await _context.DependentQuestions
                    .FirstOrDefaultAsync(d =>
                        d.QoptionId == option.QoptionId &&
                        d.NextQuestionId == questionId &&
                        !d.IsActive);

                if (existingInactiveDep != null)
                {
                    Console.WriteLine($"🔄 Reactivating dependency: Option {option.QoptionId} -> Question {questionId}");
                    existingInactiveDep.IsActive = true;
                    existingInactiveDep.ModifiedAt = DateTime.UtcNow;
                }
                else
                {
                    Console.WriteLine($"➕ Creating NEW dependency: Option {option.QoptionId} -> Question {questionId}");
                    var newDep = new DependentQuestion
                    {
                        QoptionId = option.QoptionId,
                        NextQuestionId = questionId,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow,
                        ModifiedAt = DateTime.UtcNow
                    };
                    _context.DependentQuestions.Add(newDep);
                }
            }

            await _context.SaveChangesAsync();
            Console.WriteLine($"✅ Saved dependencies for Option {option.QoptionId}");
        }
        private async Task<bool> WouldCreateCircularDependency(
    int sourceOptionId,
    List<int> targetQuestionIds,
    int templateVersionId)
        {
            // Get the parent question of this option
            var sourceOption = await _context.QuestionOptions
                .Include(o => o.Question)
                .FirstOrDefaultAsync(o => o.QoptionId == sourceOptionId);

            if (sourceOption == null) return false;

            var sourceQuestionId = sourceOption.QuestionId;

            // For each target question, check if any of its options have sourceQuestion as a dependent
            foreach (var targetQuestionId in targetQuestionIds)
            {
                // Get all options of the target question
                var targetOptions = await _context.QuestionOptions
                    .Where(o => o.QuestionId == targetQuestionId && o.IsActive)
                    .Include(o => o.DependentQuestions.Where(d => d.IsActive))
                    .ToListAsync();

                foreach (var targetOption in targetOptions)
                {
                    // Check if any of these options have sourceQuestion as their dependent
                    var hasCircularDep = targetOption.DependentQuestions
                        .Any(d => d.IsActive && d.NextQuestionId == sourceQuestionId);

                    if (hasCircularDep)
                    {
                        Console.WriteLine($"🚫 CIRCULAR DEPENDENCY DETECTED: Question {sourceQuestionId} -> Question {targetQuestionId}, but Question {targetQuestionId} already depends on Question {sourceQuestionId}");
                        return true;
                    }
                }
            }

            return false;
        }

        private void UpdateQuestionOption(QuestionOption option, AnswerRequest answer)
        {
            Console.WriteLine($"Updating QuestionOption: ID={option.QoptionId}, SelectedOption={answer.SelectedOption}, SelectedMatComId={answer.SelectedMatComId}");

            option.OptionText = answer.Text;
            option.DisplayOrder = answer.Order;
            option.MatCompName = answer.SelectedOption;
            option.MaterialCompId = answer.SelectedMatComId;
            option.ModifiedAt = DateTime.UtcNow;

            Console.WriteLine($"After update: MatCompName={option.MatCompName}, MaterialCompId={option.MaterialCompId}");
        }

        public async Task<bool> DeleteQuestionAsync(int questionId)
        {
            var question = await _context.Questions
                .FirstOrDefaultAsync(q => q.QuestionId == questionId);

            if (question != null)
            {
                question.IsActive = false;
                question.ModifiedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
                return true;
            }

            return false;
        }
        // NEW: GUID + Version delete (like groups)
        public async Task<bool> DeleteQuestionbyGuidAsync(string questionGuid, int templateVersionId)
        {
            if (!Guid.TryParse(questionGuid, out var guid) || templateVersionId <= 0)
                return false;

            var businessId = GetCurrentBusinessId();

            // Find ONLY the question in the specified version
            var question = await _context.Questions
                .FirstOrDefaultAsync(q =>
                    q.QuestionGuid == guid &&
                    q.TemplateVersionId == templateVersionId &&
                    q.IsActive);

            if (question == null)
                return false;

            // Soft delete question ONLY in this templateVersion
            question.IsActive = false;
            question.ModifiedAt = DateTime.UtcNow;

            // Deactivate options that belong to this question (they are in this version)
            var options = _context.QuestionOptions
                .Where(o => o.QuestionId == question.QuestionId && o.IsActive);

            await foreach (var opt in options.AsAsyncEnumerable())
            {
                opt.IsActive = false;
                opt.ModifiedAt = DateTime.UtcNow;
            }

            // Remove dependencies where this question is involved as target,
            // but only those dependencies that reference this specific question record.
            var depsAsTarget = _context.DependentQuestions
                .Where(d => d.NextQuestionId == question.QuestionId && d.IsActive);

            // Remove dependencies where this question is the source (options belong to this question)
            var depsAsSource = from d in _context.DependentQuestions
                               join o in _context.QuestionOptions on d.QoptionId equals o.QoptionId
                               where o.QuestionId == question.QuestionId && d.IsActive
                               select d;

            if (depsAsTarget.Any())
                _context.DependentQuestions.RemoveRange(depsAsTarget);

            if (depsAsSource.Any())
                _context.DependentQuestions.RemoveRange(depsAsSource);

            await _context.SaveChangesAsync();
            return true;
        }
        private static QuestionResponse BuildResponse(Question question)
        {
            var answers = new List<AnswerIdMap>();

            if (question.QuestionOptions != null)
            {
                answers = question.QuestionOptions
                    .Where(o => o.IsActive)
                    .OrderBy(o => o.DisplayOrder)
                    .Select(o => new AnswerIdMap
                    {
                        Id = o.QoptionId,
                        Text = o.OptionText,
                        Order = o.DisplayOrder,
                        OptionGuid = o.OptionGuid.ToString()
                    })
                    .ToList();
            }

            return new QuestionResponse
            {
                Success = true,
                QuestionId = question.QuestionId,
                Text = question.Text,
                GroupId = question.QuestionGroupId,
                QuestionGuid = question.QuestionGuid.ToString(),
                Answers = answers
            };
        }
    }

    public class QuestionRequest
    {
        public int Id { get; set; }
        public string Text { get; set; }
        public int GroupId { get; set; }
        public string GroupGuid { get; set; } = string.Empty;
        public int FieldTypeId { get; set; }
        public int Order { get; set; }
        public bool IsRequired { get; set; }
        public int TemplateVersionId { get; set; }
        public List<AnswerRequest> Answers { get; set; } = new List<AnswerRequest>();
        public string QuestionGuid { get; set; } = string.Empty;
    }

    public class AnswerRequest
    {
        public int Id { get; set; }
        public string Text { get; set; }
        public int Order { get; set; }
        public string SelectedOption { get; set; }
        public int? SelectedMatComId { get; set; }
        public List<int> SelectedQuestionsList { get; set; } = new List<int>();
        public bool IsDeleted { get; set; }
        public string OptionGuid { get; set; } = string.Empty;
        // NEW: optionStatus flag to control algorithm ("new", "updated", "deleted")
        public string OptionStatus { get; set; } = string.Empty;
    }

    public class QuestionResponse
    {
        public bool Success { get; set; }
        public int QuestionId { get; set; }
        public string Text { get; set; }
        public int GroupId { get; set; }
        public string QuestionGuid { get; set; }
        public System.Collections.Generic.List<AnswerIdMap> Answers { get; set; } = new();
    }

    public class AnswerIdMap
    {
        public int Id { get; set; }
        public string Text { get; set; }
        public int Order { get; set; }
        public string OptionGuid { get; set; }
    }
}