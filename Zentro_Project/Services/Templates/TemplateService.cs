using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using zentro.DTOs;
using zentro.library;
using zentro.Models;
using zentro.View_Model;

namespace zentro.Templates
{
    public class TemplateService: ITemplateService
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public TemplateService(dbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        public List<TemplateDetails> FlatTemplateDetails(int templateVersionId)
        {
            return GetBaseFlatTemplateDetails(templateVersionId)
                  .Where(td =>
                      !_context.DependentQuestions
                          .Where(d => d.IsActive &&  // ✅ Check dependency is active
                              _context.QuestionOptions.Any(o => o.QoptionId == d.QoptionId && o.IsActive))  // ✅ Check source option is active
                          .Select(d => d.NextQuestionId)
                          .Contains(td.QuestionId))
                  .OrderBy(td => td.QuestionGroupDisplayOrder)
                  .ThenBy(td => td.QuestionDisplayOrder)
                  .ThenBy(td => td.OptionDisplayOrder)
                  .ToList();
        }

        public List<TemplateDetails> FlatDependentQuestionDetails(int templateVersionId, int questionOptionId)
        {
            return GetBaseFlatTemplateDetails(templateVersionId)
                  .Where(td =>
                       _context.DependentQuestions
                          .Where(d => d.QoptionId == questionOptionId &&
                                      d.IsActive &&  // ✅ Check dependency is active
                                      _context.QuestionOptions.Any(o => o.QoptionId == d.QoptionId && o.IsActive))  // ✅ Check source option is active
                          .Select(d => d.NextQuestionId)
                          .Contains(td.QuestionId))
                  .OrderBy(td => td.QuestionGroupDisplayOrder)
                  .ThenBy(td => td.QuestionDisplayOrder)
                  .ThenBy(td => td.OptionDisplayOrder)
                  .ToList();
        }

        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }

        public List<QuestionGroupDto> NormalizedList(List<TemplateDetails> flatList)
        {
            var groups = flatList
                .GroupBy(g => new
                {
                    g.QuestionGroupId,
                    g.QuestionGroupName,
                    g.QuestionGroupDisplayOrder
                })
                .Select(group => new QuestionGroupDto
                {
                    QuestionGroupId = group.Key.QuestionGroupId,
                    QuestionGroupName = group.Key.QuestionGroupName,
                    QuestionGroupDisplayOrder = group.Key.QuestionGroupDisplayOrder,

                    Questions = group
                        .Where(q => q.QuestionId != null)
                        .GroupBy(q => new
                        {
                            q.QuestionId,
                            q.QuestionText,
                            q.IsRequired,
                            q.QuestionDisplayOrder,
                            q.QuestionFieldTypeId,
                            q.FieldTypeName,
                            q.FieldTypeDisplayName
                        })
                        .Select(q => new QuestionDto
                        {
                            QuestionId = q.Key.QuestionId.Value,
                            QuestionText = q.Key.QuestionText,
                            IsRequired = q.Key.IsRequired,
                            QuestionDisplayOrder = q.Key.QuestionDisplayOrder,
                            QuestionFieldTypeId = q.Key.QuestionFieldTypeId,
                            FieldTypeName = q.Key.FieldTypeName,
                            FieldTypeDisplayName = q.Key.FieldTypeDisplayName,

                            Options = q
                                .Where(o => o.QOptionId != null)
                                .Select(o => new OptionDto
                                {
                                    QOptionId = o.QOptionId,
                                    OptionText = o.OptionText,
                                    OptionDisplayOrder = o.OptionDisplayOrder,
                                    OptionFieldTypeId = o.OptionFieldTypeId,

                                    MatCompName = o.MatCompName,
                                    MaterialCompId = o.MaterialCompId,
                                    Name = o.Name,
                                    SellPrice = o.SellPrice,
                                    CostPrice = o.CostPrice
                                })
                                .OrderBy(o => o.OptionDisplayOrder)
                                .ToList()
                        })
                        .OrderBy(q => q.QuestionDisplayOrder)
                        .ToList()
                })
                .OrderBy(g => g.QuestionGroupDisplayOrder)
                .ToList();

            return groups;
        }


        private List<TemplateDetails> GetBaseFlatTemplateDetails(int templateVersionId)
        {
            var result = (
            from qg in _context.QuestionGroups
            where qg.TemplateVersionId == templateVersionId && qg.IsActive == true  // ✅ Filter active groups

            join q in _context.Questions.Where(q => q.IsActive == true)  // ✅ Filter active questions
            on qg.QuestionGroupId equals q.QuestionGroupId into q_join
            from q in q_join.DefaultIfEmpty()

            join ft in _context.FieldTypes
            on q.FieldTypeId equals ft.FieldTypeId into ft_join
            from ft in ft_join.DefaultIfEmpty()

            join qo in _context.QuestionOptions.Where(o => o.IsActive == true)  // ✅ Filter active options
            on q.QuestionId equals qo.QuestionId into qo_join
            from qo in qo_join.DefaultIfEmpty()

            join m in _context.Materials
            on new { Name = qo.MatCompName, Id = qo.MaterialCompId }
            equals new { Name = "Material", Id = (int?)m.MaterialId }
            into m_join
            from m in m_join.DefaultIfEmpty()

            join c in _context.Components
            on new { Name = qo.MatCompName, Id = qo.MaterialCompId }
            equals new { Name = "Component", Id = (int?)c.ComponentId }
            into c_join
            from c in c_join.DefaultIfEmpty()

            select new TemplateDetails
            {
                QuestionGroupId = qg.QuestionGroupId,
                QuestionGroupName = qg.Name,
                QuestionGroupDisplayOrder = qg.DisplayOrder,

                QuestionId = q.QuestionId,
                QuestionText = q.Text,
                IsRequired = q.IsRequired,
                QuestionDisplayOrder = q.DisplayOrder,
                QuestionFieldTypeId = q.FieldTypeId,

                FieldTypeName = ft.FieldName,
                FieldTypeDisplayName = ft.DisplayName,

                QOptionId = qo.QoptionId,
                OptionText = qo.OptionText,
                OptionDisplayOrder = qo.DisplayOrder,
                OptionFieldTypeId = qo.FieldTypeId,

                MatCompName = qo.MatCompName,
                MaterialCompId = qo.MaterialCompId,

                Name = m != null ? m.Name : c.Name,
                SellPrice = m != null ? m.SellPrice : c.SellPrice,
                CostPrice = m != null ? m.CostPrice : c.BuildCost
            }
            ).ToList();

            return result;
        }


        //[HttpGet("TemplateDetail")]
        //public async Task<TemplateBuilderVM> GetTemplateDetail(int? id, int? tempVersionId = null, bool isNewTemplate = false)
        //{
        //    // STEP 1: Resolve latest version if not provided
        //    tempVersionId = ResolveTemplateVersionId(id, tempVersionId);

        //    // STEP 2: Initialize ViewModel
        //    var vm = InitializeTemplateBuilderVM();

        //    // STEP 3: Handle cases based on parameters
        //    if (id.HasValue && tempVersionId.HasValue)
        //    {
        //        return await BuildTemplateWithSelectedVersionAsync(id.Value, tempVersionId.Value, isNewTemplate, vm);
        //    }
        //    else if (id.HasValue)
        //    {
        //        return await BuildTemplateWithLatestVersionAsync(id.Value, isNewTemplate, vm);
        //    }
        //    else
        //    {
        //        return BuildEmptyTemplateVM(isNewTemplate, vm);
        //    }
        //}

        [HttpGet("TemplateDetail")]
        public async Task<TemplateBuilderVM> GetTemplateDetail(int? id)
        {
            // Initialize ViewModel
            var vm = InitializeTemplateBuilderVM();

            // Handle cases based on parameters
            if (id.HasValue)
            {
                return await BuildTemplateWithSelectedVersionAsync(id.Value, vm);
            }
            //else if (id.HasValue)
            //{
            //    return await BuildTemplateWithLatestVersionAsync(id.Value, isNewTemplate, vm);
            //}
            else
            {
                return BuildEmptyTemplateVM(vm);
            }
        }

        private TemplateVM MapTemplateData(zentro.Models.TemplateVersion templateVersion)
        {
            var result = (from t in _context.Templates
                          join tv in _context.TemplateVersions on t.TemplateId equals tv.TemplateId
                          join u in _context.Users on t.CreatedById equals u.Id

                          where tv.TempVersionId == templateVersion.TempVersionId
                          select new TemplateVM
                          {
                              Id = t.TemplateId,
                              Name = t.TemplateName,
                              Description = t.Description,
                              CreatedBy = u.FirstName + " " + u.LastName
                          }).FirstOrDefault();

            return result;
        }


        private int? ResolveTemplateVersionId(int? id, int? tempVersionId)
        {
            if (id.HasValue && (tempVersionId == null || tempVersionId == 0))
            {
                var latestVersion = GetLatestTemplateVersion(id.Value);
                if (latestVersion != null)
                    tempVersionId = latestVersion.TempVersionId;
            }

            return tempVersionId;
        }


        private TemplateBuilderVM InitializeTemplateBuilderVM()
        {
            return new TemplateBuilderVM
            {
                FieldTypes = GetFieldTypesList()
            };
        }

        private async Task<TemplateBuilderVM> BuildTemplateWithSelectedVersionAsync(
            int id, TemplateBuilderVM vm)
        {
            var selectedVersion = await _context.TemplateVersions.FindAsync(id);
            if (selectedVersion == null)
                return vm; // return empty VM if template not found

            

            vm.Template = MapTemplateData(selectedVersion);
            vm.IsActive = selectedVersion.IsActive;

            if (selectedVersion != null)
            {
                vm.SelectedVersion = MapTemplateVersionData(selectedVersion);

                //var latestVersion = GetLatestTemplateVersion(template.TemplateId);
                //if (latestVersion != null)
                    vm.LatestVersion = MapTemplateVersionData(selectedVersion);

               // vm.IsNewTemplate = isNewTemplate;
                vm.QuestionGroups = GetQuestionGroups(selectedVersion.TempVersionId);
                vm.QuestionAnswers = GetQuestionAnswers(selectedVersion.TempVersionId);

                var allVersions = GetTemplateAllVersions(selectedVersion.TemplateId);
                vm.AllVersions = allVersions.Select(MapTemplateVersionData).ToList();
            }

            return vm;
        }
        //private async Task<TemplateBuilderVM> BuildTemplateWithSelectedVersionAsync(
        //    int id, int tempVersionId, bool isNewTemplate, TemplateBuilderVM vm)
        //{
        //    var template = await _context.Templates.FindAsync(id);
        //    if (template == null)
        //        return vm; // return empty VM if template not found

        //    var selectedVersion = await _context.TemplateVersions.FindAsync(tempVersionId);

        //    vm.Template = MapTemplateData(template);
        //    vm.IsActive = template.IsActive;

        //    if (selectedVersion != null)
        //    {
        //        vm.SelectedVersion = MapTemplateVersionData(selectedVersion);

        //        var latestVersion = GetLatestTemplateVersion(template.TemplateId);
        //        if (latestVersion != null)
        //            vm.LatestVersion = MapTemplateVersionData(latestVersion);

        //        vm.IsNewTemplate = isNewTemplate;
        //        vm.QuestionGroups = GetQuestionGroups(selectedVersion.TempVersionId);
        //        vm.QuestionAnswers = GetQuestionAnswers(selectedVersion.TempVersionId);

        //        var allVersions = GetTemplateAllVersions(template.TemplateId);
        //        vm.AllVersions = allVersions.Select(MapTemplateVersionData).ToList();
        //    }

        //    return vm;
        //}

        //private async Task<TemplateBuilderVM> BuildTemplateWithLatestVersionAsync(
        //    int id, bool isNewTemplate, TemplateBuilderVM vm)
        //{
        //    var template = await _context.Templates.FindAsync(id);
        //    if (template == null)
        //        return vm;

        //    vm.Template = MapTemplateData(template);
        //    vm.IsActive = template.IsActive;

        //    var latestVersion = GetLatestTemplateVersion(template.TemplateId);
        //    if (latestVersion != null)
        //    {
        //        vm.LatestVersion = MapTemplateVersionData(latestVersion);
        //        vm.SelectedVersion = MapTemplateVersionData(latestVersion);
        //        vm.IsNewTemplate = isNewTemplate;

        //        vm.QuestionGroups = GetQuestionGroups(latestVersion.TempVersionId);
        //        vm.QuestionAnswers = GetQuestionAnswers(latestVersion.TempVersionId);

        //        var allVersions = GetTemplateAllVersions(template.TemplateId);
        //        vm.AllVersions = allVersions.Select(MapTemplateVersionData).ToList();
        //    }

        //    return vm;
        //}

        private TemplateBuilderVM BuildEmptyTemplateVM(TemplateBuilderVM vm)
        {
            vm.Template = new TemplateVM { Id = 0 };
            vm.SelectedVersion = new TemplateVersionVM();
            vm.LatestVersion = new TemplateVersionVM();
            vm.QuestionGroups = new List<QuestionGroupVM>();
            vm.QuestionAnswers = new List<QuestionViewModel>();
            return vm;
        }


        private TemplateVersion GetLatestTemplateVersion(int templateId)
        {
            return _context.TemplateVersions
                    .Where(v => v.TemplateId == templateId)
                    .OrderByDescending(v => v.TempVersion)
                    .FirstOrDefault();
        }

        private List<SelectListItem> GetFieldTypesList()
        {
            var fieldList = _context.FieldTypes.Where(f => f.IsActive == true).Select(f => new SelectListItem()
            {
                Text = f.DisplayName, //f.FieldName,
                Value = f.FieldTypeId.ToString()
            }).ToList();
            return fieldList;
        }
        private TemplateVM _MapTemplateData(zentro.Models.Template template)
        {
            var result = (from t in _context.Templates
                          join u in _context.Users on t.CreatedById equals u.Id
                          where t.TemplateId == template.TemplateId
                          select new TemplateVM
                          {
                              Id = template.TemplateId,
                              Name = template.TemplateName,
                              Description = template.Description,
                              CreatedBy = u.FirstName + " " + u.LastName
                          }).FirstOrDefault() ??
            new TemplateVM()
            {
                Id = template.TemplateId,
                Name = template.TemplateName,
                Description = template.Description
            };

            return result;
        }
        private TemplateVersionVM MapTemplateVersionData(TemplateVersion tv)
        {
            return new TemplateVersionVM()
            {
                TemplateVersionId = tv.TempVersionId,
                TempVersion = tv.TempVersion ?? 0,
                TempValidFrom = tv.TempValidFrom,
                TempValidTo = tv.TempValidTo,
                //CreatedBy = tv.CreatedBy 
            };
        }
        private List<QuestionGroupVM> GetQuestionGroups(int templateVersionId)
        {
            return _context.QuestionGroups
                        .Where(g => g.TemplateVersionId == templateVersionId && g.IsActive == true)
                        .Select(g => new QuestionGroupVM
                        {
                            Id = g.QuestionGroupId,
                            GroupGuid = g.GroupGuid,
                            Name = g.Name,
                            Order = g.DisplayOrder
                        })
                        .ToList();
        }
        private List<QuestionViewModel> GetQuestionAnswers(int templateVersionId)
        {
            // Fetch all questions and their dependencies with proper Includes
            var questions = _context.Questions
                .Where(q => q.TemplateVersionId == templateVersionId && q.IsActive == true)
                .Include(q => q.FieldType)
                .Include(q => q.QuestionGroup)
                .Include(q => q.QuestionOptions.Where(o => o.IsActive == true))
                    .ThenInclude(o => o.DependentQuestions.Where(dq => dq.IsActive == true))
                        .ThenInclude(dq => dq.NextQuestion)
                .ToList();

            // Build a lookup for all questions to access dependent questions efficiently
            var questionLookup = questions.ToDictionary(q => q.QuestionId, q => q);

            var result = questions.Select(q => new QuestionViewModel
            {
                Id = q.QuestionId,
                QuestionText = q.Text,
                QuestionGuid = q.QuestionGuid.ToString(),
                GroupGuid = q.QuestionGroup?.GroupGuid.ToString() ?? "",
                FieldTypeId = q.FieldTypeId ?? 0,
                IsRequired = q.IsRequired,
                Order = q.DisplayOrder,
                QuestionGroup = q.QuestionGroup?.Name ?? "",
                QuestionGrpId = q.QuestionGroup?.QuestionGroupId ?? 0,
                Answers = q.QuestionOptions
                    .Where(o => o.IsActive == true)
                    .Select(o => new AnswerViewModel
                    {
                        Id = o.QoptionId,
                        Option = o.OptionText,
                        OptionGuid = o.OptionGuid.ToString(),
                        AnswerGuid = o.OptionGuid.ToString(),
                        Order = o.DisplayOrder,
                        SelectedOption = o.MatCompName,
                        SelectedMatComId = o.MaterialCompId,
                        // ✅ ADD THESE TWO LINES:
                        SelectedQuestions = GetAllDependentQuestionIds(o, questionLookup),
                        SelectedQuestionsList = GetDependentQuestionIdsList(o, questionLookup)
                    }).ToList()
            }).ToList();

            return result;
        }

        // ✅ ADD THIS NEW METHOD to the class:
        private List<string> GetDependentQuestionIdsList(QuestionOption option, Dictionary<int, Question> questionLookup)
        {
            var dependentIds = new List<string>();

            if (option.DependentQuestions == null || !option.DependentQuestions.Any())
                return dependentIds;

            // Get only immediate dependent questions (not recursive)
            foreach (var dq in option.DependentQuestions.Where(dq => dq.IsActive == true && dq.NextQuestionId.HasValue))
            {
                // ✅ CRITICAL: Only add if the question exists in the current version
                if (dq.NextQuestionId.HasValue && questionLookup.ContainsKey(dq.NextQuestionId.Value))
                {
                    dependentIds.Add(dq.NextQuestionId.Value.ToString());
                }
                else if (dq.NextQuestionId.HasValue)
                {
                    // Question might be in a different version - try to find by GUID
                    Console.WriteLine($"⚠️ DependentQuestion {dq.NextQuestionId} not found in current version lookup");
                }
            }

            return dependentIds;
        }
        private string GetAllDependentQuestionIds(QuestionOption option, Dictionary<int, Question> questionLookup)
        {
            var dependentIds = new HashSet<int>();
            var queue = new Queue<Question>();

            // Initialize queue with immediate dependent questions
            foreach (var dq in option.DependentQuestions.Where(dq => dq.IsActive == true && dq.NextQuestion != null))
            {
                if (questionLookup.ContainsKey(dq.NextQuestion.QuestionId))
                {
                    queue.Enqueue(dq.NextQuestion);
                    dependentIds.Add(dq.NextQuestion.QuestionId);
                }
            }

            while (queue.Count > 0)
            {
                var current = queue.Dequeue();
                var options = current.QuestionOptions.Where(o => o.IsActive == true);

                // Add dependent questions to the queue and collect their IDs
                foreach (var opt in options)
                {
                    foreach (var dq in opt.DependentQuestions.Where(dq => dq.IsActive == true && dq.NextQuestion != null))
                    {
                        if (questionLookup.ContainsKey(dq.NextQuestion.QuestionId) && !dependentIds.Contains(dq.NextQuestion.QuestionId))
                        {
                            queue.Enqueue(dq.NextQuestion);
                            dependentIds.Add(dq.NextQuestion.QuestionId);
                        }
                    }
                }
            }

            return string.Join(",", dependentIds.OrderBy(id => id));
        }
        private List<TemplateVersion> GetTemplateAllVersions(int templateId)
        {
            return _context.TemplateVersions
                .Where(v => v.TemplateId == templateId)
                .OrderBy(v => v.TempVersion)
                .ToList();
        }

    }
}