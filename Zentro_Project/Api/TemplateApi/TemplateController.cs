using Independentsoft.Office.Odf;
using Independentsoft.Office.Odf.Charts;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
//using zentro.Api.TemplateServicesApi;
using zentro.Areas.Identity.Data;
using zentro.DTOs;
using zentro.library;
using zentro.Models;
using zentro.Services;
using zentro.Services.Group;
using zentro.Services.Questions;
using zentro.Services.Questions.zentro.Services.Questions;
using zentro.Services.TemplatesVersion;
using zentro.Templates;
using zentro.View_Model;
//using zentro.View_Model;

namespace zentro.Api.TemplateApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class TemplateController : Controller
    {
        private readonly dbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ITemplateService _templateService;
        private readonly IGroupService _groupService;
        private readonly IQuestionService _questionService;
        private readonly ITemplateVersionCheckService _templateVersionCheckService;
        private readonly IWebHostEnvironment _env;



        public TemplateController(dbContext context, UserManager<ApplicationUser> userManager, ITemplateVersionCheckService templateVersionCheckService,
 IHttpContextAccessor httpContextAccessor, IWebHostEnvironment env ,
             ITemplateService templateService, IGroupService groupService,
        IQuestionService questionService)
        {
            _context = context;
            _userManager = userManager;
            _httpContextAccessor = httpContextAccessor;
            _templateService = templateService;
            _groupService = groupService;
            _questionService = questionService;
            _templateVersionCheckService = templateVersionCheckService;
            _env = env;

        }

        [HttpPost("CloneTemplateVersion")]
        public async Task<IActionResult> CloneTemplateVersion([FromBody] int templateVersionId)
        {
            try
            {
                var modifiedById = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);

                //var modifiedById = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var newVersionId = await _templateVersionCheckService.CloneTemplateVersionAsync(templateVersionId, modifiedById);
                return Ok(new { success = true, newTemplateVersionId = newVersionId });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("GetTemplateIdByVersion")]
        public async Task<IActionResult> GetTemplateIdByVersion(int templateVersionId)
        {
            if (templateVersionId <= 0)
                return BadRequest(new { success = false, message = "Invalid templateVersionId" });

            var businessId = GetCurrentBusinessId();

            var templateId = await _context.TemplateVersions
                .Where(v => v.TempVersionId == templateVersionId && v.BusinessId == businessId)
                .Select(v => v.TemplateId)
                .FirstOrDefaultAsync();

            if (templateId == 0)
                return NotFound(new { success = false, message = "Template not found" });

            return Ok(new { success = true, templateId });
        }

        [HttpGet("GetTemplateName")]
        public async Task<IActionResult> GetTemplateName(int templateVersionId)
        {
            if (templateVersionId <= 0)
                return BadRequest(new { success = false, message = "Invalid templateVersionId" });

            var businessId = GetCurrentBusinessId();

            var templateId = await _context.TemplateVersions
                .Where(v => v.TempVersionId == templateVersionId && v.BusinessId == businessId)
                .Select(v => v.TemplateId)
                .FirstOrDefaultAsync();

            if (templateId == 0)
                return NotFound(new { success = false, message = "Template not found" });

            var templateName = await _context.Templates
                .Where(t => t.TemplateId == templateId && t.BusinessId == businessId)
                .Select(t => t.TemplateName)
                .FirstOrDefaultAsync();

            return Ok(new { success = true, templateName });
        }
        private List<TemplateVm> GenerateTemplateOverview(IQueryable<zentro.Models.Template> templateQuery)
        {
            List<TemplateVm> templates = new();

            if (templateQuery != null)
            {
                templates = templateQuery
                    .OrderByDescending(x => x.CreatedAt)
                    .Select(x => new TemplateVm
                    {
                        TemplateId = x.TemplateId,
                        TemplateName = x.TemplateName,
                        Description = x.Description,
                        IsActive = x.IsActive,
                        CreatedAt = x.CreatedAt,
                        CreatedBy = x.CreatedById,
                        Id = x.TemplateId,
                        Link = $"/Home/TemplateDetail/{x.TemplateId}?tempVersionId=" +
                               $"{x.TemplateVersions.OrderByDescending(v => v.TempVersionId).Select(v => v.TempVersionId).FirstOrDefault()}"
                              // $"&isNewTemplate=false"
                    })
                    .OrderByDescending(r => r.CreatedAt)
                    .ToList();
            }

            return templates;
        }

        [HttpPost("ToggleActive")]
        public async Task<IActionResult> ToggleActive([FromBody] ToggleActiveRequest request)
        {
            if (request == null || request.TemplateVersionId <= 0)
            {
                return BadRequest(new { success = false, message = "Invalid template version id" });
            }

            var templateId = await GetTemplateId(request.TemplateVersionId);

            if (templateId <= 0)
            {
                return BadRequest(new { success = false, message = "Template not found for given version" });
            }

            var template = await _context.Templates.FindAsync(templateId);

            if (template == null)
            {
                return BadRequest(new { success = false, message = "Template not found" });
            }

            template.IsActive = !template.IsActive;
            await _context.SaveChangesAsync();

            return Ok(new { success = true, isActive = template.IsActive });
        }

        public class ToggleActiveRequest
        {
            public int TemplateVersionId { get; set; }
        }
        [HttpGet("GetStatus/{templateVersionId}")]
        public async Task<IActionResult> GetStatus(int templateVersionId)
        {
            if (templateVersionId <= 0)
            {
                return BadRequest(new { error = "Invalid template version id" });
            }

            // Use your existing GetTemplateId method
            var templateId = await GetTemplateId(templateVersionId);

            if (templateId <= 0)
            {
                return NotFound(new { error = "Template not found for given version" });
            }

            var template = await _context.Templates.FindAsync(templateId);

            if (template == null)
            {
                return NotFound(new { error = "Template not found" });
            }

            return Ok(new { isActive = template.IsActive });
        }
        [HttpGet]
        public async Task<List<TemplateVm>> GetTemplates()
        {
            var businessId = GetCurrentBusinessId();

            IQueryable<zentro.Models.Template> query = _context.Templates
                .AsNoTracking()
                .Where(t => t.BusinessId == businessId);
            return GenerateTemplateOverview(query);
        }
        [HttpPost("Create")]

        [HttpPost]
        public async Task<IActionResult> Create(TemplateVM templateVM)
        {
            bool isAjax = Request.Headers["X-Requested-With"] == "XMLHttpRequest";

            if (templateVM == null)
                return BadRequest("Invalid template data.");

            try
            {
                zentro.Models.Template template = GetTemplateObject(templateVM);
                TemplateVersion templateVersion = GetTemplateVersionObject(templateVM);
                template.TemplateVersions = new List<TemplateVersion> { templateVersion };

                template.CreatedAt = DateTime.UtcNow;
                template.IsActive = true;
                template.CreatedById = _userManager.GetUserId(User); // ✅ same FK logic

                await _context.Templates.AddAsync(template);
                await _context.SaveChangesAsync();

                //var redirectUrl = Url.Action(
                //                            "TemplateDetail",
                //                            "Home",
                //                            new
                //                            {
                //                                id = template.TemplateVersions.First().TempVersionId
                //                            }
                //                        );

                var redirectUrl = Url.RouteUrl(
                    "TemplateDetail",
                    new
                    {
                        id = template.TemplateVersions.First().TempVersionId
                    }
                );

                if (isAjax)
                {
                    return Ok(new { success = true, redirect = redirectUrl });
                }

                return RedirectToAction("TemplateDetail", "Home", new
                {
                    id = templateVersion.TempVersionId
                });
            }
            catch (Exception ex)
            {
                if (isAjax)
                {
                    return StatusCode(500, new
                    {
                        success = false,
                        message = "An error occurred while creating the template.",
                        error = ex.Message
                    });
                }

                return StatusCode(500, "An error occurred while creating the template.");
            }
        }

        private TemplateVersion GetTemplateVersionObject(TemplateVM templateVM)
        {
            return new TemplateVersion
            {
                TempValidFrom = DateTime.UtcNow,
                //CreatedById = null,
                //CreatedAt = DateTime.UtcNow,
                TempVersion = 1,
                IsActive = true,
                BusinessId = GetCurrentBusinessId()
            };
        }
        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }
        private zentro.Models.Template GetTemplateObject(TemplateVM templateVM)
        {
            var businessId = GetCurrentBusinessId();

            return new zentro.Models.Template
            {
                TemplateName = templateVM.Name,
                Description = templateVM.Description,
                CreatedAt = DateTime.UtcNow,
                IsActive = true,
                CreatedById = _userManager.GetUserId(User),
                BusinessId = businessId 


            };
        }

        private async Task<bool> SaveTemplateToDbAsync(TemplateBuilderVM data)
        {
            try
            {
                // STEP 1: Create or update main Template
                zentro.Models.Template template = await UpdateTemplateNameDescriptionAsync(data);

                // STEP 2: Handle TemplateVersion (existing or new)
                TemplateVersion templateVersion = await GetOrCreateTemplateVersionAsync(data, template);
                if (templateVersion == null)
                    return true; // case where version already existed, and we already saved

                // ✅ STEP 3.5: Build and attach Metafields
                await BuildTemplateMetaFieldsAsync(data, template, templateVersion);

                // STEP 4: Save everything
                await _context.SaveChangesAsync();

                data.TemplateVersion.TemplateVersionId = templateVersion.TempVersionId;
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        private async Task<TemplateVersion> GetOrCreateTemplateVersionAsync(TemplateBuilderVM data, zentro.Models.Template template)
        {
            TemplateVersion templateVersion;
            if (IsTemplateVersionExists(template, data.TemplateVersion.TempVersion))
            {

                data.TemplateVersion.TemplateVersionId = _context.TemplateVersions
                    .Where(tv => tv.TempVersion == data.TemplateVersion.TempVersion && tv.TemplateId == template.TemplateId)
                    .Select(tv => tv.TempVersionId)
                    .FirstOrDefault();
                await _context.SaveChangesAsync();
                return null;
            }

            templateVersion = await BuildTemplateVersionAsync(data, template);
            return templateVersion;
        }

        private async Task BuildTemplateQuestionsAsync(TemplateBuilderVM data, zentro.Models.Template template, TemplateVersion templateVersion)
        {
            var vmToDbQuestionMap = new Dictionary<int, Question>();

            foreach (var groupVm in data.QuestionGroups)
            {
                var dbGroup = BuildQuestionGroup(groupVm, template, templateVersion);

                // Step 1: Create all questions for this group
                await CreateQuestionsForGroupAsync(data, groupVm, dbGroup, template, templateVersion, vmToDbQuestionMap);

                // Step 2: Create options and dependencies for those questions
                await CreateOptionsAndDependenciesAsync(data, groupVm, vmToDbQuestionMap);

                // Attach group to template
                template.QuestionGroups ??= new List<QuestionGroup>();
                template.QuestionGroups.Add(dbGroup);
            }
        }

        private async Task CreateQuestionsForGroupAsync(TemplateBuilderVM data, QuestionGroupVM groupVm, QuestionGroup dbGroup, zentro.Models.Template template, TemplateVersion templateVersion, Dictionary<int, Question> vmToDbQuestionMap)
        {
            var groupQuestions = data.QuestionAnswers
                .Where(q => q.QuestionGroup == groupVm.Name)
                .ToList();

            foreach (var questionVm in groupQuestions)
            {
                var dbQuestion = BuildQuestion(questionVm, template, templateVersion, dbGroup);
                dbGroup.Questions.Add(dbQuestion);
                vmToDbQuestionMap[questionVm.Id] = dbQuestion;
            }

            await Task.CompletedTask;
        }

        private async Task CreateOptionsAndDependenciesAsync(TemplateBuilderVM data, QuestionGroupVM groupVm, Dictionary<int, Question> vmToDbQuestionMap)
        {
            var groupQuestions = data.QuestionAnswers
                .Where(q => q.QuestionGroup == groupVm.Name)
                .ToList();

            foreach (var questionVm in groupQuestions)
            {
                var dbQuestion = vmToDbQuestionMap[questionVm.Id];
                dbQuestion.QuestionOptions ??= new List<QuestionOption>();

                foreach (var answerVm in questionVm.Answers)
                {
                    var dbOption = BuildQuestionOption(answerVm);
                    dbQuestion.QuestionOptions.Add(dbOption);

                    if (answerVm.SelectedQuestionsList == null || !answerVm.SelectedQuestionsList.Any())
                        continue;

                    foreach (var selectedIdStr in answerVm.SelectedQuestionsList)
                    {
                        if (string.IsNullOrWhiteSpace(selectedIdStr)) continue;
                        if (!int.TryParse(selectedIdStr, out var selectedQuestionVmId)) continue;

                        if (vmToDbQuestionMap.TryGetValue(selectedQuestionVmId, out var dependentQuestion))
                        {
                            var dependency = BuildDependQuestionObject(dbOption, dependentQuestion);
                            dbOption.DependentQuestions.Add(dependency);
                        }
                        else
                        {
                            // Try fetching from DB if dependency points to an existing question
                            var existingTarget = await _context.Questions.FindAsync(selectedQuestionVmId);
                            if (existingTarget != null)
                            {
                                var dependency = BuildDependQuestionObject(dbOption, existingTarget);
                                dbOption.DependentQuestions.Add(dependency);
                            }
                        }
                    }
                }
            }
        }

        private async Task BuildTemplateMetaFieldsAsync( TemplateBuilderVM data, zentro.Models.Template template, TemplateVersion templateVersion)
        {
            if (data.MetaFields == null || !data.MetaFields.Any())
                return;

            foreach (var metaVm in data.MetaFields)
            {
                // Skip empty names
                if (string.IsNullOrWhiteSpace(metaVm.Name))
                    continue;

                // If version already exists and this metafield is already stored
                if (metaVm.Id > 0)
                {
                    var exists = await _context.Metafields
                        .AnyAsync(m => m.PID == metaVm.Id &&
                                       m.TempVersionId == templateVersion.TempVersionId);

                    if (exists)
                        continue;
                }

                var dbMeta = BuildMetaField(metaVm, template, templateVersion);

                _context.Metafields.Add(dbMeta);
            }

            await Task.CompletedTask;
        }
        private Metafield BuildMetaField(
            MetafieldDto vm,
            zentro.Models.Template template,
            TemplateVersion templateVersion)
        {
            var userId = _userManager.GetUserId(User); // Get current user

            return new Metafield
            {
                TempVersionId = templateVersion.TempVersionId,
                Name = vm.Name,
                FieldType = vm.FieldType,
                Tag = vm.Tag,
                Visibility = vm.Visibility,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                CreatedById = userId,
                ModifiedAt = DateTime.UtcNow,
                ModifiedById = userId
            };
        }

        [HttpPost("SaveTemplate")]
        public async Task<IActionResult> SaveTemplate([FromBody] TemplateBuilderVM data)
        {
            if (data == null)
                return BadRequest(new { success = false, message = "Error: Data is incorrect." });

            var isSaved = await SaveTemplateToDbAsync(data);
            if (!isSaved)
                return BadRequest(new { success = false, message = "Error saving template." });

            // Return the new version info + any other relevant data
            return Ok(new
            {
                success = true,
                message = "Template saved successfully",
                templateVersionId = data.TemplateVersion.TemplateVersionId,
                tempVersion = data.TemplateVersion.TempVersion
                // optionally return the full templateId, groups, questions, metafields if needed
                // templateId = data.Template.TemplateId
            });
        }


        private async Task<zentro.Models.Template> UpdateTemplateNameDescriptionAsync(TemplateBuilderVM data)
        {
            // ✅ FIX: Add null checks and logging
            if (data?.Template == null)
            {
                throw new ArgumentNullException(nameof(data.Template), "Template data is null");
            }

           
            var templateVersionId = data.Template.TemplateVersionId;
            if (templateVersionId <= 0)
            {
                throw new InvalidOperationException("Invalid TemplateVersionId");
            }

            var templateId = await GetTemplateId(templateVersionId);

            if (templateId == null || templateId <= 0)
            {
                throw new InvalidOperationException($"Could not find template for version {templateVersionId}");
            }

            data.Template.Id = templateId.Value;
            var template = await _context.Templates.FindAsync(data.Template.Id);

            if (template == null)
            {
                throw new InvalidOperationException($"Template with ID {data.Template.Id} not found");
            }

            
            if (!string.IsNullOrWhiteSpace(data.Template.Name))
            {
                template.TemplateName = data.Template.Name;
            }

            // Description can be empty, so just check for null
            if (data.Template.Description != null)
            {
                template.Description = data.Template.Description;
            }

            _context.Update(template);
            return template;
        }

        private async Task<int?> GetTemplateId(int? templateVersionId)
        {
            return await _context.TemplateVersions
                .Where(v => v.TempVersionId == templateVersionId)
                .Select(v => v.TemplateId)
                .FirstOrDefaultAsync();
        }
        private TemplateVersion GetLatestTemplateVersion(int templateId)
        {
            return _context.TemplateVersions
                    .Where(v => v.TemplateId == templateId)
                    .OrderByDescending(v => v.TempVersion)
                    .FirstOrDefault();
        }
        private TemplateVersion GetTemplateVersion(int? versionId)
        {
            return _context.TemplateVersions
                    .Where(v => v.TempVersionId == versionId)
                    .FirstOrDefault();
        }
        private bool IsTemplateVersionExists(zentro.Models.Template template, int version)
        {
            return _context.TemplateVersions.Any(tv => tv.TemplateId == template.TemplateId && tv.TempVersion == version);
        }
        private async Task<TemplateVersion> BuildTemplateVersionAsync(TemplateBuilderVM data, zentro.Models.Template template)
        {
            TemplateVersion templateVersion;

            if (data.Template.Id > 0)
            {
                var latest = await _context.TemplateVersions
                                .Where(v => v.TemplateId == template.TemplateId)
                                .OrderByDescending(v => v.TempVersion)
                                .FirstOrDefaultAsync();

                if (latest != null)
                {
                    latest.TempValidTo = DateTime.UtcNow;
                }

                var nextVersionNumber = (latest?.TempVersion ?? 0) + 1;

                templateVersion = new TemplateVersion
                {
                    Template = template,
                    TempVersion = nextVersionNumber,              // bump version
                    TempValidFrom = DateTime.UtcNow,
                    BusinessId = GetCurrentBusinessId()

                };

                _context.TemplateVersions.Add(templateVersion);
            }
            else
            {
                templateVersion = new TemplateVersion
                {
                    Template = template,
                    TempVersion = 1,
                    TempValidFrom = DateTime.UtcNow,
                    BusinessId = GetCurrentBusinessId()
                };

                _context.TemplateVersions.Add(templateVersion);
            }
            await _context.SaveChangesAsync();

            return templateVersion;
        }
        private QuestionGroup BuildQuestionGroup(QuestionGroupVM group, zentro.Models.Template template, TemplateVersion templateVersion)
        {
            return new QuestionGroup
            {
                Name = group.Name,
                DisplayOrder = group.Order,
                Template = template,
                TemplateVersion = templateVersion,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                BusinessId = GetCurrentBusinessId()
            };
        }
        private Question BuildQuestion(QuestionViewModel qVm, zentro.Models.Template template, TemplateVersion templateVersion, QuestionGroup dbGroup)
        {
            return new Question
            {
                Text = qVm.QuestionText,
                Template = template,
                TemplateVersion = templateVersion,
                QuestionGroup = dbGroup,
                FieldTypeId = qVm.FieldTypeId,
                IsRequired = qVm.IsRequired,
                //CreatedDate = DateTime.UtcNow,
                ValidFrom = DateTime.UtcNow,
                DisplayOrder = qVm.Order,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                QuestionOptions = new List<QuestionOption>(),
                BusinessId = GetCurrentBusinessId()
            };
        }

        private QuestionOption BuildQuestionOption(AnswerViewModel ansVm)
        {
            return new QuestionOption
            {
                OptionText = ansVm.Option,
                MatCompName = ansVm.SelectedOption,
                MaterialCompId = ansVm.SelectedMatComId,
                DisplayOrder = ansVm.Order,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                DependentQuestions = new List<DependentQuestion>()
            };
        }
        private DependentQuestion BuildDependQuestionObject(QuestionOption dbOption, Question nextQuestion)
        {
            return new DependentQuestion
            {
                Qoption = dbOption,
                NextQuestion = nextQuestion,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };
        }
        [HttpGet("Builder")]
        public async Task<IActionResult> Builder(int? templateId, int? tempVersionId = null)
        {
            TemplateBuilderVM vm = new TemplateBuilderVM
            {
                FieldTypes = GetFieldTypesList()
            };

            // Select version from dropdown
            if (templateId.HasValue && tempVersionId.HasValue)
            {
                var template = await _context.Templates.FindAsync(templateId.Value);

                if (template == null)
                {
                    return RedirectToAction("Index");
                }

                var selectedVersion = await _context.TemplateVersions.FindAsync(tempVersionId);

                vm.Template = MapTemplateData(template);

                if (selectedVersion != null)
                {
                    vm.SelectedVersion = MapTemplateVersionData(selectedVersion);

                    var latestVersion = GetLatestTemplateVersion(template.TemplateId);

                    if (latestVersion != null)
                    {
                        vm.LatestVersion = MapTemplateVersionData(latestVersion);
                    }

                   // vm.IsNewTemplate = isNewTemplate;

                    vm.QuestionGroups = GetQuestionGroups(selectedVersion.TempVersionId);

                    vm.QuestionAnswers = GetQuestionAnswers(selectedVersion.TempVersionId);

                    var allVersions = GetTemplateAllVersions(template.TemplateId);

                    foreach (var v in allVersions)
                    {
                        var versionVm = MapTemplateVersionData(v);
                        vm.AllVersions.Add(versionVm);
                    }

                }

            }
            else if (templateId.HasValue)
            {
                var template = await _context.Templates.FindAsync(templateId.Value);
                if (template == null)
                {
                    return RedirectToAction("Index");
                }

                vm.Template = MapTemplateData(template);

                var latestVersion = GetLatestTemplateVersion(template.TemplateId);


                if (latestVersion != null)
                {
                    vm.LatestVersion = MapTemplateVersionData(latestVersion);

                    vm.SelectedVersion = MapTemplateVersionData(latestVersion);

                   // vm.IsNewTemplate = isNewTemplate;

                    vm.QuestionGroups = GetQuestionGroups(latestVersion.TempVersionId);

                    vm.QuestionAnswers = GetQuestionAnswers(latestVersion.TempVersionId);

                    var allVersions = GetTemplateAllVersions(template.TemplateId);

                    foreach (var v in allVersions)
                    {
                        var versionVm = MapTemplateVersionData(v);
                        vm.AllVersions.Add(versionVm);
                    }
                }
            }
            else
            {
                vm.Template = new TemplateVM { Id = 0 };
                if (TempData["TemplateName"] != null)
                {
                    vm.Template.Name = TempData["TemplateName"].ToString();
                    vm.Template.Description = TempData["TemplateDescription"]?.ToString();

                    TempData.Keep("TemplateName");
                    TempData.Keep("TemplateDescription");
                }
               // vm.IsNewTemplate = isNewTemplate;
                vm.SelectedVersion = new TemplateVersionVM();
                vm.LatestVersion = new TemplateVersionVM();
                vm.QuestionGroups = new List<QuestionGroupVM>();
                vm.QuestionAnswers = new List<QuestionViewModel>();
            }

            return View(vm);
        }
        private List<SelectListItem> GetFieldTypesList()
        {
            var fieldList = _context.FieldTypes.Where(f => f.IsActive == true).Select(f => new SelectListItem()
            {
                Text = f.FieldName,
                Value = f.FieldTypeId.ToString()
            }).ToList();
            return fieldList;
        }
        private TemplateVM MapTemplateData(zentro.Models.Template template)
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
            var businessId = GetCurrentBusinessId();

            return new TemplateVersionVM()
            {
                TemplateVersionId = tv.TempVersionId,
                TempVersion = tv.TempVersion ?? 0,
                TempValidFrom = tv.TempValidFrom,
                TempValidTo = tv.TempValidTo
                //CreatedBy = tv.CreatedBy 
            };
        }
        private List<QuestionGroupVM> GetQuestionGroups(int templateVersionId)
        {
            var businessId = GetCurrentBusinessId();

            var versionOk = _context.TemplateVersions
                .Any(tv => tv.TempVersionId == templateVersionId && tv.BusinessId == businessId); // ✅ scope

            if (!versionOk) return new List<QuestionGroupVM>();

            return _context.QuestionGroups
                        .Where(g => g.TemplateVersionId == templateVersionId && g.IsActive == true)
                        .Select(g => new QuestionGroupVM
                        {
                            Id = g.QuestionGroupId,
                            Name = g.Name,
                            Order = g.DisplayOrder
                        })
                        .ToList();
        }
        private List<QuestionViewModel> GetQuestionAnswers(int templateVersionId)
        {
            var questions = _context.Questions
                .Where(q => q.TemplateVersionId == templateVersionId && q.IsActive)
                .Include(q => q.QuestionGroup)
                .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                .OrderBy(q => q.DisplayOrder)
                .Select(q => new QuestionViewModel
                {
                    Id = q.QuestionId,
                    QuestionText = q.Text,
                    QuestionGuid = q.QuestionGuid.ToString(),  // ✅ Ensure this exists
                    GroupGuid = q.QuestionGroup != null ? q.QuestionGroup.GroupGuid.ToString() : string.Empty,
                    QuestionGroup = q.QuestionGroup.Name,
                    QuestionGrpId = q.QuestionGroupId,
                    FieldTypeId = q.FieldTypeId,
                    Order = q.DisplayOrder,
                    IsRequired = q.IsRequired,
                    Answers = q.QuestionOptions
                        .Where(o => o.IsActive)
                        .OrderBy(o => o.DisplayOrder)
                        .Select(o => new AnswerViewModel
                        {
                            Id = o.QoptionId,
                            Option = o.OptionText,
                            OptionGuid = o.OptionGuid.ToString(),  // ✅ ADD THIS LINE - use OptionGuid not just AnswerGuid
                            AnswerGuid = o.OptionGuid.ToString(),  // ✅ Keep this for backward compatibility
                            Order = o.DisplayOrder,
                            SelectedOption = o.MatCompName,
                            SelectedMatComId = o.MaterialCompId,
                            SelectedQuestionsList = o.DependentQuestions
                                .Where(dq => dq.IsActive && dq.NextQuestion != null)
                                .Select(dq => dq.NextQuestionId.ToString())
                                .ToList()
                        }).ToList()
                })
                .ToList();

            return questions;
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
                .Where(tv => tv.TemplateId == templateId && tv.IsActive == true)
                .ToList();
        }

        
        [HttpPost("PreviewTemplate")]
        public async Task<IActionResult> PreviewTemplate([FromBody] TemplateBuilderVM data)
        {
            try
            {
                if (data == null)
                    return BadRequest(new { success = false, message = "Error: Data is incorrect." });

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }
                var isSaved = await SaveTemplateToDbAsync(data);
                if (!isSaved)
                    return BadRequest(new { success = false, message = "Error saving template." });

                // Get the template version ID
                var templateVersionId = data?.TemplateVersion?.TemplateVersionId ?? 0;

                if (templateVersionId == 0)
                {
                    return BadRequest(new { success = false, message = "Template version ID not found after save." });
                }

                return Ok(new
                {
                    success = true,
                    isPreviewPage = true,
                    message = "Template saved successfully.",
                    redirectUrl = Url.Content($"~/page/template/preview/{templateVersionId}"),
                    templateId = data?.Template?.Id ?? 0,
                    templateVersionId = templateVersionId
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = $"Server Exception: {ex.Message}" });
            }
        }

        [HttpGet("ListAll")]
        public async Task<IActionResult> GetAllTemplatesForList()
        {
            var businessId = GetCurrentBusinessId();
            var templates = await _context.Templates
                .Where(t => t.BusinessId == businessId)
                .Include(t => t.CreatedBy) // ✅ Include the related user
                .Select(t => new
                {
                    TemplateId = t.TemplateId,
                    TemplateName = t.TemplateName,
                    Description = t.Description,
                    CreatedAt = t.CreatedAt ?? DateTime.UtcNow,
                    // ✅ Pull the creator's full name if available
                    CreatedBy = t.CreatedBy != null
                                ? $"{t.CreatedBy.FirstName} {t.CreatedBy.LastName}"
                                : "Unknown",
                    IsActive = t.IsActive,
                    LatestTempVersionId = t.TemplateVersions
                        .OrderByDescending(v => v.TempVersionId)
                        .Select(v => v.TempVersionId)
                        .FirstOrDefault()
                })
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return Ok(templates);
        }

        // ----------------- GET: Filtered Templates -----------------
        [HttpGet("FilterTemplateIndex")]
        public JsonResult FilterTemplateIndex(
            [FromQuery(Name = "sT")] string? sT,
            [FromQuery(Name = "search")] string? search,
            [FromQuery(Name = "createdBy")] string? createdBy,
            [FromQuery(Name = "dateFrom")] string? dateFrom,
            [FromQuery(Name = "dateTo")] string? dateTo,
            [FromQuery(Name = "status")] List<string>? statusList // <-- added here
        )
        {
            var businessId = GetCurrentBusinessId();
            // base scoped query
            IQueryable<zentro.Models.Template> query = _context.Templates
                .Where(t => t.IsActive == true)
                .Where(t => t.BusinessId == businessId);
            // Accept either ?search=... or ?sT=...
            if (string.IsNullOrWhiteSpace(search) && !string.IsNullOrWhiteSpace(sT))
            {
                search = sT;
            }

            // Search: accept "q" style or plain text
            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.Trim();
                if (s.StartsWith("q", StringComparison.OrdinalIgnoreCase))
                    s = s.Substring(1).Trim();

                s = s.ToLower();
                query = query.Where(t =>
                    (!string.IsNullOrEmpty(t.TemplateName) && t.TemplateName.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(t.Description) && t.Description.ToLower().Contains(s))
                );
            }

            // Filter by createdBy (match id or name)
            if (!string.IsNullOrWhiteSpace(createdBy))
            {
                var cb = createdBy.Trim().ToLower();
                query = query.Where(t =>
                    (!string.IsNullOrEmpty(t.CreatedById) && t.CreatedById.ToLower() == cb) ||
                    (t.CreatedBy != null && (
                        (!string.IsNullOrEmpty(t.CreatedBy.FirstName) && t.CreatedBy.FirstName.ToLower().Contains(cb)) ||
                        (!string.IsNullOrEmpty(t.CreatedBy.LastName) && t.CreatedBy.LastName.ToLower().Contains(cb))
                    ))
                );
            }

            // Date range filtering for CreatedAt
            if (DateTime.TryParse(dateFrom, out DateTime parsedFrom) ||
                DateTime.TryParse(dateTo, out DateTime parsedTo))
            {
                bool hasFrom = DateTime.TryParse(dateFrom, out parsedFrom);
                bool hasTo = DateTime.TryParse(dateTo, out parsedTo);

                if (hasFrom && hasTo)
                {
                    parsedTo = parsedTo.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(t => t.CreatedAt >= parsedFrom && t.CreatedAt <= parsedTo);
                }
                else if (hasFrom)
                {
                    query = query.Where(t => t.CreatedAt >= parsedFrom);
                }
                else if (hasTo)
                {
                    parsedTo = parsedTo.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(t => t.CreatedAt <= parsedTo);
                }
            }

            // ✅ Status filter fix
            if (statusList != null && statusList.Any())
            {
                // Support multiple statuses (e.g. ?status=active&status=inactive)
                var lowerStatuses = statusList.Select(s => s.ToLower()).ToList();

                if (lowerStatuses.Contains("active") && !lowerStatuses.Contains("inactive"))
                    query = query.Where(x => x.IsActive == true);
                else if (lowerStatuses.Contains("inactive") && !lowerStatuses.Contains("active"))
                    query = query.Where(x => x.IsActive == false);
                // if both included, no need to filter (means show all)
            }

            // Use existing helper to build view models
            var templates = GenerateTemplateOverview(query);

            // Keep same shape as ComponentController so frontend that expects { lists: [...] } works
            return new JsonResult(new { lists = templates });
        }



        // ----------------- GET: Template Filter Lists (creators, versions, etc) -----------------
        [HttpGet("TemplateFilterLists")]
        public JsonResult TemplateFilterLists()
        {
            var businessId = GetCurrentBusinessId();
            // Creator list (value = id, name = "First Last" if available)
            var creatorList = _context.Templates
                .Where(t => t.IsActive == true && t.BusinessId == businessId && !string.IsNullOrEmpty(t.CreatedById))
                .Include(t => t.CreatedBy)
                .Select(t => new
                {
                    value = t.CreatedById,
                    name = t.CreatedBy != null
                        ? (t.CreatedBy.FirstName + " " + t.CreatedBy.LastName).Trim()
                        : t.CreatedById
                })
                .Distinct()
                .OrderBy(x => x.name)
                .ToList();

            // Template version numbers available (if you want this)
            var versionList = _context.TemplateVersions
                .Where(v => v.IsActive == true && v.BusinessId == businessId)
                .Select(v => v.TempVersion ?? 0)
                .Distinct()
                .OrderBy(v => v)
                .Select(v => new { value = v, name = $"v{v}" })
                .ToList();
            var statusLists = new List<object>
    {
        new { value = "active", name = "Active" },
        new { value = "inactive", name = "Inactive" }
    };

            var lists = new
            {
                createdByLists = creatorList,
                versionLists = versionList,
                statusLists = statusLists
            };

            // Keep same wrapper as ComponentController: lists is an array with a single object
            return new JsonResult(new { lists = new List<object> { lists } });
        }

        [HttpGet("preview")]
        public async Task<ActionResult<UserAnswerVM>> TemplateDetailsForPreview([FromQuery] int templateVersionId)
        {
            return await GetRootQuestions(templateVersionId); 
        }
        [HttpGet("CheckQuotesOnVersion")]
        public async Task<IActionResult> CheckQuotesOnVersion([FromQuery] int versionId)
        {
            if (versionId <= 0)
                return BadRequest("Invalid versionId");

            bool exists = await _context.UserRecords
                .AnyAsync(u => u.TempVersionId == versionId);

            return Ok(exists);
        }


        private (decimal CostPrice, decimal SellPrice) GetOptionCostAndSellPrice(int optionId)
        {
            var option = _context.QuestionOptions.FirstOrDefault(o => o.QoptionId == optionId);
            if (option == null) return (0m, 0m);

            if (option.MatCompName == "Material" && option.MaterialCompId.HasValue)
            {
                var material = _context.Materials.FirstOrDefault(m => m.MaterialId == option.MaterialCompId.Value);
                if (material != null)
                    return (material.CostPrice ?? 0m, material.SellPrice ?? 0m);
            }
            else if (option.MatCompName == "Component" && option.MaterialCompId.HasValue)
            {
                var component = _context.Components.FirstOrDefault(c => c.ComponentId == option.MaterialCompId.Value);
                if (component != null)
                    return (component.BuildCost, component.SellPrice);
            }
            return (0m, 0m);
        }


        [HttpGet("TemplateDetail/GetData")]
        public async Task<IActionResult> GetTemplateDetailJson(int? id)
        {
            var vm = await _templateService.GetTemplateDetail(id);
            //var vm = await _templateService.GetTemplateDetail(id, tempVersionId, isNewTemplate);
            return Json(vm); // this will work here
        }

        [HttpGet("ByOptionId")]
        public async Task<IActionResult> GetByOptionId(int optionId)
        {
            if (optionId <= 0) return BadRequest();

            var opt = _context.QuestionOptions
                              .Where(o => o.QoptionId == optionId)
                              .Select(o => new { o.QoptionId, o.MatCompName, o.MaterialCompId })
                              .FirstOrDefault();

            if (opt == null) return NotFound();

            if (opt.MatCompName == "Material" && opt.MaterialCompId.HasValue)
            {
                var mat = _context.Materials
                                  .Where(m => m.MaterialId == opt.MaterialCompId.Value)
                                  .Select(m => new { m.MaterialId, m.Name })
                                  .FirstOrDefault();

                return Ok(new
                {
                    MatCompName = "Material",
                    MaterialCompId = mat?.MaterialId,
                    Name = mat?.Name
                });
            }

            if (opt.MatCompName == "Component" && opt.MaterialCompId.HasValue)
            {
                var comp = _context.Components
                                   .Where(c => c.ComponentId == opt.MaterialCompId.Value)
                                   .Select(c => new { c.ComponentId, c.Name })
                                   .FirstOrDefault();

                return Ok(new
                {
                    MatCompName = "Component",
                    MaterialCompId = comp?.ComponentId,
                    Name = comp?.Name
                });
            }

            // If neither mapped or no ID available
            return Ok(new
            {
                MatCompName = (string?)null,
                MaterialCompId = (int?)null,
                Name = (string?)null
            });
        }


        [HttpGet("root-questions")]
        public async Task<ActionResult<UserAnswerVM>> GetRootQuestions([FromQuery] int templateVersionId)
        {
            var businessId = GetCurrentBusinessId();

            // Ensure version belongs to this business
            var version = await _context.TemplateVersions
                .AsNoTracking()
                .Where(v => v.TempVersionId == templateVersionId && v.BusinessId == businessId)
                .FirstOrDefaultAsync();

            if (version == null) return Ok(new UserAnswerVM());
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);

            UserAnswerVM userAnswerVM = GetRootQuestionsOnly(templateVersionId);
            return Ok(userAnswerVM);
        }

        [HttpGet("dependent-questions")]
        public async Task<IActionResult> GetDependentQuestions([FromQuery] int optionId)
        {
            Console.WriteLine($"🔍 GetDependentQuestions called for optionId: {optionId}");

            // ✅ STEP 1: Get the option and its parent question's version
            var option = await _context.QuestionOptions
                .Include(o => o.Question)
                .FirstOrDefaultAsync(o => o.QoptionId == optionId);

            if (option == null)
            {
                Console.WriteLine($"❌ Option {optionId} not found");
                return NotFound(new { message = $"Option {optionId} not found" });
            }

            var templateVersionId = option.Question.TemplateVersionId;
            Console.WriteLine($"📋 Option belongs to TemplateVersionId: {templateVersionId}");

            // ✅ STEP 2: Get ALL active dependencies for this option
            var dependencies = await _context.DependentQuestions
                .Where(d => d.QoptionId == optionId && d.IsActive)
                .ToListAsync();

            Console.WriteLine($"📋 Found {dependencies.Count} dependencies in database");

            var dependentQuestions = new List<object>();

            foreach (var dep in dependencies)
            {
                if (dep.NextQuestionId == null) continue;

                // ✅ STEP 3: Get the target question
                var targetQuestion = await _context.Questions
                    .AsNoTracking()
                    .FirstOrDefaultAsync(q => q.QuestionId == dep.NextQuestionId.Value && q.IsActive);

                if (targetQuestion == null)
                {
                    Console.WriteLine($"⚠️ Target question {dep.NextQuestionId} not found");
                    continue;
                }

                // ✅ STEP 4: Check if target question is in the SAME version
                if (targetQuestion.TemplateVersionId == templateVersionId)
                {
                    // ✅ Same version - return it directly
                    dependentQuestions.Add(new
                    {
                        questionId = targetQuestion.QuestionId,
                        questionText = targetQuestion.Text,
                        templateVersionId = targetQuestion.TemplateVersionId
                    });
                    Console.WriteLine($"   ✅ Question {targetQuestion.QuestionId} is in same version {templateVersionId}");
                }
                else
                {
                    // ✅ CRITICAL: Different version - find the equivalent question in current version by GUID
                    Console.WriteLine($"   ⚠️ Question {targetQuestion.QuestionId} is in version {targetQuestion.TemplateVersionId}, need to resolve to version {templateVersionId}");

                    if (targetQuestion.QuestionGuid == Guid.Empty)
                    {
                        Console.WriteLine($"   ❌ Question has empty GUID, cannot resolve");
                        continue;
                    }

                    var equivalentQuestion = await _context.Questions
                        .AsNoTracking()
                        .FirstOrDefaultAsync(q =>
                            q.QuestionGuid == targetQuestion.QuestionGuid &&
                            q.TemplateVersionId == templateVersionId &&
                            q.IsActive);

                    if (equivalentQuestion != null)
                    {
                        dependentQuestions.Add(new
                        {
                            questionId = equivalentQuestion.QuestionId,
                            questionText = equivalentQuestion.Text,
                            templateVersionId = equivalentQuestion.TemplateVersionId
                        });
                        Console.WriteLine($"   ✅ Resolved to Question {equivalentQuestion.QuestionId} in version {templateVersionId}");
                    }
                    else
                    {
                        Console.WriteLine($"   ❌ Could not find equivalent question with GUID {targetQuestion.QuestionGuid} in version {templateVersionId}");
                    }
                }
            }

            Console.WriteLine($"✅ Returning {dependentQuestions.Count} dependent questions for optionId {optionId}");

            return Ok(dependentQuestions);
        }

        private UserAnswerVM GetRootQuestionsOnly(int templateVersionId)
        {
            var templateVersion = _context.TemplateVersions
                .AsNoTracking()
                .FirstOrDefault(v => v.TempVersionId == templateVersionId);

            if (templateVersion == null) return new UserAnswerVM();

            int templateId = templateVersion.TemplateId;

            // Get template name
            var templateName = _context.Templates
                .AsNoTracking()
                .Where(t => t.TemplateId == templateId)
                .Select(t => t.TemplateName)
                .FirstOrDefault();

            // Get groups
            var groups = _context.QuestionGroups
                .AsNoTracking()
                .Where(qg => qg.TemplateId == templateId &&
                             qg.TemplateVersionId == templateVersionId &&
                             qg.IsActive)
                .OrderBy(qg => qg.DisplayOrder)
                .ToList();

            // Get ONLY root questions (no dependent questions)
            var questions = _context.Questions
                .AsNoTracking()
                .Where(q => q.TemplateId == templateId &&
                            q.TemplateVersionId == templateVersionId &&
                            q.IsActive &&
                            !_context.DependentQuestions.Any(dq => dq.NextQuestionId == q.QuestionId && dq.IsActive))
                .Include(q => q.QuestionOptions.Where(o => o.IsActive))
                    .ThenInclude(o => o.DependentQuestions.Where(dq => dq.IsActive)) // Include dependency info
                .Include(q => q.FieldType)
                .OrderBy(q => q.DisplayOrder)
                .ToList();

            // Get option prices for root questions only
            var optionPrices = questions
                .SelectMany(q => q.QuestionOptions)
                .Select(opt =>
                {
                    var (cost, sell) = GetOptionCostAndSellPrice(opt.QoptionId);
                    return new OptionPriceVM
                    {
                        OptionId = opt.QoptionId,
                        CostPrice = cost,
                        SellPrice = sell
                    };
                })
                .ToList();

            return new UserAnswerVM
            {
                dbQuestionGroups = groups,
                dbQuestions = questions,
                TemplateId = templateId,
                TemplateVersion = templateVersionId,
                TemplateName = templateName,
                OptionPrices = optionPrices
            };
        }

        [HttpGet("debug-dependent-questions")]
        public async Task<IActionResult> DebugDependentQuestions([FromQuery] int optionId)
        {
            try
            {
                Console.WriteLine($"🔍 DEBUG: Fetching dependent questions for option {optionId}");

                // Check if option exists
                var optionExists = await _context.QuestionOptions.AnyAsync(o => o.QoptionId == optionId);
                if (!optionExists)
                {
                    return NotFound(new { message = $"Option with ID {optionId} not found" });
                }

                var dependentQuestions = await _context.DependentQuestions
                    .Where(dq => dq.QoptionId == optionId && dq.IsActive)
                    .ToListAsync();

                Console.WriteLine($"🔍 DEBUG: Found {dependentQuestions.Count} dependent question relations");

                // Use projection instead of Include
                var questions = await _context.DependentQuestions
                    .Where(dq => dq.QoptionId == optionId && dq.IsActive)
                    .Select(dq => new
                    {
                        QuestionId = dq.NextQuestion.QuestionId,
                        Text = dq.NextQuestion.Text,
                        FieldTypeName = dq.NextQuestion.FieldType.FieldName
                    })
                    .OrderBy(q => q.QuestionId)
                    .ToListAsync();

                Console.WriteLine($"✅ DEBUG: Returning {questions.Count} questions");

                return Ok(new
                {
                    optionExists = true,
                    dependentRelationCount = dependentQuestions.Count,
                    questions = questions
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ DEBUG ERROR: {ex.Message}");
                Console.WriteLine($"❌ DEBUG STACK TRACE: {ex.StackTrace}");
                return StatusCode(500, new
                {
                    message = "Internal server error",
                    error = ex.Message,
                    stackTrace = ex.StackTrace
                });
            }
        }
        // ================== GROUP APIs ==================

        [HttpPost("CreateGroup")]
        public async Task<IActionResult> CreateGroup([FromBody] GroupRequest request)
        {
            try
            {
                var result = await _groupService.CreateOrUpdateGroupAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpDelete("DeleteGroup")]
        public async Task<IActionResult> DeleteGroup(
    [FromQuery] string groupGuid,
    [FromQuery] int templateVersionId)
        {
            try
            {
                var success = await _groupService
                    .DeleteGroupByGuidAsync(groupGuid, templateVersionId);

                return Ok(new { success });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }


        [HttpPost("CreateQuestion")]
        public async Task<IActionResult> CreateQuestion([FromBody] QuestionRequest request)
        {
            try
            {
                Console.WriteLine("=== CreateQuestion API Called ===");
                Console.WriteLine($"Request: Id={request.Id}, Text={request.Text}, GroupId={request.GroupId}, TemplateVersionId={request.TemplateVersionId}");
                Console.WriteLine($"Answers count: {request.Answers?.Count ?? 0}");

                var result = await _questionService.CreateOrUpdateQuestionAsync(request);

                Console.WriteLine($"Response: Success={result.Success}, QuestionId={result.QuestionId}");

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== ERROR in CreateQuestion ===");
                Console.WriteLine($"Message: {ex.Message}");
                Console.WriteLine($"Inner: {ex.InnerException?.Message}");

                return StatusCode(500, new
                {
                    success = false,
                    message = "Internal server error",
                    error = ex.Message,
                    innerError = ex.InnerException?.Message
                });
            }
        }

        [HttpDelete("DeleteQuestionByGuid")]
        public async Task<IActionResult> DeleteQuestion([FromQuery] string questionGuid, [FromQuery] int templateVersionId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(questionGuid) || templateVersionId <= 0)
                {
                    return BadRequest(new { success = false, message = "Invalid question guid or templateVersionId" });
                }

                // Assumes your IQuestionService has a Guid-based delete. Add it if missing.
                var success = await _questionService.DeleteQuestionbyGuidAsync(questionGuid, templateVersionId);
                return Ok(new { success });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
        [HttpDelete("DeleteQuestion/{questionId}")]
        public async Task<IActionResult> DeleteQuestionById(int questionId)
        {
            try
            {
                if (questionId <= 0)
                {
                    return BadRequest(new { success = false, message = "Invalid question ID" });
                }

                var success = await _questionService.DeleteQuestionAsync(questionId);
                return Ok(new { success });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

    }
}
