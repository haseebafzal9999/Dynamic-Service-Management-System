using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System;
using System.Net.Http;
using System.Security.Claims;
using System.Text;
using zentro.library;
using zentro.Models;
using zentro.View_Model;
using static zentro.Controllers.HomeController;

namespace zentro.TemplateItems
{
    public class TemplateItemsService : ITemplateItemsService
    {
        private readonly dbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public TemplateItemsService(dbContext context, IConfiguration configuration , IHttpClientFactory httpClientFactory, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _configuration = configuration;
            _httpClientFactory = httpClientFactory;
            _httpContextAccessor = httpContextAccessor;

        }
        private record SyncResult(int Added, int Updated, int Skipped);
        private record PdfResult(bool Success, string Message);
        public record MaterialTableRow(string part_no, string a, string b, string c, string d, string total);
        public record ServiceTableRow(string a, string b, string c, string d, string e, string f, string g);
        public record NumberedRow(string Line, string Description, string Notes, decimal? Qty, string Unit, decimal? ItemPrice);
        public record TemplateItemRow(string Description, string Notes, decimal? Qty, string Unit, decimal? ItemPrice, string RowId);

        public List<string> GetTemplateItemSuggestions(string type, string query, int recStatusId, int customerId)
        {
            if (string.IsNullOrWhiteSpace(query))
                return new List<string>();

            query = query.ToLower();

            // 1️⃣ Fetch TemplateVersionId from UserRecords
            var record = _context.UserRecords
                .Where(r => r.RecStatusId == recStatusId)
                .Select(r => new { r.TempVersionId })
                .FirstOrDefault();

            if (record == null)
                return new List<string>();

          
            int templateVersion = record.TempVersionId;

            // 2️⃣ Filter TemplateItems using  TemplateVersionId
            var itemsQuery = _context.TemplateItems
                .Where(t => t.TemplateVersion == templateVersion);

            // 3️⃣ Apply search based on type
            if (type.Equals("ServiceName", StringComparison.OrdinalIgnoreCase))
            {
                return itemsQuery
                    .Where(t => t.ServiceName != null &&
                                t.ServiceName.ToLower().Contains(query))
                    .Select(t => t.ServiceName)
                    .Distinct()
                    .Take(10)
                    .ToList();
            }
            else if (type.Equals("Description", StringComparison.OrdinalIgnoreCase))
            {
                return itemsQuery
                    .Where(t => t.Description != null &&
                                t.Description.ToLower().Contains(query))
                    .Select(t => t.Description)
                    .Distinct()
                    .Take(10)
                    .ToList();
            }

            return new List<string>();
        }
        public async Task<(bool Success, string Message)> CreateQuotePostAsync(UserAnswerVM model, string currency = "en-GB")
        {
            // 1️⃣ Validate input
            if (model.TemplateId == null || model.TemplateVersion == null)
            {
                return (false, "TemplateId or TemplateVersion missing.");
            }

            // 2️⃣ Prepare base data
            var userQuote = await GetQuoteDetails(model.RecStatusId.Value);
            var postedItems = model.Items ?? new List<TemplateItem>();

            // 3️⃣ Process and sync template items (add/update)
            var syncResult = await SyncTemplateItemsAsync(postedItems, userQuote, model);

            // 4️⃣ Update quote status
            if (userQuote != null)
                userQuote.Status = "Authorised";

            await _context.SaveChangesAsync();

            // 5️⃣ Generate PDF
            var pdfResult = await TryGenerateQuotePdfAsync(userQuote, model, currency);

            // 6️⃣ Return result
            return (
                pdfResult.Success,
                pdfResult.Message + $" (Added: {syncResult.Added}; Updated: {syncResult.Updated}; Skipped: {syncResult.Skipped})"
            );
        }
        private async Task<UserRecord> GetQuoteDetails(int RecStatusId)
        {
            return await _context.UserRecords
                    .FirstOrDefaultAsync(r => r.RecStatusId == RecStatusId);
        }
        private async Task<SyncResult> SyncTemplateItemsAsync(List<TemplateItem> postedItems, UserRecord userQuote, UserAnswerVM model)
        {
            var dbItems = GetTemplateItems(model.RecStatusId.Value);
            var dbById = MapById(dbItems);

            int added = 0, updated = 0, skipped = 0;

            foreach (var posted in postedItems)
            {
                var postedRowId = (posted.RowId ?? "").Trim();

                if (IsExistingItem(posted, dbById, out var dbItem))
                {
                    UpdateExistingItem(dbItem, posted, userQuote);
                    updated++;
                }
                else
                {
                    if (posted.TemplateItemId > 0)
                        posted.TemplateItemId = 0; // reset PK for new revision

                    // Correct duplicate check (RowId + ServiceName + TempVersionId)
                    if (IsDuplicateItem(postedRowId, userQuote, posted.ServiceName))
                    {
                        skipped++;
                        continue;
                    }

                    PrepareNewItem(posted, model, userQuote);
                    _context.TemplateItems.Add(posted);
                    added++;
                }
            }


            return new SyncResult(added, updated, skipped);
        }

        private Dictionary<int, TemplateItem> MapById(IEnumerable<TemplateItem> items)
        {
            return items.ToDictionary(d => d.TemplateItemId, d => d);
        }

        private List<TemplateItem> GetTemplateItems(int RecStatusId)
        {
            return _context.TemplateItems
                .Where(t => t.QuoteId == RecStatusId)
                .ToList();
        }

        private bool IsExistingItem(TemplateItem posted, Dictionary<int, TemplateItem> dbById, out TemplateItem? dbItem)
        {
            dbItem = null;
            return posted.TemplateItemId > 0 && dbById.TryGetValue(posted.TemplateItemId, out dbItem);
        }

        private void UpdateExistingItem(TemplateItem dbItem, TemplateItem posted, UserRecord userQuote)
        {
            dbItem.ServiceName = posted.ServiceName;
            dbItem.Description = posted.Description;
            dbItem.Quantity = posted.Quantity;
            dbItem.Unit = posted.Unit;
            dbItem.ItemPrice = posted.ItemPrice;
            dbItem.Total = posted.Total;
            dbItem.RowId = (posted.RowId ?? "").Trim();

            dbItem.CustomerId ??= userQuote.CustomerId;
            dbItem.QuoteId ??= userQuote.RecStatusId;
        }
        private bool IsDuplicateItem(string postedRowId, UserRecord userQuote, string serviceName)
        {
            if (string.IsNullOrWhiteSpace(serviceName))
                return false;

            string svc = serviceName.ToLower();

            return _context.TemplateItems.Any(t =>
                t.CustomerId == userQuote.CustomerId &&
                t.QuoteId == userQuote.RecStatusId &&
                t.TemplateVersion == userQuote.TempVersionId &&          // NEW CHECK
                (
                    t.RowId == postedRowId ||                          // existing check
                    t.ServiceName.ToLower() == svc                     // NEW service name check
                )
            );
        }

        private void PrepareNewItem(TemplateItem posted, UserAnswerVM model, UserRecord userQuote)
        {
            posted.TemplateId = model.TemplateId.Value;
            posted.TemplateVersion = model.TemplateVersion.Value;
            posted.CustomerId = userQuote.CustomerId;
            posted.QuoteId = userQuote.RecStatusId;
            posted.BusinessId = GetCurrentBusinessId();
        }
        private async Task<PdfResult> TryGenerateQuotePdfAsync(UserRecord userQuote, UserAnswerVM model, string currency)
        {
            try
            {
                bool pdfSuccess = await GenerateQuotePdf(userQuote, model, currency);
                if (pdfSuccess)
                    return new PdfResult(true, "Quote created successfully!");

                return new PdfResult(false, "Failed to send data to API.");
            }
            catch (Exception ex)
            {
                return new PdfResult(false, ex.Message);
            }
        }

        //private async Task<bool> GenerateQuotePdf(UserRecord userQuote, UserAnswerVM model, string currency)
        //{
        //    var date = userQuote.CreatedAt;
        //    var quoteNo = userQuote.QuoteReference;

        //    // ✅ Fetch customer and main linked material rows
        //    var user = await GetCustomer(model.CustomerId.Value);
        //    var rows = GetLinkedMaterialComponent(model.CustomerId.Value, model.TemplateId.Value, model.TemplateVersion.Value);

        //    // ✅ Fetch all template items (single DB call)
        //    var allTemplateItems = GetTemplateItems(model, userQuote);

        //    // ✅ Derive service and numbered rows
        //    var numberedRows = GetNumberedRows(allTemplateItems);
        //    var serviceRows = GetServiceRows(model, userQuote);

        //    // ✅ Build display tables
        //    var tableData = BuildMaterialTable(rows, currency);
        //    var serviceTableData = BuildServiceTable(numberedRows, currency);

        //    // ✅ Totals
        //    var grandTotal = FormatCurrency(rows.Sum(r => r.Price * r.Quantity), currency);
        //    var grandTotal2 = FormatCurrency(numberedRows.Sum(r => r.ItemPrice * r.Qty), currency);

        //    // ✅ Service names for top section
        //    var serviceNames = GetServiceNames(model, userQuote);
        //    var metafieldNames = GetMetafieldNames(model);
        //    // ✅ File configuration
        //    string outputFile = quoteNo + ".pdf";
        //    string flPath = _configuration["FileSettings:TemplateFilePath"];
        //    string flStoragePath = _configuration["FileSettings:FileStoragePath"];

        //    var payload = new
        //    {
        //        TemplateFilePath = flPath,
        //        FileStoragePath = Path.Combine(flStoragePath, outputFile),
        //        Data = new
        //        {
        //            DOCTITLE = "Quotation",
        //            Start_Row = "InTable",
        //            Q = JsonConvert.SerializeObject(tableData),
        //            S = JsonConvert.SerializeObject(serviceTableData),
        //            GRANDTOTAL = grandTotal,
        //            NAMES = JsonConvert.SerializeObject(serviceNames),
        //            CLIENTCONTACT = user.PhoneNumber ?? "",
        //            CUSTOMERNAME = $"{user.FirstName} {user.LastName}",
        //            TOTAL2 = grandTotal2,
        //            CREATED_AT = date?.ToString("dd/MM/yyyy") ?? "",
        //            QUOTE_NO = quoteNo
        //        }
        //    };

        //    // ✅ Send to PDF generator API
        //    return await SendToReceiverApi(payload);
        //}
        private async Task<bool> GenerateQuotePdf(UserRecord userQuote, UserAnswerVM model, string currency)
        {
            var date = userQuote.CreatedAt;
            var quoteNo = userQuote.QuoteReference;

            // Fetch customer and main linked material rows
            var user = await GetCustomer(model.CustomerId.Value);
            var rows = GetLinkedMaterialComponent(model.CustomerId.Value, model.TemplateId.Value, model.TemplateVersion.Value);

            // Fetch all template items
            var allTemplateItems = GetTemplateItems(model, userQuote);

            // Derive service and numbered rows
            var numberedRows = GetNumberedRows(allTemplateItems);
            var serviceRows = GetServiceRows(model, userQuote);

            // Build display tables
            var tableData = BuildMaterialTable(rows, currency);
            var serviceTableData = BuildServiceTable(numberedRows, currency);

            // Totals
            var grandTotal = FormatCurrency(rows.Sum(r => r.Price * r.Quantity), currency);
            var grandTotal2 = FormatCurrency(numberedRows.Sum(r => r.ItemPrice * r.Qty), currency);

            // Service names for top section
            var serviceNames = GetServiceNames(model, userQuote);

            // File configuration
            string outputFile = quoteNo + ".pdf";
            string flPath = _configuration["FileSettings:TemplateFilePath"];
            string flStoragePath = _configuration["FileSettings:FileStoragePath"];
            var style1TableData = new List<Dictionary<string, string>>
{
    new()
    {
        ["Col1"] = "Row1-Col1",
        ["Col2"] = "Row1-Col2",
        ["Col3"] = "Row1-Col3",
        ["Col4"] = "Row1-Col4",
        ["Col5"] = "Row1-Col5"
    },
    new()
    {
        ["Col1"] = "Row2-Col1",
        ["Col2"] = "Row2-Col2",
        ["Col3"] = "Row2-Col3",
        ["Col4"] = "Row2-Col4",
        ["Col5"] = "Row2-Col5"
    }
};

            // CREATE DYNAMIC DATA OBJECT
            var data = new Dictionary<string, object>
            {
                ["DOCTITLE"] = "Quotation",
                ["Start_Row"] = "InTable",
                ["Q"] = JsonConvert.SerializeObject(tableData),
                ["S"] = JsonConvert.SerializeObject(serviceTableData),
                ["GRANDTOTAL"] = grandTotal,
                ["NAMES"] = JsonConvert.SerializeObject(serviceNames),
                ["CLIENTCONTACT"] = user.PhoneNumber ?? "",
                ["CUSTOMERNAME"] = $"{user.FirstName} {user.LastName}",
                ["TOTAL2"] = grandTotal2,
                ["CREATED_AT"] = date?.ToString("dd/MM/yyyy") ?? "",
                ["QUOTE_NO"] = quoteNo
            };

            // INJECT METAFIELDS AS DYNAMIC TAGS (key = Name, value = Value)
            InjectMetafieldsIntoPayloadByDbTag(data, model); // single-line metafields
            //await InjectTableMetafieldsAsync(data, model);  // table metafields


            // FINAL PAYLOAD
            var payload = new
            {
                TemplateFilePath = flPath,
                FileStoragePath = Path.Combine(flStoragePath, outputFile),
                Data = data
            };

            // Send to PDF generator API
            return await SendToReceiverApi(payload);
        }


        private async Task InjectMetafieldsIntoPayloadAsync(
    Dictionary<string, object> data,
    UserAnswerVM model)
        {
            if (model?.Metafields == null || !model.Metafields.Any())
                return;

            // 1️⃣ Keep existing single-line text logic
            InjectSingleLineMetafields(data, model);

            // 2️⃣ Add table-based metafields
            await InjectTableMetafieldsAsync(data, model);
        }
        private void InjectSingleLineMetafields(
    Dictionary<string, object> data,
    UserAnswerVM model)
        {
            foreach (var field in model.Metafields)
            {
                if (string.IsNullOrWhiteSpace(field.Value))
                    continue;

                // skip table JSON
                if (IsJsonArray(field.Value))
                    continue;

                string tag = GetMetafieldTagFromDb(field.PID);

                if (!string.IsNullOrWhiteSpace(tag))
                {
                    if (!data.ContainsKey(tag))
                        data[tag] = field.Value;
                }
            }
        }
        private async Task InjectTableMetafieldsAsync(
       Dictionary<string, object> data,
       UserAnswerVM model)
        {
            var tableFields = model.Metafields
                .Where(m => !string.IsNullOrWhiteSpace(m.Value) && IsJsonArray(m.Value))
                .ToList();

            if (!tableFields.Any())
                return;

            var metafieldIds = tableFields.Select(m => m.MetafieldId).ToList();

            var dbStyles = await _context.Metafields
                .Where(m => metafieldIds.Contains(m.PID))
                .Select(m => new
                {
                    m.PID,
                    m.TableStyle,
                    m.FieldType
                })
                .ToListAsync();

            foreach (var field in tableFields)
            {
                var meta = dbStyles.FirstOrDefault(x => x.PID == field.MetafieldId);
                if (meta == null)
                    continue;

                // Ensure this metafield is a table
                if (!string.Equals(meta.FieldType, "table", StringComparison.OrdinalIgnoreCase))
                    continue;

                if (string.IsNullOrWhiteSpace(meta.TableStyle))
                    continue;

                // 🔹 Extract style number from string (e.g. "style1", "Style 2", "1")
                var match = System.Text.RegularExpressions.Regex.Match(meta.TableStyle, @"\d+");
                if (!match.Success)
                    continue;

                int styleNo = int.Parse(match.Value);

                var styleKey = $"style{styleNo}";
                var dataKey = $"s{styleNo}";

                // Activate style
                data[styleKey] = "value";

                // Attach table data
                data[dataKey] = field.Value;
            }
        }

        private bool IsJsonArray(string input)
        {
            input = input?.Trim();
            return !string.IsNullOrEmpty(input)
                   && input.StartsWith("[")
                   && input.EndsWith("]");
        }

        private void InjectMetafieldsIntoPayloadByDbTag(Dictionary<string, object> data, UserAnswerVM model)
        {
            if (model?.Metafields == null || !model.Metafields.Any())
                return;

            foreach (var field in model.Metafields)
            {
                // 1️⃣ Fetch the 'Tag' from DB or model using PID
                string tag = GetMetafieldTagFromDb(field.PID); // <-- implement DB lookup

                if (!string.IsNullOrWhiteSpace(tag))
                {
                    var key = tag.Trim();

                    // 2️⃣ Add to payload if not already present
                    if (!data.ContainsKey(key))
                        data[key] = field.Value ?? string.Empty;
                }
            }
        }


        private string GetMetafieldTagFromDb(int pid)
        {
            
            var metafieldRow = _context.Metafields
                                 .Where(m => m.PID == pid)
                                 .Select(m => m.Tag) // the column in your table
                                 .FirstOrDefault();

            return metafieldRow ?? string.Empty;
        }

        private async Task<Customer> GetCustomer(int customerId)
        {
            return await _context.Customers
           .Where(u => u.CustomerId == customerId)
           .FirstOrDefaultAsync();
        }
        private List<MaterialComponentVM> GetLinkedMaterialComponent(int CustomerId, int TemplateId, int TemplateVersion)
        {
            var rows = (from ua in _context.UserAnswers.Where(c => c.CustomerId == CustomerId)
                        join qo in _context.QuestionOptions
                            on ua.QoptionId equals qo.QoptionId
                        join q in _context.Questions.Where(t => t.TemplateId == TemplateId && t.TemplateVersionId == TemplateVersion)
                            on qo.QuestionId equals q.QuestionId
                        // Left join with Materials (conditionally)
                        join m in _context.Materials
                            on qo.MaterialCompId equals m.MaterialId into matGroup
                        from m in matGroup.DefaultIfEmpty()
                            // Left join with Components (conditionally)
                        join c in _context.Components
                            on qo.MaterialCompId equals c.ComponentId into compGroup
                        from c in compGroup.DefaultIfEmpty()
                            // Filter to only include matching ones based on MatCompName
                        where (qo.MatCompName == "Material" && m != null)
                           || (qo.MatCompName == "Component" && c != null)
                        select new MaterialComponentVM
                        {

                            Quantity = 1,
                            AnswerText = ua.AnswerText,
                            PartNo = qo.MatCompName == "Material" ? m.PartNo : c.PartNo,
                            Item = qo.MatCompName == "Material" ? m.Name : c.Name,
                            Notes = qo.MatCompName == "Material" ? m.Description : c.Description,
                            Price = qo.MatCompName == "Material" ? m.SellPrice : c.SellPrice,
                        }).ToList();

            foreach (var rec in rows)
            {
                try
                {
                    if (decimal.TryParse(rec.AnswerText, out var parsedQty))
                        rec.Quantity = parsedQty;
                    else
                        rec.Quantity = 1;
                }
                catch (Exception e)
                {
                    rec.Quantity = 1;
                }
            }

            return rows;
        }
        private List<TemplateItemRow> GetTemplateItems(UserAnswerVM model, UserRecord userQuote)
        {
            return _context.TemplateItems
                .Where(t => t.TemplateId == model.TemplateId
                    && t.TemplateVersion == model.TemplateVersion
                    && t.RowId != null
                    && t.CustomerId == model.CustomerId
                    && t.QuoteId == userQuote.RecStatusId)
                .AsEnumerable()
                .Select(t => new TemplateItemRow(
                    t.ServiceName,
                    t.Description,
                    t.Quantity,
                    t.Unit,
                    t.ItemPrice,
                    t.RowId
                ))
                .OrderBy(t => t.RowId, StringComparer.OrdinalIgnoreCase)
                .ToList();
        }
        private List<NumberedRow> GetNumberedRows(IEnumerable<TemplateItemRow> items)
        {
            return items.Select(row => new NumberedRow(
                row.RowId,
                row.Description,
                row.Notes,
                row.Qty,
                row.Unit,
                row.ItemPrice
            )).ToList();
        }
        private List<TemplateItemRow> GetServiceRows(UserAnswerVM model, UserRecord userQuote)
        {
            return _context.TemplateItems
                .Where(t => t.TemplateId == model.TemplateId
                    && t.TemplateVersion == model.TemplateVersion
                    && t.RowId != null
                    && t.CustomerId == model.CustomerId
                    && t.QuoteId == userQuote.RecStatusId)
                .AsEnumerable()
                .Where(t => !t.RowId.Contains(".") && t.RowId.All(char.IsDigit))
                .Select(t => new TemplateItemRow(
                    t.ServiceName,
                    t.Description,
                    t.Quantity,
                    t.Unit,
                    t.ItemPrice,
                    t.RowId
                ))
                .ToList();
        }
        private List<MaterialTableRow> BuildMaterialTable(IEnumerable<dynamic> rows, string currency)
        {
            var tableData = rows.Select(r => new MaterialTableRow(
                r.PartNo.ToString(),
                r.Quantity.ToString(),
                r.Item,
                r.Notes,
                FormatCurrency(r.Price, currency),
                FormatCurrency(r.Quantity * r.Price, currency)
            )).ToList();

            if (!tableData.Any())
                tableData.Add(new MaterialTableRow("", "", "", "", "", ""));

            return tableData;
        }
        private List<ServiceTableRow> BuildServiceTable(IEnumerable<NumberedRow> numberedRows, string currency)
        {
            var serviceTable = numberedRows.Select(r => new ServiceTableRow(
                r.Line,
                r.Description,
                r.Notes,
                r.Qty?.ToString() ?? "",
                r.Unit,
                FormatCurrency(r.ItemPrice, currency),
                FormatCurrency((r.Qty ?? 0) * (r.ItemPrice ?? 0), currency)
            )).ToList();

            if (!serviceTable.Any())
                serviceTable.Add(new ServiceTableRow("", "", "", "", "", "", ""));

            return serviceTable;
        }
        private List<string> GetServiceNames(UserAnswerVM model, UserRecord userQuote)
        {
            return _context.TemplateItems
                .Where(t => t.TemplateId == model.TemplateId
                    && t.TemplateVersion == model.TemplateVersion
                    && t.CustomerId == model.CustomerId
                    && t.QuoteId == userQuote.RecStatusId
                    && t.RowId != null)
                .AsEnumerable()
                .Where(t => !t.RowId.Contains(".") && t.RowId.All(char.IsDigit))
                .Select(t => t.ServiceName)
                .ToList();
        }

        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }
        private async Task<bool> SendToReceiverApi(object payload)
        {
            try
            {
                var jsonData = JsonConvert.SerializeObject(payload);
                var content = new StringContent(jsonData, Encoding.UTF8, "application/json");
                var client = _httpClientFactory.CreateClient();

                var response = await client.PostAsync("http://localhost:5050/api/receiver", content);
                return response.IsSuccessStatusCode;
            }
            catch
            {
                return false;
            }
        }
        public async Task<List<TemplateItem>> GetItemsByTemplateIdAsync(int quoteId)
        {
            return await _context.TemplateItems
                .Where(x => x.QuoteId == quoteId)
                .ToListAsync();
        }

        // Make this private if you only use it internally
        public async Task<bool> CheckTemplatesAsync(int quoteId)
        {
            return await _context.TemplateItems.AnyAsync(t => t.QuoteId == quoteId);
        }

        public async Task<QuoteDetailsResult> GetQuoteDetailsAsync(int id)
        {
            var data = await (
               from r in _context.UserRecords.Where(rec => rec.RecStatusId == id)
               join t in _context.Templates on r.TemplateId equals t.TemplateId
               select new
               {
                   TemplateName = t.TemplateName,
                   TemplateId = r.TemplateId,
                   TemplateVersionId = r.TempVersionId,
                   customerId = r.CustomerId
               }
           ).FirstOrDefaultAsync();

            var exists = data != null;

            return new QuoteDetailsResult
            {
                Exists = exists,
                TemplateName = data?.TemplateName,
                TemplateId = data?.TemplateId,
                TemplateVersionId = data?.TemplateVersionId,
                CustomerId = data?.customerId
            };
        }
        public async Task<(bool Success, string Message, byte[] FileBytes, string FileName)> DownloadQuoteAsync(int quoteId)
        {
            var record = await _context.UserRecords
                .FirstOrDefaultAsync(u => u.RecStatusId == quoteId);

            if (record == null || string.IsNullOrEmpty(record.Pdflink))
                return (false, "The PDF is still being generated. Please try again later.", null, null);

            var filePath = record.Pdflink;
            if (!File.Exists(filePath))
                return (false, "The PDF is still being generated. Please try again later.", null, null);

            var fileBytes = await File.ReadAllBytesAsync(filePath);
            var fileName = Path.GetFileName(filePath);

            return (true, "Success", fileBytes, fileName);
        }
    }
}
