using Azure.Core;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Build.Framework;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System;
using System.Collections.Concurrent;
using System.Security.Claims;
using System.Text;
using Vscale_Fleet_Solutions.DTOs;
using zentro.Areas.Identity.Data;
using zentro.DTOs;
using zentro.IFrames;
using zentro.library;
using zentro.Models;
using zentro.Quote;
using zentro.Templates;
using zentro.View_Model;
using static zentro.Controllers.HomeController;

namespace zentro.Quote
{
    public class QuoteService : IQuoteService
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<QuoteService> _logger;
        private readonly UserManager<ApplicationUser> _userManager;
        private static ConcurrentDictionary<int, DateTime> LastLoadTimes = new ConcurrentDictionary<int, DateTime>();
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ITemplateService _templateService;
        private readonly IIFrameService _iframeService;


        public QuoteService(ILogger<QuoteService> logger, UserManager<ApplicationUser> userManager, dbContext context,
            IHttpClientFactory httpClientFactory, IConfiguration configuration, ITemplateService templateService, IHttpContextAccessor httpContextAccessor,
            IIFrameService iframeService)
        {
            _logger = logger;
            _userManager = userManager;
            _context = context;
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _httpContextAccessor = httpContextAccessor;
            _templateService = templateService;
            _iframeService = iframeService;

        }



        public async Task<UserAnswerVM> CreateRevisionAsync(int templateId, int customerId)
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            var businessId = Common.GetUserBusinessId(_context, userId); // Fetch BusinessId

            var customer = await GetCustomerName(customerId);

            UserAnswerVM userAnswerVM = GetTemplateVm(templateId);
            userAnswerVM.CustomerName = customer ?? "Unknown Customer";
            userAnswerVM.CustomerId = customerId;

            string quoteNum = GenerateQuoteReference();
            string pdfDirectory = @"C:\PDF Scheduler\Test Outputs";
            string pdfFileName = $"{quoteNum}.pdf";
            string fullPdfPath = Path.Combine(pdfDirectory, pdfFileName);

            var newUserRecord = new UserRecord
            {
                TemplateId = templateId,
                TempVersionId = userAnswerVM.TemplateVersion.Value,
                TotalCostPrice = 0,
                TotalSellPrice = 0,
                TotalCost = 0,
                QuoteReference = quoteNum,
                Pdflink = fullPdfPath,
                MiscCodeEnum = 0,
                MiscCodeName = "",
                CreatedAt = DateTime.UtcNow,
                IsActive = true,
                Status = "Requested",
                CreatedById = userId,
                CustomerId = customerId,
                BusinessId = businessId 

            };

            _context.UserRecords.Add(newUserRecord);
            await _context.SaveChangesAsync();

            userAnswerVM.RecStatusId = newUserRecord.RecStatusId;

            return userAnswerVM;
        }
       
        // CreateQuote Service Implementation ::-

        public async Task<int> CreateQuoteRecordAsync(CreateQuoteRequest request)
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            var businessId = Common.GetUserBusinessId(_context, userId); // Fetch BusinessId

            string quoteNum = GenerateQuoteReference();
            string pdfDirectory = @"C:\PDF Scheduler\Test Outputs";
            string pdfFileName = $"{quoteNum}.pdf";
            string fullPdfPath = Path.Combine(pdfDirectory, pdfFileName);

            var newUserRecord = new UserRecord
            {
                TemplateId = GetTemplateId(request.TemplateVersionId),
                TempVersionId = request.TemplateVersionId,
                TotalCostPrice = 0,
                TotalSellPrice = 0,
                TotalCost = 0,
                QuoteReference = quoteNum,
                Pdflink = fullPdfPath,
                MiscCodeEnum = 0,
                MiscCodeName = "",
                CreatedAt = DateTime.UtcNow,
                IsActive = true,
                Status = "Requested",
                CreatedById = userId,
                CustomerId = request.CustomerId,
                BusinessId = businessId 

            };

            _context.UserRecords.Add(newUserRecord);
            await _context.SaveChangesAsync();

            return newUserRecord.RecStatusId;
        }

        public async Task<object> GetTemplateDataForCreateQuoteAsync(int quoteId)
        {
            try
            {
                var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
                var businessId = Common.GetUserBusinessId(_context, userId); // Fetch BusinessId

                // Get quote record
                var record = await _context.UserRecords
                    .FirstOrDefaultAsync(r => r.RecStatusId == quoteId);
                var business = await _context.Businesses.FirstOrDefaultAsync(b => b.BusinessId == record.BusinessId);
                string currency = business?.Currency ?? "GBP";
                string currencyIdentity = business?.CurrencyIdentity ?? "en-GB";

                if (record == null)
                    throw new Exception("Quote not found.");

                // Get customer info
                var customer = (from r in _context.UserRecords
                                join c in _context.Customers on r.CustomerId equals c.CustomerId
                                where r.RecStatusId == quoteId
                                select c).FirstOrDefault();

                string customerName = customer != null ? customer.FirstName + " " + customer.LastName : "Not Exist";

                // Get template structure (NO ANSWERS)
                var templateVersion = _context.TemplateVersions
                    .FirstOrDefault(tv => tv.TempVersionId == record.TempVersionId);

                var templateName = _context.Templates
                    .Where(t => t.TemplateId == record.TemplateId)
                    .Select(t => t.TemplateName)
                    .FirstOrDefault();

                // Use your existing helper for structure
                var flatTemplate = _templateService.FlatTemplateDetails(record.TempVersionId);
                var templateData = MapFlatTemplateToCreateQuoteDto(flatTemplate);
                var normalizedGroups = GetNormalizedCreateQuoteList(templateData);

                var data = new
                {
                    templateId = record.TemplateId,
                    templateVersion = record.TempVersionId,
                    templateName = templateName,
                    questionGroups = normalizedGroups
                };

                return new
                {
                    success = true,
                    message = "Template loaded successfully",
                    data = data,
                    customerName = customerName,
                    quoteId = quoteId,
                    templateName = templateName,
                    currency = currency,
                    currencyIdentity = currencyIdentity
                };
            }
            catch (Exception ex)
            {
                return new
                {
                    success = false,
                    message = ex.Message
                };
            }
        }

        public async Task<object> GetDependentQuestionsForCreateQuoteAsync(int quoteId, int questionOptionId)
        {
            try
            {
                // Validate record exists
                var record = await _context.UserRecords.FirstOrDefaultAsync(r => r.RecStatusId == quoteId);
                if (record == null)
                    return new { success = false, message = "Quote not found." };

                // Get dependent questions structure (NO ANSWERS)
                var flatDependentTemplate = _templateService.FlatDependentQuestionDetails(record.TempVersionId, questionOptionId);
                var templateData = MapFlatTemplateToCreateQuoteDto(flatDependentTemplate);
                var normalizedGroups = GetNormalizedCreateQuoteList(templateData);

                return new
                {
                    success = true,
                    message = "Success",
                    data = new { questionGroups = normalizedGroups }
                };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }


        public async Task<(bool allAnswered, bool hasRequired)> IsAllRequiredAnsweredAsync(int quoteId, int quoteVersionId = 1)
        {
            var tempVersionId = await _context.UserRecords
                .Where(r => r.RecStatusId == quoteId)
                .Select(r => r.TempVersionId)
                .FirstOrDefaultAsync();

            if (tempVersionId == 0)
                return (true, false);

            var requiredQuestions = await _context.Questions
                .Where(q => q.TemplateVersionId == tempVersionId && q.IsRequired)
                .Select(q => q.QuestionId)
                .ToListAsync();

            if (requiredQuestions.Count == 0)
                return (true, false);

            var answeredQuestionIds = await _context.UserAnswers
                .Where(ua => ua.RecordId == quoteId && ua.QuoteVersionId == quoteVersionId && ua.IsActive)
                .Select(ua => ua.QuestionId)
                .Distinct()
                .ToListAsync();

            bool allAnswered = requiredQuestions.All(qid => answeredQuestionIds.Contains(qid));
            return (allAnswered, true);
        }

        public async Task<QuoteAnswerResponse> AddQuoteAnswerAsync(QuoteAnswerRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                if (request.QuoteVersionId == 0) request.QuoteVersionId = 1;

                if (request.fieldType == "table" && request.OptionId != 0)
                {
                    // ✅ FIX: Pass ParentOptionId
                    await RemoveExistingTableRowAsync(
                        request.QuoteId,
                        request.QuestionId,
                        request.OptionId,
                        request.QuoteVersionId,
                        request.ParentOptionId  // ✅ NEW
                    );
                }

                await DeactivateExistingAnswerAsync(request);

                int id = 0;
                if (request.QuestionId != 0)
                {
                    id = await CreateNewAnswerAsync(request);
                    await RecalculateQuoteTotalsAsync(request.QuoteId);
                }

                await transaction.CommitAsync();

                return new QuoteAnswerResponse
                {
                    primaryId = id,
                    Success = true,
                    Message = "Answer saved successfully",
                    QuoteVersionId = request.QuoteVersionId
                };
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return new QuoteAnswerResponse
                {
                    primaryId = 0,
                    Success = false,
                    Message = $"Error: {ex.Message}",
                    QuoteVersionId = request.QuoteVersionId
                };
            }
        }

        public async Task<QuoteAnswerResponse> RemoveQuoteAnswerAsync(QuoteAnswerRequest request)
        {
            try
            {
                if (request.QuoteVersionId == 0) request.QuoteVersionId = 1;

                await DeactivateExistingAnswerAsync(request);
                await _context.SaveChangesAsync();
                await RecalculateQuoteTotalsAsync(request.QuoteId);

                return new QuoteAnswerResponse
                {
                    primaryId = 0,
                    Success = true,
                    Message = "Answer deleted successfully",
                    QuoteVersionId = request.QuoteVersionId
                };
            }
            catch (Exception ex)
            {
                return new QuoteAnswerResponse
                {
                    primaryId = 0,
                    Success = false,
                    Message = $"Error: {ex.Message}",
                    QuoteVersionId = request.QuoteVersionId
                };
            }
        }

        public async Task<QuoteAnswerResponse> AddQuoteDetailAnswerAsync(QuoteAnswerRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                request.QuoteVersionId = 2;

                if (request.fieldType == "table" && request.OptionId != 0)
                {
                    // ✅ FIX: Pass ParentOptionId to properly identify dependent table rows
                    await RemoveExistingTableRowAsync(
                        request.QuoteId,
                        request.QuestionId,
                        request.OptionId,
                        request.QuoteVersionId,
                        request.ParentOptionId  // ✅ NEW: Include parent context
                    );
                }

                bool hasVersion2 = await _context.UserAnswers
                    .AnyAsync(ua => ua.RecordId == request.QuoteId && ua.QuoteVersionId == 2);

                if (!hasVersion2)
                {
                    await CopyAnswersToVersion2(request.QuoteId);
                }

                await DeactivateExistingAnswerForVersionAsync(request);

                int id = 0;
                if (request.QuestionId != 0)
                {
                    id = await CreateNewAnswerAsync(request);
                    await RecalculateQuoteTotalsAsync(request.QuoteId, request.QuoteVersionId);
                }

                await transaction.CommitAsync();

                return new QuoteAnswerResponse
                {
                    primaryId = id,
                    Success = true,
                    Message = "Answer saved successfully",
                    QuoteVersionId = 2
                };
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return new QuoteAnswerResponse
                {
                    primaryId = 0,
                    Success = false,
                    Message = $"Error: {ex.Message}",
                    QuoteVersionId = 2
                };
            }
        }

        public async Task<QuoteAnswerResponse> RemoveQuoteDetailAnswerAsync(QuoteAnswerRequest request)
        {
            try
            {
                request.QuoteVersionId = 2;

                bool hasVersion2 = await _context.UserAnswers
                    .AnyAsync(ua => ua.RecordId == request.QuoteId && ua.QuoteVersionId == 2);

                if (!hasVersion2)
                {
                    await CopyAnswersToVersion2(request.QuoteId);
                }

                await DeactivateExistingAnswerForVersionAsync(request);
                await _context.SaveChangesAsync();
                await RecalculateQuoteTotalsAsync(request.QuoteId, request.QuoteVersionId);

                return new QuoteAnswerResponse
                {
                    primaryId = 0,
                    Success = true,
                    Message = "Answer deleted successfully",
                    QuoteVersionId = 2
                };
            }
            catch (Exception ex)
            {
                return new QuoteAnswerResponse
                {
                    primaryId = 0,
                    Success = false,
                    Message = $"Error: {ex.Message}",
                    QuoteVersionId = 2
                };
            }
        }

        public async Task<object> GetQuoteDetailsAsync(int recStatusId)
        {
            var record = await _context.UserRecords
                .FirstOrDefaultAsync(r => r.RecStatusId == recStatusId);

            if (record == null)
                return new { success = false, message = "Record not found." };
            var business = await _context.Businesses.FirstOrDefaultAsync(b => b.BusinessId == record.BusinessId);
            string currency = business?.Currency ?? "GBP";
            string currencyIdentity = business?.CurrencyIdentity ?? "en-GB";

            string customerName = GetCustomerName(GetCustomerUsingQuoteId(recStatusId));

            var quoteDetails = GetQuoteDetailsWithAnswers(
                record.TemplateId,
                record.TempVersionId,
                recStatusId
            );
            var templateName = await _context.Templates
                .Where(t => t.TemplateId == record.TemplateId)
                .Select(t => t.TemplateName)
                .FirstOrDefaultAsync();

            return new
            {
                success = true,
                message = "Success",
                details = quoteDetails,
                customerName = customerName,
                quoteId = recStatusId,
                templateName = templateName,
                currency = currency,
                currencyIdentity = currencyIdentity
            };
        }

        public object GetDependentQuestionsForQuote(int recStatusId, int questionOptionId)
        {
            var record = _context.UserRecords.FirstOrDefault(r => r.RecStatusId == recStatusId);
            if (record == null)
                return new { success = false, message = "Quote not found." };

            var dependentQuestions = GetDependentQuestionsWithAnswers(
                record.TemplateId,
                record.TempVersionId,
                questionOptionId,
                recStatusId
            );

            return new
            {
                success = true,
                message = "Success",
                data = dependentQuestions
            };
        }


        // Default Template Service Implementation ::-


        public async Task<object> GetLatestTemplateForDefaultAsync(int templateId=0)
        {
            if (templateId == 0)
            {
                try
                {
                    var latestTemplateVersion = await _context.TemplateVersions
                        .OrderByDescending(tv => tv.TempVersionId)
                        .FirstOrDefaultAsync();

                    if (latestTemplateVersion == null)
                        return new { success = false, message = "No template found." };

                    var templateData = GetTemplateStructureOnly(latestTemplateVersion.TempVersionId);

                    return new
                    {
                        success = true,
                        message = "Template loaded successfully",
                        data = templateData
                    };
                }
                catch (Exception ex)
                {
                    return new { success = false, message = ex.Message };
                }
            }
            var templateVersion = await _iframeService.GetLatestVersionUsingTemplateID(templateId);

            if (templateVersion == null)
                return new { success = false, message = "No template found." };

            // ✅ Check if the template is active
            bool isTemplateActive = await IsTemplateActiveByVersionAsync(templateVersion);
            if (!isTemplateActive)
                return new { success = false, message = "This template is not active." };

            var defaulttemplateData = GetTemplateStructureOnly(templateVersion);

            return new
            {
                success = true,
                message = "Template loaded successfully",
                data = defaulttemplateData
            };

        }
        private async Task<bool> IsTemplateActiveByVersionAsync(int templateVersionId)
        {
            // Step 1: Get the TemplateId for this version
            var templateId = await _context.TemplateVersions
                .Where(tv => tv.TempVersionId == templateVersionId)
                .Select(tv => tv.TemplateId)
                .FirstOrDefaultAsync();

            // If no template found → not active
            if (templateId == 0)
                return false;

            // Step 2: Check if template itself is active
            var isActive = await _context.Templates
                .Where(t => t.TemplateId == templateId)
                .Select(t => t.IsActive)
                .FirstOrDefaultAsync();

            return isActive;
        }

        public object GetDependentQuestionsForDefault(int templateVersionId, int questionOptionId)
        {
            try
            {
                var dependentQuestions = GetDependentQuestionsStructureOnly(templateVersionId, questionOptionId);

                return new
                {
                    success = true,
                    message = "Dependent questions loaded successfully",
                    data = dependentQuestions
                };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }
        public async Task<object> IsAllRequiredAnsweredForDefaultAsync(int templateVersionId, int[] answeredQuestionIds)
        {
            try
            {
                answeredQuestionIds ??= Array.Empty<int>();

                var requiredQuestions = await _context.Questions
                    .Where(q => q.TemplateVersionId == templateVersionId && q.IsRequired)
                    .Select(q => q.QuestionId)
                    .ToListAsync();

                if (requiredQuestions.Count == 0)
                    return new { allAnswered = true, hasRequired = false };

                bool allAnswered = requiredQuestions.All(qid => answeredQuestionIds.Contains(qid));

                return new { allAnswered, hasRequired = true };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }
        public async Task<object> CreateAndSaveQuoteAsync(CreateAndSaveQuoteRequest request)
        {
            try
            {
                if (request == null || request.Answers == null || request.Answers.Count == 0)
                {
                    return new
                    {
                        success = false,
                        message = "Invalid request. Answers are required."
                    };
                }

                var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
                var businessId = Common.GetUserBusinessId(_context, userId); // Fetch BusinessId

                // Step 1: Create quote record
                var newUserRecord = new UserRecord
                {
                    TemplateId = GetTemplateId(request.TemplateVersion),
                    TempVersionId = request.TemplateVersion,
                    TotalCostPrice = 0,
                    TotalSellPrice = 0,
                    TotalCost = 0,
                    QuoteReference = GenerateQuoteReference(),
                    Pdflink = "",
                    MiscCodeEnum = 0,
                    MiscCodeName = "",
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true,
                    Status = "Requested",
                    CreatedById = userId,
                    CustomerId = request.CustomerId ?? GetCurrentCustomerId(),
                    BusinessId = businessId 

                };
                string quoteNum = newUserRecord.QuoteReference;
                string pdfDirectory = @"C:\PDF Scheduler\Test Outputs";
                string pdfFileName = $"{quoteNum}.pdf";
                string fullPdfPath = Path.Combine(pdfDirectory, pdfFileName);
                newUserRecord.Pdflink = fullPdfPath;
                _context.UserRecords.Add(newUserRecord);
                await _context.SaveChangesAsync();

                var recStatusId = newUserRecord.RecStatusId;

                // Step 2: Save all answers
                int savedAnswerCount = 0;
                foreach (var answer in request.Answers)
                {
                    try
                    {
                        if (answer.SelectedOptionId == null && string.IsNullOrWhiteSpace(answer.AnswerText))
                        {
                            _logger.LogWarning($"Skipping answer for QuestionId={answer.QuestionId} - no valid data");
                            continue;
                        }

                        var userAnswer = new UserAnswer
                        {
                            QuestionId = answer.QuestionId,
                            QoptionId = answer.SelectedOptionId,
                            AnswerText = answer.AnswerText ?? (answer.Quantity > 1 ? answer.Quantity.ToString() : null),
                            DateTime = DateTime.UtcNow,
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow,
                            CreatedById = userId,
                            CustomerId = GetCurrentCustomerId(),
                            RecordId = recStatusId,
                            QuoteVersionId = 1,
                            BusinessId = businessId ,
                            ParentOptionId = answer.ParentOptionId  // ✅ NEW: Save ParentOptionId


                        };

                        _context.UserAnswers.Add(userAnswer);
                        savedAnswerCount++;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError($"Error saving answer for QuestionId={answer.QuestionId}: {ex.Message}");
                    }
                }

                await _context.SaveChangesAsync();

                // Step 3: Calculate totals
                var (totalCost, totalSellPrice, totalCostPrice) = CalculateTotals(recStatusId);

                newUserRecord.TotalCostPrice = (decimal)(totalCostPrice ?? 0);
                newUserRecord.TotalSellPrice = (decimal)(totalSellPrice ?? 0);
                newUserRecord.TotalCost = (decimal)(totalCost ?? 0);
                await _context.SaveChangesAsync();

                return new
                {
                    success = true,
                    message = "Quote created and saved successfully",
                    recStatusId = recStatusId,
                    quoteReference = newUserRecord.QuoteReference,
                    answersCount = savedAnswerCount
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating and saving quote");
                return new
                {
                    success = false,
                    message = ex.Message,
                    innerException = ex.InnerException?.Message
                };
            }
        }



        // HELPER METHODS OF QuoteController :

        //  CREATE QUOTE
        private int? GetCurrentCustomerId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return null;

            var customer = _context.Customers.FirstOrDefault(c => c.UserId == userId);
            return customer?.CustomerId;
        }
        // Helper method for calculating totals
        private (decimal? totalCost, decimal? totalSellPrice, decimal? totalCostPrice) CalculateTotals(int recordId)
        {
            decimal? totalCost = 0;
            decimal? totalSellPrice = 0;
            decimal? totalCostPrice = 0;

            var userAnswers = _context.UserAnswers
                .Include(ua => ua.Question)
                .Include(ua => ua.Qoption)
                .Where(ua => ua.RecordId == recordId)
                .ToList();

            foreach (var ua in userAnswers)
            {
                var option = ua.Qoption;
                if (option == null) continue;

                int quantity = 1;
                if (!string.IsNullOrWhiteSpace(ua.AnswerText))
                    int.TryParse(ua.AnswerText, out quantity);

                if (option.MatCompName == "Material" && option.MaterialCompId.HasValue)
                {
                    var material = _context.Materials.FirstOrDefault(m => m.MaterialId == option.MaterialCompId.Value);
                    if (material != null)
                    {
                        totalCost += (material.SellPrice + material.CostPrice) * quantity;
                        totalSellPrice += material.SellPrice * quantity;
                        totalCostPrice += material.CostPrice * quantity;
                    }
                }
                else if (option.MatCompName == "Component" && option.MaterialCompId.HasValue)
                {
                    var component = _context.Components.FirstOrDefault(c => c.ComponentId == option.MaterialCompId.Value);
                    if (component != null)
                    {
                        totalCost += (component.SellPrice + component.BuildCost) * quantity;
                        totalSellPrice += component.SellPrice * quantity;
                        totalCostPrice += component.BuildCost * quantity;
                    }
                }
            }

            return (totalCost, totalSellPrice, totalCostPrice);
        }

        // HELPER METHODS FOR CREATE QUOTE

        private object GetTemplateStructureOnly(int templateVersionId)
        {
            // Get flat template structure
            var flatTemplate = _templateService.FlatTemplateDetails(templateVersionId);

            // Convert to CreateQuote DTOs (no answers)
            var templateData = MapFlatTemplateToCreateQuoteDto(flatTemplate);

            // Normalize into hierarchical structure
            var normalizedGroups = GetNormalizedCreateQuoteList(templateData);

            // Get template info
            var templateVersion = _context.TemplateVersions
                .FirstOrDefault(tv => tv.TempVersionId == templateVersionId);

            var templateName = _context.Templates
                .Where(t => t.TemplateId == templateVersion.TemplateId)
                .Select(t => t.TemplateName)
                .FirstOrDefault();

            return new
            {
                templateId = templateVersion.TemplateId,
                templateVersion = templateVersionId,
                templateName = templateName,
                questionGroups = normalizedGroups
                //recStatusId = 0 // No answers yet
            };
        }

        private object GetDependentQuestionsStructureOnly(int templateVersionId, int questionOptionId)
        {
            // Get flat dependent questions
            var flatDependentTemplate = _templateService.FlatDependentQuestionDetails(templateVersionId, questionOptionId);

            // Convert to CreateQuote DTOs
            var templateData = MapFlatTemplateToCreateQuoteDto(flatDependentTemplate);

            // Normalize
            var normalizedGroups = GetNormalizedCreateQuoteList(templateData);

            return new
            {
                questionGroups = normalizedGroups
            };
        }

        private List<CreateQuoteTemplateDetails> MapFlatTemplateToCreateQuoteDto(List<TemplateDetails> templateDetails)
        {
            return templateDetails.Select(t => new CreateQuoteTemplateDetails
            {
                QuestionGroupId = t.QuestionGroupId,
                QuestionGroupName = t.QuestionGroupName,
                QuestionGroupDisplayOrder = t.QuestionGroupDisplayOrder,

                QuestionId = t.QuestionId,
                QuestionText = t.QuestionText,
                IsRequired = t.IsRequired,
                QuestionDisplayOrder = t.QuestionDisplayOrder,
                QuestionFieldTypeId = t.QuestionFieldTypeId,

                FieldTypeName = t.FieldTypeName,
                FieldTypeDisplayName = t.FieldTypeDisplayName,

                QOptionId = t.QOptionId,
                OptionText = t.OptionText,
                OptionDisplayOrder = t.OptionDisplayOrder,
                OptionFieldTypeId = t.OptionFieldTypeId,

                MatCompName = t.MatCompName,
                MaterialCompId = t.MaterialCompId,
                Name = t.Name,
                SellPrice = t.SellPrice,
                CostPrice = t.CostPrice
            }).ToList();
        }

        private List<CreateQuoteQuestionGroupDto> GetNormalizedCreateQuoteList(List<CreateQuoteTemplateDetails> flatList)
        {
            var groups = flatList
                .GroupBy(g => new
                {
                    g.QuestionGroupId,
                    g.QuestionGroupName,
                    g.QuestionGroupDisplayOrder
                })
                .Select(group => new CreateQuoteQuestionGroupDto
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
                        .Select(q => new CreateQuoteQuestionDto
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
                                .Select(o => new CreateQuoteOptionDto
                                {
                                    QOptionId = o.QOptionId.Value,
                                    OptionText = o.OptionText,
                                    OptionDisplayOrder = o.OptionDisplayOrder,
                                    OptionFieldTypeId = o.OptionFieldTypeId,
                                    MatCompName = o.MatCompName,
                                    MaterialCompId = o.MaterialCompId,
                                    Name = o.Name,
                                    SellPrice = o.SellPrice,
                                    CostPrice = o.CostPrice
                                })
                                .GroupBy(o => o.QOptionId)
                                .Select(og => og.First())
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

        // HELPER METHODS FOR QUOTE DETAIL

        private object GetQuoteDetailsWithAnswers(int templateId, int templateVersionId, int recStatusId)
        {
            // Step 1: Get flat template details with answers
            var flatDetails = GetFlatQuoteDetails(templateId, templateVersionId, recStatusId);

            // Step 2: Normalize into hierarchical structure
            var normalizedGroups = GetNormalizedQuoteList(flatDetails);

            // Step 4: Get template name
            var templateName = _context.Templates
                .Where(t => t.TemplateId == templateId)
                .Select(t => t.TemplateName)
                .FirstOrDefault();

            // ✅ Determine current QuoteVersionId
            int quoteVersionId = _context.UserAnswers
                .Any(ua => ua.RecordId == recStatusId && ua.QuoteVersionId == 2) ? 2 : 1;


            return new
            {
                templateId = templateId,
                templateVersion = templateVersionId,
                templateName = templateName,
                questionGroups = normalizedGroups,
                recStatusId = recStatusId,
                quoteVersionId = quoteVersionId

            };
        }

        private List<QuoteTemplateDetails> GetFlatQuoteDetails(int templateId, int templateVersionId, int recStatusId)
        {
            var flatTemplate = _templateService.FlatTemplateDetails(templateVersionId);
            var templateData = MapFlatTemplateToQuoteTemplateDetails(flatTemplate);

            int quoteVersionId = _context.UserAnswers
                .Any(ua => ua.RecordId == recStatusId && ua.QuoteVersionId == 2) ? 2 : 1;

            // ✅ FIX: Only get ROOT answers (ParentOptionId == null)
            var userAnswers = _context.UserAnswers
                .Where(ua => ua.RecordId == recStatusId
                          && ua.QuoteVersionId == quoteVersionId
                          && ua.ParentOptionId == null)  // ✅ ADD THIS LINE
                .ToList();

            foreach (var item in templateData)
            {
                if (item.QuestionId.HasValue)
                {
                    var answer = userAnswers.FirstOrDefault(ua =>
                        ua.QuestionId == item.QuestionId.Value &&
                        ua.QoptionId == item.QOptionId
                    );

                    if (answer != null)
                    {
                        item.UserAnswerId = answer.UanswerId;
                        item.AnswerText = answer.AnswerText;
                        item.IsAnswered = true;

                        if (!string.IsNullOrEmpty(answer.AnswerText) &&
                            int.TryParse(answer.AnswerText, out int qty))
                        {
                            item.AnswerQuantity = qty;
                        }
                    }
                }
            }

            return templateData;
        }
        private object GetDependentQuestionsWithAnswers(int templateId, int templateVersionId, int questionOptionId, int recStatusId)
        {
            // Step 1: Get flat dependent questions
            var flatDependentQuestions = GetFlatDependentQuestions(templateId, templateVersionId, questionOptionId, recStatusId);

            // Step 2: Normalize into hierarchical structure
            var normalizedGroups = GetNormalizedDependentList(flatDependentQuestions);

            return new
            {
                questionGroups = normalizedGroups,
            };
        }

        private List<QuoteTemplateDetails> GetFlatDependentQuestions(int templateId, int templateVersionId, int questionOptionId, int recStatusId)
        {
            // Step 1: Get dependent questions structure
            var flatDependentTemplate = _templateService.FlatDependentQuestionDetails(templateVersionId, questionOptionId);
            var templateData = MapFlatTemplateToQuoteTemplateDetails(flatDependentTemplate);

            // ✅ Use version 2 if it exists, otherwise version 1
            int quoteVersionId = _context.UserAnswers
                .Any(ua => ua.RecordId == recStatusId && ua.QuoteVersionId == 2) ? 2 : 1;

            // ✅ FIX: Get ALL answers for this parent option (including multiple table rows)
            var userAnswers = _context.UserAnswers
                .Where(ua => ua.RecordId == recStatusId
                          && ua.QuoteVersionId == quoteVersionId
                          && ua.ParentOptionId == questionOptionId
                          && ua.IsActive)
                .ToList();

            // ✅ FIX: For table questions, we need to handle multiple answers per question
            // Group answers by QuestionId to handle tables properly
            var answersByQuestion = userAnswers
                .GroupBy(ua => ua.QuestionId)
                .ToDictionary(g => g.Key, g => g.ToList());

            // Step 3: Merge answers - but handle tables differently
            foreach (var item in templateData)
            {
                if (item.QuestionId.HasValue && answersByQuestion.TryGetValue(item.QuestionId.Value, out var questionAnswers))
                {
                    // Find answer matching this specific option
                    var answer = questionAnswers.FirstOrDefault(ua => ua.QoptionId == item.QOptionId);

                    if (answer != null)
                    {
                        item.UserAnswerId = answer.UanswerId;
                        item.AnswerText = answer.AnswerText;
                        item.IsAnswered = true;

                        if (!string.IsNullOrEmpty(answer.AnswerText) &&
                            int.TryParse(answer.AnswerText, out int qty))
                        {
                            item.AnswerQuantity = qty;
                        }
                    }
                }
            }

            // ✅ FIX: For table questions, add EXTRA rows for answers that don't match template options
            // This handles cases where the same option is selected multiple times
            var tableQuestionIds = templateData
                .Where(t => t.FieldTypeName?.ToLower() == "table" && t.QuestionId.HasValue)
                .Select(t => t.QuestionId.Value)
                .Distinct()
                .ToList();

            foreach (var questionId in tableQuestionIds)
            {
                if (answersByQuestion.TryGetValue(questionId, out var tableAnswers))
                {
                    // Get template items for this question (to copy structure)
                    var templateItem = templateData.FirstOrDefault(t => t.QuestionId == questionId);
                    if (templateItem == null) continue;

                    // Check each answer - if not already in templateData as IsAnswered, we might have duplicate options
                    var existingAnswerIds = templateData
                        .Where(t => t.QuestionId == questionId && t.IsAnswered)
                        .Select(t => t.UserAnswerId)
                        .ToHashSet();

                    foreach (var answer in tableAnswers)
                    {
                        if (!existingAnswerIds.Contains(answer.UanswerId))
                        {
                            // This is an additional row (same option selected twice, or option not in current view)
                            // Find the matching template item and mark it, or create a new entry
                            var matchingTemplate = templateData.FirstOrDefault(t =>
                                t.QuestionId == questionId &&
                                t.QOptionId == answer.QoptionId &&
                                !t.IsAnswered);

                            if (matchingTemplate != null)
                            {
                                matchingTemplate.UserAnswerId = answer.UanswerId;
                                matchingTemplate.AnswerText = answer.AnswerText;
                                matchingTemplate.IsAnswered = true;

                                if (!string.IsNullOrEmpty(answer.AnswerText) &&
                                    int.TryParse(answer.AnswerText, out int qty))
                                {
                                    matchingTemplate.AnswerQuantity = qty;
                                }
                            }
                        }
                    }
                }
            }

            return templateData;
        }

        private List<QuoteTemplateDetails> MapFlatTemplateToQuoteTemplateDetails(List<TemplateDetails> templateDetails)
        {
            return templateDetails.Select(t => new QuoteTemplateDetails
            {
                QuestionGroupId = t.QuestionGroupId,
                QuestionGroupName = t.QuestionGroupName,
                QuestionGroupDisplayOrder = t.QuestionGroupDisplayOrder,

                QuestionId = t.QuestionId,
                QuestionText = t.QuestionText,
                IsRequired = t.IsRequired,
                QuestionDisplayOrder = t.QuestionDisplayOrder,
                QuestionFieldTypeId = t.QuestionFieldTypeId,

                FieldTypeName = t.FieldTypeName,
                FieldTypeDisplayName = t.FieldTypeDisplayName,

                QOptionId = t.QOptionId,
                OptionText = t.OptionText,
                OptionDisplayOrder = t.OptionDisplayOrder,
                OptionFieldTypeId = t.OptionFieldTypeId,

                MatCompName = t.MatCompName,
                MaterialCompId = t.MaterialCompId,
                Name = t.Name,
                SellPrice = t.SellPrice,
                CostPrice = t.CostPrice
            }).ToList();
        }

        private List<QuoteQuestionGroupDto> GetNormalizedQuoteList(List<QuoteTemplateDetails> flatList)
        {
            var groups = flatList
                .GroupBy(g => new
                {
                    g.QuestionGroupId,
                    g.QuestionGroupName,
                    g.QuestionGroupDisplayOrder
                })
                .Select(group => new QuoteQuestionGroupDto
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
                        .Select(q => new QuoteQuestionDto
                        {
                            QuestionId = q.Key.QuestionId.Value,
                            QuestionText = q.Key.QuestionText,
                            IsRequired = q.Key.IsRequired,
                            QuestionDisplayOrder = q.Key.QuestionDisplayOrder,
                            QuestionFieldTypeId = q.Key.QuestionFieldTypeId,
                            FieldTypeName = q.Key.FieldTypeName,
                            FieldTypeDisplayName = q.Key.FieldTypeDisplayName,

                            AnswerText = ProcessAnswerText(q, q.Key.FieldTypeName),
                            SelectedOptionId = ProcessSelectedOptionId(q, q.Key.FieldTypeName),
                            PrimaryId = ProcessPrimaryId(q, q.Key.FieldTypeName),
                            LineItems = ProcessLineItems(q, q.Key.FieldTypeName),

                            Options = q
                                .Where(o => o.QOptionId != null)
                                .Select(o => new QuoteOptionDto
                                {
                                    QOptionId = o.QOptionId.Value,
                                    OptionText = o.OptionText,
                                    OptionDisplayOrder = o.OptionDisplayOrder,
                                    OptionFieldTypeId = o.OptionFieldTypeId,
                                    MatCompName = o.MatCompName,
                                    MaterialCompId = o.MaterialCompId,
                                    Name = o.Name,
                                    SellPrice = o.SellPrice,
                                    CostPrice = o.CostPrice,
                                    IsSelected = o.IsAnswered,
                                    Quantity = o.AnswerQuantity
                                })
                                .GroupBy(o => o.QOptionId)
                                .Select(og => og.First())
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

        private int? ProcessPrimaryId(IGrouping<dynamic, QuoteTemplateDetails> questionGroup, string fieldTypeName)
        {
            var answered = questionGroup.FirstOrDefault(x => x.IsAnswered);
            return answered?.UserAnswerId;
        }

        private List<QuoteQuestionGroupDto> GetNormalizedDependentList(List<QuoteTemplateDetails> flatList)
        {
            return GetNormalizedQuoteList(flatList);
        }

        private string ProcessAnswerText(IGrouping<dynamic, QuoteTemplateDetails> questionGroup, string fieldTypeName)
        {
            var fieldType = fieldTypeName?.ToLower();
            if (fieldType == "input")
            {
                return questionGroup.FirstOrDefault(x => x.IsAnswered)?.AnswerText;
            }
            return null;
        }

        private int? ProcessSelectedOptionId(IGrouping<dynamic, QuoteTemplateDetails> questionGroup, string fieldTypeName)
        {
            var fieldType = fieldTypeName?.ToLower();
            if (fieldType == "radio buttons" || fieldType == "select list" || fieldType == "checkboxes")
            {
                return questionGroup.FirstOrDefault(x => x.IsAnswered)?.QOptionId;
            }
            return null;
        }

        private List<TableLineItemDto> ProcessLineItems(IGrouping<dynamic, QuoteTemplateDetails> questionGroup, string fieldTypeName)
        {
            var fieldType = fieldTypeName?.ToLower();
            if (fieldType == "table")
            {
                return questionGroup
                    .Where(x => x.IsAnswered && x.QOptionId.HasValue)
                    .Select(x => new TableLineItemDto
                    {
                        OptionId = x.QOptionId,
                        Quantity = x.AnswerQuantity ?? 0,
                        PrimaryId = x.UserAnswerId
                    })
                    .ToList();
            }
            return new List<TableLineItemDto>();
        }

        private Customer GetCustomerUsingQuoteId(int quoteId)
        {
            return (from r in _context.UserRecords
                    join c in _context.Customers on r.CustomerId equals c.CustomerId
                    where r.RecStatusId == quoteId
                    select c)
                   .FirstOrDefault();

        }

        private string GetCustomerName(Customer customer)
        {
            string customerName = "Not Exist";
            if (customer != null) { customerName = customer.FirstName + " " + customer.LastName; }
            return customerName;
        }

        private int GetTemplateId(int? tempVerId)
        {
            if (!tempVerId.HasValue || tempVerId <= 0)
            {
                throw new Exception("Invalid TemplateVersion");
            }

            var templateVersion = _context.TemplateVersions
                .FirstOrDefault(v => v.TempVersionId == tempVerId.Value);

            if (templateVersion == null)
            {
                throw new Exception($"Template version {tempVerId} not found");
            }

            return templateVersion.TemplateId;
        }
        private string GenerateQuoteReference()
        {
            var now = DateTime.UtcNow;
            int year = now.Year;
            int week = System.Globalization.ISOWeek.GetWeekOfYear(now);
            string day = now.Day.ToString("D2");

            // Ensure weekStart is UTC
            var weekStart = DateTime.SpecifyKind(System.Globalization.ISOWeek.ToDateTime(year, week, System.DayOfWeek.Monday), DateTimeKind.Utc);
            var weekEnd = weekStart.AddDays(7);

            int count = _context.UserRecords
                .Where(r => r.CreatedAt >= weekStart && r.CreatedAt < weekEnd)
                .Count();

            string sequence = (count + 1).ToString("D4"); // 0001, 0002, etc.

            return $"Q{year}{week:D2}{day}{sequence}";
        }



        // Helper Method of QuoteAnswerController:

        private async Task RecalculateQuoteTotalsAsync(int recordId, int? quoteVersionId = 1)
        {
            decimal totalCost = 0;
            decimal totalSellPrice = 0;
            decimal totalCostPrice = 0;

            var userAnswersQuery = _context.UserAnswers
                .Include(ua => ua.Qoption)
                .Where(ua => ua.RecordId == recordId);

            if (quoteVersionId.HasValue)
                userAnswersQuery = userAnswersQuery.Where(ua => ua.QuoteVersionId == quoteVersionId.Value);

            var userAnswers = await userAnswersQuery.ToListAsync();

            foreach (var ua in userAnswers)
            {
                var option = ua.Qoption;
                if (option == null) continue;

                int quantity = 1;
                if (!string.IsNullOrWhiteSpace(ua.AnswerText))
                    int.TryParse(ua.AnswerText, out quantity);

                if (option.MatCompName == "Material" && option.MaterialCompId.HasValue)
                {
                    var material = await _context.Materials
                        .FirstOrDefaultAsync(m => m.MaterialId == option.MaterialCompId.Value);
                    if (material != null)
                    {
                        var sell = material.SellPrice ?? 0;
                        var cost = material.CostPrice ?? 0;
                        totalCost += (sell + cost) * quantity;
                        totalSellPrice += sell * quantity;
                        totalCostPrice += cost * quantity;
                    }
                }
                else if (option.MatCompName == "Component" && option.MaterialCompId.HasValue)
                {
                    var component = await _context.Components
                        .FirstOrDefaultAsync(c => c.ComponentId == option.MaterialCompId.Value);
                    if (component != null)
                    {
                        totalCost += (component.SellPrice + component.BuildCost) * quantity;
                        totalSellPrice += component.SellPrice * quantity;
                        totalCostPrice += component.BuildCost * quantity;
                    }
                }
            }

            var userRecord = await _context.UserRecords.FirstOrDefaultAsync(r => r.RecStatusId == recordId);
            if (userRecord != null)
            {
                userRecord.TotalCost = totalCost;
                userRecord.TotalCostPrice = totalCostPrice;
                userRecord.TotalSellPrice = totalSellPrice;
                userRecord.ModifiedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }
        }

        // REPLACE CopyAnswersToVersion2 method in QuoteService.cs:

        private async Task CopyAnswersToVersion2(int quoteId)
        {
            var userId = GetCurrentUserId();
            var businessId = Common.GetUserBusinessId(_context, userId);

            // ✅ FIX: Get all version 1 answers INCLUDING ParentOptionId
            var version1Answers = await _context.UserAnswers
                .Where(ua => ua.RecordId == quoteId && ua.QuoteVersionId == 1)
                .ToListAsync();

            // ✅ FIX: Copy WITH ParentOptionId preserved
            var version2Answers = version1Answers.Select(ua => new UserAnswer
            {
                QuestionId = ua.QuestionId,
                QoptionId = ua.QoptionId,
                AnswerText = ua.AnswerText,
                DisplayOrder = ua.DisplayOrder,
                DateTime = DateTime.UtcNow,
                RecordId = ua.RecordId,
                IsActive = ua.IsActive,
                ModifiedAt = DateTime.UtcNow,
                ModifiedById = userId,
                CustomerId = ua.CustomerId,
                QuoteVersionId = 2,
                BusinessId = businessId,
                ParentOptionId = ua.ParentOptionId  // ✅ NEW: Preserve parent relationship
            }).ToList();

            await _context.UserAnswers.AddRangeAsync(version2Answers);
            await _context.SaveChangesAsync();
        }

        private int GetCustomerId(Customer customer)
        {
            int customerId = 0;
            if (customer != null) { customerId = customer.CustomerId; }
            return customerId;
        }

        private async Task DeactivateExistingAnswerAsync(QuoteAnswerRequest request)
        {
            if (request.PrimaryId != 0 && request.fieldType != "checkbox" && request.fieldType != "radio" && request.fieldType != "select")
            {
                await DeactivateRecordUsingId(request.PrimaryId);
            }
            else if (request.fieldType == "checkbox" || request.fieldType == "radio" || request.fieldType == "select")
            {
                // ✅ MODIFIED: Include select type and use parent-aware deactivation
                await DeactivateRecordUsingQuoteQuestionAndParent(
                    request.QuoteId,
                    request.QuestionId,
                    request.QuoteVersionId,
                    request.ParentOptionId
                );
            }
        }
        // ✅ FIXED METHOD: Deactivate considering ParentOptionId
        private async Task DeactivateRecordUsingQuoteQuestionAndParent(
     int quoteId,
     int questionId,
     int quoteVersionId,
     int? ParentOptionId)
        {
            var query = _context.UserAnswers
                .Where(x => x.RecordId == quoteId
                         && x.QuestionId == questionId
                         && x.QuoteVersionId == quoteVersionId
                         && x.IsActive);

            if (ParentOptionId.HasValue && ParentOptionId.Value > 0)
            {
                query = query.Where(x => x.ParentOptionId == ParentOptionId);
            }
            else
            {
                query = query.Where(x => x.ParentOptionId == null);
            }

            var existingAnswer = await query.FirstOrDefaultAsync();

            if (existingAnswer == null) return;

            if (quoteVersionId == 2)
            {
                existingAnswer.ModifiedAt = DateTime.UtcNow;
                existingAnswer.ModifiedById = GetCurrentUserId();
            }

            // ✅ IMPORTANT: First remove dependent answers (using the fixed method)
            if (existingAnswer.QoptionId.HasValue)
            {
                await RemoveDependentAnswersRecursive(quoteId, quoteVersionId, existingAnswer.QoptionId.Value);
            }

            _context.UserAnswers.Remove(existingAnswer);
            await _context.SaveChangesAsync();
        }


        // REPLACE DeactivateExistingAnswerForVersionAsync in QuoteService.cs:

        private async Task DeactivateExistingAnswerForVersionAsync(QuoteAnswerRequest request)
        {
            if (request.PrimaryId != 0 && request.fieldType != "checkbox" && request.fieldType != "radio" && request.fieldType != "select")
            {
                var answer = await _context.UserAnswers
                    .FirstOrDefaultAsync(x => x.UanswerId == request.PrimaryId && x.QuoteVersionId == request.QuoteVersionId);

                if (answer != null && answer.QoptionId.HasValue)
                {
                    await RemoveDependentAnswersRecursiveBothVersions(request.QuoteId, answer.QoptionId.Value);
                }

                await DeactivateRecordUsingIdForVersion(request.PrimaryId, request.QuoteVersionId);
            }
            else if (request.fieldType == "checkbox" || request.fieldType == "radio" || request.fieldType == "select")
            {
                // ✅ FIX: Build query with proper ParentOptionId filtering
                var answerQuery = _context.UserAnswers
                    .Where(x => x.RecordId == request.QuoteId
                             && x.QuestionId == request.QuestionId
                             && x.QuoteVersionId == request.QuoteVersionId
                             && x.IsActive);

                // ✅ FIX: Properly handle null vs non-null ParentOptionId
                if (request.ParentOptionId.HasValue && request.ParentOptionId.Value > 0)
                {
                    answerQuery = answerQuery.Where(x => x.ParentOptionId == request.ParentOptionId);
                }
                else
                {
                    answerQuery = answerQuery.Where(x => x.ParentOptionId == null);
                }

                var answer = await answerQuery.FirstOrDefaultAsync();

                if (answer != null && answer.QoptionId.HasValue)
                {
                    await RemoveDependentAnswersRecursiveBothVersions(request.QuoteId, answer.QoptionId.Value);
                }

                await DeactivateRecordUsingQuoteQuestionAndParent(
                    request.QuoteId,
                    request.QuestionId,
                    request.QuoteVersionId,
                    request.ParentOptionId
                );
            }
            else if (request.fieldType == "table" && request.OptionId != 0)
            {
                // ✅ FIX: Also consider ParentOptionId for tables
                var existingRowsQuery = _context.UserAnswers
                    .Where(x => x.RecordId == request.QuoteId
                        && x.QuestionId == request.QuestionId
                        && x.QoptionId == request.OptionId
                        && x.QuoteVersionId == request.QuoteVersionId);

                if (request.ParentOptionId.HasValue && request.ParentOptionId.Value > 0)
                {
                    existingRowsQuery = existingRowsQuery.Where(x => x.ParentOptionId == request.ParentOptionId);
                }
                else
                {
                    existingRowsQuery = existingRowsQuery.Where(x => x.ParentOptionId == null);
                }

                var existingRows = await existingRowsQuery.ToListAsync();

                if (existingRows.Any())
                {
                    foreach (var row in existingRows)
                    {
                        if (row.QoptionId.HasValue)
                        {
                            await RemoveDependentAnswersRecursiveBothVersions(request.QuoteId, row.QoptionId.Value);
                        }
                    }

                    _context.UserAnswers.RemoveRange(existingRows);
                    await _context.SaveChangesAsync();
                }
            }
        }
        private string? GetCurrentUserId()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            return user?.Identity?.IsAuthenticated == true
                ? user.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                : null;
        }

        private async Task RemoveDependentQuestionsIfAny(UserAnswer userAnswer)
        {
            // ✅ FIX: Only remove dependent questions that belong to THIS parent option
            // The ParentOptionId of dependent answers should match the QoptionId of the parent answer

            var dependentQuestionIds = await _context.DependentQuestions
                .Where(dq => dq.QoptionId == userAnswer.QoptionId)
                .Select(dq => dq.NextQuestionId)
                .ToListAsync();

            if (!dependentQuestionIds.Any()) return;

            // ✅ KEY FIX: Filter by ParentOptionId = userAnswer.QoptionId
            // This ensures we only delete dependent answers that were created under THIS option
            await _context.UserAnswers
                .Where(ua => ua.RecordId == userAnswer.RecordId &&
                             ua.QuoteVersionId == userAnswer.QuoteVersionId &&
                             dependentQuestionIds.Contains(ua.QuestionId) &&
                             ua.ParentOptionId == userAnswer.QoptionId)  // ✅ NEW: Filter by parent
                .ExecuteDeleteAsync();
        }

        private async Task DeactivateRecordUsingId(int id)
        {
            var existingAnswer = await _context.UserAnswers.FirstOrDefaultAsync(x => x.UanswerId == id);
            if (existingAnswer == null) return;

            _context.UserAnswers.Remove(existingAnswer);
            await RemoveDependentQuestionsIfAny(existingAnswer);
            await _context.SaveChangesAsync();
        }

        private async Task DeactivateRecordUsingIdForVersion(int id, int quoteVersionId)
        {
            var existingAnswer = await _context.UserAnswers
                .FirstOrDefaultAsync(x => x.UanswerId == id && x.QuoteVersionId == quoteVersionId);
            if (existingAnswer == null) return;

            if (quoteVersionId == 2)
            {
                existingAnswer.ModifiedAt = DateTime.UtcNow;
                existingAnswer.ModifiedById = GetCurrentUserId();
            }

            // ✅ FIX: Remove dependent answers using the corrected method
            if (existingAnswer.QoptionId.HasValue)
            {
                await RemoveDependentAnswersRecursive(
                    existingAnswer.RecordId ?? 0,
                    quoteVersionId,
                    existingAnswer.QoptionId.Value
                );
            }

            _context.UserAnswers.Remove(existingAnswer);
            await _context.SaveChangesAsync();
        }

        private async Task DeactivateRecordUsingQuoteAndQuestionId(int quoteId, int questionId, int quoteVersionId)
        {
            var existingAnswer = await _context.UserAnswers
                .FirstOrDefaultAsync(x => x.RecordId == quoteId
                                       && x.QuestionId == questionId
                                       && x.QuoteVersionId == quoteVersionId
                                       && x.IsActive);
            if (existingAnswer == null) return;

            // Set modified fields for version 2
            if (quoteVersionId == 2)
            {
                existingAnswer.ModifiedAt = DateTime.UtcNow;
                existingAnswer.ModifiedById = GetCurrentUserId();
            }

            _context.UserAnswers.Remove(existingAnswer);
            await RemoveDependentQuestionsIfAny(existingAnswer);
            await _context.SaveChangesAsync();
        }

        // MODIFY CreateNewAnswerAsync in QuoteService.cs:

        private async Task<int> CreateNewAnswerAsync(QuoteAnswerRequest request)
        {
            var customer = GetCustomerUsingQuoteId(request.QuoteId);
            var customerId = GetCustomerId(customer);
            var userId = GetCurrentUserId();
            var businessId = Common.GetUserBusinessId(_context, userId);

            if (request.fieldType == "checkbox" || request.fieldType == "select" || request.fieldType == "radio")
            {
                request.Value = "";
            }

            var newAnswer = new UserAnswer
            {
                CustomerId = customerId,
                AnswerText = request.Value,
                CreatedAt = DateTime.UtcNow,
                CreatedById = userId,
                DateTime = DateTime.UtcNow,
                IsActive = true,
                QuestionId = request.QuestionId,
                RecordId = request.QuoteId,
                QoptionId = request.OptionId == 0 ? null : request.OptionId,
                QuoteVersionId = request.QuoteVersionId,
                BusinessId = businessId,
                ParentOptionId = request.ParentOptionId  // ✅ NEW: Store parent option context
            };

            if (request.QuoteVersionId == 2)
            {
                newAnswer.ModifiedAt = DateTime.UtcNow;
                newAnswer.ModifiedById = userId;
            }

            await _context.UserAnswers.AddAsync(newAnswer);
            await _context.SaveChangesAsync();

            return newAnswer.UanswerId;
        }

        private async Task RemoveDependentAnswersRecursiveBothVersions(int quoteId, int ParentOptionId)
        {
            await RemoveDependentAnswersRecursive(quoteId, 2, ParentOptionId);
            await RemoveDependentAnswersRecursive(quoteId, 1, ParentOptionId);
        }


        private async Task RemoveExistingTableRowAsync(int quoteId, int questionId, int optionId, int quoteVersionId, int? parentOptionId = null)
        {
            var query = _context.UserAnswers
                .Where(x => x.RecordId == quoteId
                    && x.QuestionId == questionId
                    && x.QoptionId == optionId
                    && x.QuoteVersionId == quoteVersionId);

            // ✅ FIX: Consider ParentOptionId for dependent table rows
            if (parentOptionId.HasValue && parentOptionId.Value > 0)
            {
                query = query.Where(x => x.ParentOptionId == parentOptionId);
            }
            else
            {
                query = query.Where(x => x.ParentOptionId == null);
            }

            var existingRows = await query.ToListAsync();

            if (existingRows.Any())
            {
                // ✅ Log for debugging
                Console.WriteLine($"🗑️ Removing {existingRows.Count} table row(s) for Q{questionId}, Option{optionId}, Parent{parentOptionId}");

                _context.UserAnswers.RemoveRange(existingRows);
                await _context.SaveChangesAsync();

                Console.WriteLine($"✅ Removed table rows successfully");
            }
        }

        // REPLACE RemoveDependentAnswersRecursive in QuoteService.cs:

        private async Task RemoveDependentAnswersRecursive(int quoteId, int quoteVersionId, int parentOptionId)
        {
            var dependentQuestionIds = await _context.DependentQuestions
                .Where(dq => dq.QoptionId == parentOptionId)
                .Select(dq => dq.NextQuestionId)
                .ToListAsync();

            if (!dependentQuestionIds.Any()) return;

            // ✅ FIX: Only get answers that have THIS ParentOptionId
            var answers = await _context.UserAnswers
                .Where(ua => ua.RecordId == quoteId &&
                             ua.QuoteVersionId == quoteVersionId &&
                             dependentQuestionIds.Contains(ua.QuestionId) &&
                             ua.ParentOptionId == parentOptionId)  // ✅ Filter by parent
                .ToListAsync();

            foreach (var answer in answers)
            {
                // Recursively remove any dependent answers of THIS answer
                if (answer.QoptionId.HasValue)
                {
                    await RemoveDependentAnswersRecursive(quoteId, quoteVersionId, answer.QoptionId.Value);
                }
                _context.UserAnswers.Remove(answer);
            }

            await _context.SaveChangesAsync();
        }
        // Helper Method For CreateQuote:



        //private int GetTemplateId(int? tempVerId)
        //{
        //    if (!tempVerId.HasValue || tempVerId <= 0)
        //    {
        //        throw new Exception("Invalid TemplateVersion");
        //    }

        //    var templateVersion = _context.TemplateVersions
        //        .FirstOrDefault(v => v.TempVersionId == tempVerId.Value);

        //    if (templateVersion == null)
        //    {
        //        throw new Exception($"Template version {tempVerId} not found");
        //    }

        //    return templateVersion.TemplateId;
        //}

        //private string GenerateQuoteReference()
        //{
        //    var now = DateTime.UtcNow;
        //    int year = now.Year;
        //    int week = System.Globalization.ISOWeek.GetWeekOfYear(now);
        //    string day = now.Day.ToString("D2");

        //    // Ensure weekStart is UTC
        //    var weekStart = DateTime.SpecifyKind(System.Globalization.ISOWeek.ToDateTime(year, week, System.DayOfWeek.Monday), DateTimeKind.Utc);
        //    var weekEnd = weekStart.AddDays(7);

        //    int count = _context.UserRecords
        //        .Where(r => r.CreatedAt >= weekStart && r.CreatedAt < weekEnd)
        //        .Count();

        //    string sequence = (count + 1).ToString("D4"); // 0001, 0002, etc.

        //    return $"Q{year}{week:D2}{day}{sequence}";
        //}

        private async Task<string> GetCustomerName(int customerId)
        {
            return await _context.Customers
             .Where(c => c.CustomerId == customerId)
             .Select(c => c.FirstName + " " + c.LastName)
             .FirstOrDefaultAsync();
        }
        private UserAnswerVM GetTemplateVm(int? tempVerId)
        {
            //var templateVersion = _context.TemplateVersions
            //    .Where(v => (tempVerId.HasValue && tempVerId > 0 && v.TempVersionId == tempVerId)
            //                || (!tempVerId.HasValue)
            //                || tempVerId == 0)
            //    .OrderByDescending(r => r.TempVersionId)
            //    .FirstOrDefault();

            //if (templateVersion == null)
            //{
            //    return new UserAnswerVM();
            //}
            TemplateVersion templateVersion = null;
            if (tempVerId.HasValue && tempVerId > 0)
            {
                templateVersion = _context.TemplateVersions
                    .Where(v => v.TempVersionId == tempVerId)
                    .FirstOrDefault();

                // ✅ Case 2: If no TemplateVersion found, maybe tempVerId was actually a TemplateId
                if (templateVersion == null)
                {
                    templateVersion = _context.TemplateVersions
                        .Where(v => v.TemplateId == tempVerId)
                        .OrderByDescending(v => v.TempVersionId)
                        .FirstOrDefault();
                }
            }
            if (templateVersion == null)
            {
                return new UserAnswerVM();
            }

            int? templateId = templateVersion.TemplateId;
            int? templateVersionId = templateVersion.TempVersionId;

            if (!templateId.HasValue || !templateVersionId.HasValue)
                return new UserAnswerVM();

            var templateName = _context.Templates
                .Where(t => t.TemplateId == templateId)
                .Select(t => t.TemplateName)
                .FirstOrDefault();

            var groups = _context.QuestionGroups
                .Where(qg => qg.TemplateId == templateId &&
                             qg.TemplateVersionId == templateVersionId &&
                             qg.IsActive == true)
                .OrderBy(qg => qg.DisplayOrder)
                .ToList();

            var questions = _context.Questions
                .Where(q => q.TemplateId == templateId
                            && q.TemplateVersionId == templateVersionId
                            && q.IsActive == true
                            && !_context.DependentQuestions.Any(dq => dq.NextQuestionId == q.QuestionId))
                .Include(q => q.QuestionGroup)
                .Include(q => q.FieldType)
                .OrderBy(q => q.DisplayOrder)
                .ToList();

            // Expand all dependent questions iteratively
            foreach (var q in questions)
            {
                LoadQuestionGraphIterative(q);
            }

            var optionPrices = new List<OptionPriceVM>();
            foreach (var qts in questions)
            {
                foreach (var opt in qts.QuestionOptions)
                {
                    var (cost, sell) = GetOptionCostAndSellPrice(opt.QoptionId);
                    optionPrices.Add(new OptionPriceVM
                    {
                        OptionId = opt.QoptionId,
                        CostPrice = cost ?? 0m,   // Default to zero if null
                        SellPrice = sell ?? 0m
                    });
                }
            }


            var userAnswerVM = new UserAnswerVM
            {
                dbQuestionGroups = groups,
                dbQuestions = questions,
                TemplateId = templateId,
                TemplateVersion = templateVersionId,
                TemplateName = templateName, // ✅ Added line
                Items = null,//templateItems,  // <-- Send services to the view
                OptionPrices = optionPrices
            };

            return userAnswerVM;
        }

        private void LoadQuestionGraphIterative(Question root)
        {
            var queue = new Queue<Question>();
            queue.Enqueue(root);

            while (queue.Count > 0)
            {
                var current = queue.Dequeue();

                // Load options for current question
                _context.Entry(current)
                    .Collection(q => q.QuestionOptions)
                    .Query()
                    .Where(o => o.IsActive == true)
                    .OrderBy(o => o.DisplayOrder)
                    .Include(o => o.DependentQuestions)
                        .ThenInclude(dq => dq.NextQuestion)
                    .Load();

                // Load field type
                _context.Entry(current).Reference(q => q.FieldType).Load();

                // Add children to queue
                foreach (var opt in current.QuestionOptions)
                {
                    foreach (var dq in opt.DependentQuestions)
                    {
                        if (dq.NextQuestion != null)
                        {
                            queue.Enqueue(dq.NextQuestion);
                        }
                    }
                }
            }
        }

        private (decimal? CostPrice, decimal? SellPrice) GetOptionCostAndSellPrice(int optionId)
        {
            var option = _context.QuestionOptions.FirstOrDefault(o => o.QoptionId == optionId);
            if (option == null) return (null, null);

            if (option.MatCompName == "Material" && option.MaterialCompId.HasValue)
            {
                var material = _context.Materials.FirstOrDefault(m => m.MaterialId == option.MaterialCompId.Value);
                if (material != null)
                    return (material.CostPrice, material.SellPrice);
            }
            else if (option.MatCompName == "Component" && option.MaterialCompId.HasValue)
            {
                var component = _context.Components.FirstOrDefault(c => c.ComponentId == option.MaterialCompId.Value);
                if (component != null)
                    return (component.BuildCost, component.SellPrice);
            }
            return (null, null);
        }



    }
}
