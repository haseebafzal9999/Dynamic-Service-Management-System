using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using zentro.Areas.Identity.Data;
using zentro.DTOs;
using zentro.library;
using zentro.Models;

namespace zentro.Services.Metafield
{
    public class MetafieldService : IMetafieldService
    {
        private readonly dbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;


        public MetafieldService(dbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;

        }

        public async Task<object> AddMetaFieldAsync(MetafieldDto dto, string userName)
        {
            if (dto == null)
                return new { success = false, message = "DTO is null" };

            var templateVersion = await _context.TemplateVersions.FindAsync(dto.TemplateVersionId);
            if (templateVersion == null)
                return new { success = false, message = "TemplateVersion not found" };

            var createdById = await Common.UserInfo(_userManager, userName); // Pass _userManager instead of _context

            Guid? metafieldGuid = null;
            if (!string.IsNullOrWhiteSpace(dto.MetafieldGuid) &&
                Guid.TryParse(dto.MetafieldGuid, out var parsedGuid))
            {
                metafieldGuid = parsedGuid;
            }

            zentro.Models.Metafield metafield; // Fully qualify the Metafield class name

            // CASE 1: NEW METAFIELD (no GUID)
            if (metafieldGuid == null)
            {
                metafield = new zentro.Models.Metafield
                {
                    Name = dto.Name.Trim(),
                    FieldType = dto.FieldType.Trim(),
                    Tag = string.IsNullOrWhiteSpace(dto.Tag) ? null : dto.Tag.Trim(),
                    Visibility = dto.Visibility.Trim(),
                    TempVersionId = dto.TemplateVersionId,
                    MetafieldGuid = Guid.NewGuid(),
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    CreatedById = createdById.UserId.ToString()
                };

                _context.Metafields.Add(metafield);
                await _context.SaveChangesAsync();

                return new
                {
                    success = true,
                    message = "Metafield created successfully",
                    metafieldId = metafield.PID,
                    metafieldGuid = metafield.MetafieldGuid.ToString()
                };
            }

            // CASE 2: Check if exists in current version
            var existingInVersion = await _context.Metafields
                .FirstOrDefaultAsync(m =>
                    m.MetafieldGuid == metafieldGuid &&
                    m.TempVersionId == dto.TemplateVersionId &&
                    m.IsActive);

            if (existingInVersion != null)
            {
                // UPDATE existing
                existingInVersion.Name = dto.Name.Trim();
                existingInVersion.FieldType = dto.FieldType.Trim();
                existingInVersion.Tag = string.IsNullOrWhiteSpace(dto.Tag) ? null : dto.Tag.Trim();
                existingInVersion.Visibility = dto.Visibility.Trim();
                existingInVersion.ModifiedAt = DateTime.UtcNow;
                existingInVersion.ModifiedById = createdById.UserId.ToString();

                await _context.SaveChangesAsync();

                return new
                {
                    success = true,
                    message = "Metafield updated successfully",
                    metafieldId = existingInVersion.PID,
                    metafieldGuid = existingInVersion.MetafieldGuid.ToString()
                };
            }

            // CASE 3: CLONE from previous version
            var previousMetafield = await _context.Metafields
                .Where(m => m.MetafieldGuid == metafieldGuid && m.IsActive)
                .OrderByDescending(m => m.TempVersionId)
                .FirstOrDefaultAsync();

            if (previousMetafield == null)
                return new { success = false, message = "Previous metafield not found for cloning" };

            metafield = new zentro.Models.Metafield
            {
                Name = dto.Name.Trim(),
                FieldType = dto.FieldType.Trim(),
                Tag = string.IsNullOrWhiteSpace(dto.Tag) ? null : dto.Tag.Trim(),
                Visibility = dto.Visibility.Trim(),
                TempVersionId = dto.TemplateVersionId,
                MetafieldGuid = previousMetafield.MetafieldGuid,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                CreatedById = createdById.UserId.ToString()
            };

            _context.Metafields.Add(metafield);
            await _context.SaveChangesAsync();

            return new
            {
                success = true,
                message = "Metafield cloned successfully",
                metafieldId = metafield.PID,
                metafieldGuid = metafield.MetafieldGuid.ToString()
            };
        }
        public async Task<object> UpdateMetaFieldAsync(MetafieldDto dto, string userName)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.MetafieldGuid))
                return new { success = false, message = "Payload or MetafieldGuid is null" };

            if (!Guid.TryParse(dto.MetafieldGuid, out var metafieldGuid))
                return new { success = false, message = "Invalid MetafieldGuid format" };

            var userInfo = await Common.UserInfo(_userManager, userName); // Pass _userManager instead of _context

            // Find in current version
            var metafield = await _context.Metafields
                .FirstOrDefaultAsync(m =>
                    m.MetafieldGuid == metafieldGuid &&
                    m.TempVersionId == dto.TemplateVersionId &&
                    m.IsActive);

            if (metafield != null)
            {
                // UPDATE existing
                metafield.Name = dto.Name.Trim();
                metafield.FieldType = dto.FieldType.Trim();
                metafield.Tag = string.IsNullOrWhiteSpace(dto.Tag) ? null : dto.Tag.Trim();
                metafield.Visibility = dto.Visibility.Trim();
                metafield.ModifiedAt = DateTime.UtcNow;
                metafield.ModifiedById = userInfo.UserId.ToString();

                await _context.SaveChangesAsync();

                return new
                {
                    success = true,
                    message = "Metafield updated successfully",
                    metafieldId = metafield.PID,
                    metafieldGuid = metafield.MetafieldGuid.ToString()
                };
            }

            // CLONE from previous version
            var previousMetafield = await _context.Metafields
                .Where(m => m.MetafieldGuid == metafieldGuid && m.IsActive)
                .OrderByDescending(m => m.TempVersionId)
                .FirstOrDefaultAsync();

            if (previousMetafield == null)
                return new { success = false, message = "Metafield not found" };

            var newMetafield = new zentro.Models.Metafield
            {
                Name = dto.Name.Trim(),
                FieldType = dto.FieldType.Trim(),
                Tag = string.IsNullOrWhiteSpace(dto.Tag) ? null : dto.Tag.Trim(),
                Visibility = dto.Visibility.Trim(),
                TempVersionId = dto.TemplateVersionId,
                MetafieldGuid = previousMetafield.MetafieldGuid,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                CreatedById = userInfo.UserId.ToString()
            };

            _context.Metafields.Add(newMetafield);
            await _context.SaveChangesAsync();

            return new
            {
                success = true,
                message = "Metafield cloned and updated successfully",
                metafieldId = newMetafield.PID,
                metafieldGuid = newMetafield.MetafieldGuid.ToString()
            };
        }
        public async Task<object> GetMetafieldsForCreateQuoteAsync(int quoteId)
        {
            try
            {
                // Get quote record
                var record = await _context.UserRecords.FirstOrDefaultAsync(r => r.RecStatusId == quoteId);
                if (record == null)
                    return new { success = false, message = "Quote not found." };

                // Get metafields for this template version
                var metafields = await _context.Metafields
                    .Where(m => m.TempVersionId == record.TempVersionId)
                    .OrderBy(m => m.PID)
                    .Select(m => new
                    {
                        pid = m.PID,
                        name = m.Name,
                        fieldType = m.FieldType,
                        tag = m.Tag,
                        visibility = m.Visibility
                    })
                    .ToListAsync();

                return new
                {
                    success = true,
                    message = "Metafields loaded successfully",
                    data = metafields
                };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }

        public async Task<bool> SaveMetafieldAnswerAsync(MetafieldAnswerDto dto)
        {
            if (dto == null || dto.QuoteId == 0 || dto.TemplateVersionId == 0 || dto.MetafieldId == 0)
                throw new ArgumentException("Invalid data");

            var existing = await _context.MetafieldAnswers
                .FirstOrDefaultAsync(x =>
                    x.QuoteId == dto.QuoteId &&
                    x.TemplateVersionId == dto.TemplateVersionId &&
                    x.MetafieldId == dto.MetafieldId);

            if (existing != null)
            {
                existing.MetafieldInput = dto.MetafieldInput;
                _context.MetafieldAnswers.Update(existing);
            }
            else
            {
                var answer = new MetafieldAnswer
                {
                    QuoteId = dto.QuoteId,
                    TemplateVersionId = dto.TemplateVersionId,
                    MetafieldId = dto.MetafieldId,
                    MetafieldInput = dto.MetafieldInput
                };
                await _context.MetafieldAnswers.AddAsync(answer);
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<object> GetMetafieldsForQuoteDetailAsync(int quoteId)
        {
            var record = await _context.UserRecords
                .FirstOrDefaultAsync(r => r.RecStatusId == quoteId);

            if (record == null)
                return new { success = false, message = "Quote not found." };

            var metafields = await _context.Metafields
                .Where(m => m.TempVersionId == record.TempVersionId && m.IsActive)
                .OrderBy(m => m.PID)
                .Select(m => new
                {
                    pid = m.PID,
                    name = m.Name,
                    fieldType = m.FieldType,
                    tag = m.Tag,
                    visibility = m.Visibility
                })
                .ToListAsync();

            var savedAnswers = await _context.MetafieldAnswers
                .Where(ma => ma.QuoteId == quoteId && ma.TemplateVersionId == record.TempVersionId)
                .ToDictionaryAsync(ma => ma.MetafieldId, ma => ma.MetafieldInput);

            var metafieldsWithAnswers = metafields.Select(m => new
            {
                m.pid,
                m.name,
                m.fieldType,
                m.tag,
                m.visibility,
                savedValue = savedAnswers.ContainsKey(m.pid) ? savedAnswers[m.pid] : null
            }).ToList();

            return new
            {
                success = true,
                message = "Metafields loaded successfully",
                data = metafieldsWithAnswers
            };
        }

        public async Task<object> GetMetafieldsForPreviewAsync(int templateVersionId)
        {
            var templateVersion = await _context.TemplateVersions
                .FirstOrDefaultAsync(tv => tv.TempVersionId == templateVersionId);

            if (templateVersion == null)
                return new { success = false, message = "Template version not found." };

            var metafields = await _context.Metafields
                .Where(m => m.TempVersionId == templateVersionId)
                .OrderBy(m => m.PID)
                .Select(m => new
                {
                    pid = m.PID,
                    name = m.Name,
                    fieldType = m.FieldType,
                    tag = m.Tag,
                    visibility = m.Visibility
                })
                .ToListAsync();

            return new
            {
                success = true,
                message = "Metafields loaded successfully",
                data = metafields
            };
        }

        public async Task<bool> SaveMetafieldAnswersBulkAsync(MetafieldAnswerBulkDto dto)
        {
            if (dto == null || dto.QuoteId == 0 || dto.TemplateVersionId == 0 || dto.Answers == null)
                throw new ArgumentException("Invalid data");

            foreach (var answerDto in dto.Answers)
            {
                if (answerDto.MetafieldId == 0) continue;

                var existing = await _context.MetafieldAnswers
                    .FirstOrDefaultAsync(x =>
                        x.QuoteId == dto.QuoteId &&
                        x.TemplateVersionId == dto.TemplateVersionId &&
                        x.MetafieldId == answerDto.MetafieldId);

                if (existing != null)
                {
                    existing.MetafieldInput = answerDto.MetafieldInput;
                    _context.MetafieldAnswers.Update(existing);
                }
                else
                {
                    var answer = new MetafieldAnswer
                    {
                        QuoteId = dto.QuoteId,
                        TemplateVersionId = dto.TemplateVersionId,
                        MetafieldId = answerDto.MetafieldId,
                        MetafieldInput = answerDto.MetafieldInput
                    };
                    await _context.MetafieldAnswers.AddAsync(answer);
                }
            }

            await _context.SaveChangesAsync();
            return true;
        }

    }
}
