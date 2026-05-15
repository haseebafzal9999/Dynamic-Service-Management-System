 using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using zentro.library;
using zentro.Models;
using zentro.View_Model;

namespace zentro.Api.MaterialApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class MaterialController : ControllerBase
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public MaterialController(dbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }
        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }

        private List<MaterialIndexModel> GenerateMaterialOverview(IQueryable<Material> materialQuery)
        {
            return materialQuery.Select(x => new MaterialIndexModel
            {
                MaterialId = x.MaterialId,
                PartNo = x.PartNo,
                Name = x.Name,
                Description = x.Description,
                CostPrice = (decimal)x.CostPrice,
                SellPrice = (decimal)x.SellPrice,
                Supplier = x.Supplier,
                CreatedAt = x.CreatedAt,
                Id =x.MaterialId
            }).OrderByDescending(cr => cr.CreatedAt).ToList();
        }



        [HttpGet]
        public async Task<List<MaterialIndexModel>> GetMaterials()
        {
            var businessId = GetCurrentBusinessId();
            IQueryable<Material> query = _context.Materials.Where(x => x.IsActive == true && x.BusinessId == businessId);
            return GenerateMaterialOverview(query);
        }






        [HttpGet("FilterMaterialIndex")]
        public JsonResult FilterMaterialIndex([FromQuery] MaterialFiltersModel filters, [FromQuery] string[] Supplier)
        {
            var businessId = GetCurrentBusinessId();
            IQueryable<Material> query = _context.Materials.Where(r => r.IsActive == true && r.BusinessId == businessId);

            // DEBUG: write the raw querystring (optional)
            var rawQs = Request.QueryString.HasValue ? Request.QueryString.Value : "";
            System.Diagnostics.Debug.WriteLine($"FilterMaterialIndex called. QueryString: {rawQs}");

            // --------- 1) Supplier filter (supports multiple suppliers)
            if (Supplier != null && Supplier.Length > 0)
            {
                var supplierLowerList = Supplier
                    .Where(s => !string.IsNullOrWhiteSpace(s))
                    .Select(s => s.Trim().ToLower())
                    .ToList();

                query = query.Where(x => !string.IsNullOrEmpty(x.Supplier)
                                         && supplierLowerList.Contains(x.Supplier.ToLower()));
            }

            // --------- 2) Helper to parse decimal (strip currency symbols)
            decimal? ParseDecimal(string s)
            {
                if (string.IsNullOrWhiteSpace(s)) return null;
                var cleaned = s.Replace("£", "").Replace("$", "").Replace(",", "").Trim();
                if (decimal.TryParse(cleaned, NumberStyles.Number | NumberStyles.AllowCurrencySymbol, CultureInfo.InvariantCulture, out var d))
                    return d;
                if (decimal.TryParse(cleaned, NumberStyles.Number | NumberStyles.AllowCurrencySymbol, CultureInfo.CurrentCulture, out d))
                    return d;
                return null;
            }

            // --------- 3) Handle repeated Price params: Price=10&Price=100&Price=SellPrice
            if (Request.Query.TryGetValue("Price", out var priceVals) && priceVals.Count > 0)
            {
                var nums = new List<decimal>();
                string parsedField = null;

                foreach (var raw in priceVals)
                {
                    if (string.IsNullOrWhiteSpace(raw)) continue;
                    var p = ParseDecimal(raw);
                    if (p.HasValue) nums.Add(p.Value);
                    else parsedField = parsedField ?? raw.Trim();
                }

                if (nums.Count > 0)
                {
                    nums.Sort();
                    filters.MinPrice = filters.MinPrice ?? nums.First();
                    filters.MaxPrice = filters.MaxPrice ?? (nums.Count > 1 ? nums.Last() : nums.First());
                }

                if (string.IsNullOrWhiteSpace(filters.PriceField) && !string.IsNullOrWhiteSpace(parsedField))
                    filters.PriceField = parsedField;
            }

            // --------- 4) Fallbacks for MinPrice / MaxPrice / PriceField
            string[] minKeys = { "MinPrice", "minPrice", "minprice" };
            string[] maxKeys = { "MaxPrice", "maxPrice", "maxprice" };
            string[] fieldKeys = { "PriceField", "priceField", "pricefield" };

            if (!filters.MinPrice.HasValue)
                foreach (var k in minKeys)
                    if (Request.Query.TryGetValue(k, out var mv) && mv.Count > 0 && ParseDecimal(mv[0]) is decimal pv)
                    {
                        filters.MinPrice = pv;
                        break;
                    }

            if (!filters.MaxPrice.HasValue)
                foreach (var k in maxKeys)
                    if (Request.Query.TryGetValue(k, out var mv) && mv.Count > 0 && ParseDecimal(mv[0]) is decimal pv)
                    {
                        filters.MaxPrice = pv;
                        break;
                    }

            if (string.IsNullOrWhiteSpace(filters.PriceField))
                foreach (var k in fieldKeys)
                    if (Request.Query.TryGetValue(k, out var fv) && fv.Count > 0)
                    {
                        filters.PriceField = fv[0];
                        break;
                    }

            // --------- 5) Normalize min/max
            if (filters.MinPrice.HasValue && filters.MaxPrice.HasValue && filters.MinPrice > filters.MaxPrice)
            {
                var tmp = filters.MinPrice;
                filters.MinPrice = filters.MaxPrice;
                filters.MaxPrice = tmp;
            }

            if (filters.MinPrice.HasValue && !filters.MaxPrice.HasValue) filters.MaxPrice = filters.MinPrice;
            if (!filters.MinPrice.HasValue && filters.MaxPrice.HasValue) filters.MinPrice = filters.MaxPrice;

            // --------- 6) Search filter (unchanged)
            if (!string.IsNullOrEmpty(filters?.sT) && filters.sT.StartsWith("q", StringComparison.OrdinalIgnoreCase))
            {
                var search = Common.DecodeUrlString(filters.sT.Substring(1).Trim().ToLower());
                query = query.Where(x =>
                    (!string.IsNullOrEmpty(x.PartNo) && x.PartNo.ToLower().Contains(search)) ||
                    (!string.IsNullOrEmpty(x.Name) && x.Name.ToLower().Contains(search)) ||
                    (!string.IsNullOrEmpty(x.Description) && x.Description.ToLower().Contains(search)) ||
                    (!string.IsNullOrEmpty(x.Supplier) && x.Supplier.ToLower().Contains(search))
                );
            }

            // --------- 7) Price filter
            var priceField = (filters?.PriceField ?? "SellPrice").Trim();
            if (filters?.MinPrice != null)
            {
                if (priceField.Equals("CostPrice", StringComparison.OrdinalIgnoreCase))
                    query = query.Where(x => x.CostPrice >= filters.MinPrice.Value);
                else
                    query = query.Where(x => x.SellPrice >= filters.MinPrice.Value);
            }

            if (filters?.MaxPrice != null)
            {
                if (priceField.Equals("CostPrice", StringComparison.OrdinalIgnoreCase))
                    query = query.Where(x => x.CostPrice <= filters.MaxPrice.Value);
                else
                    query = query.Where(x => x.SellPrice <= filters.MaxPrice.Value);
            }

            var materials = GenerateMaterialOverview(query);
            return new JsonResult(new { lists = materials });
        }



        [HttpGet("MaterialFilterLists")]
        public JsonResult MaterialFilterLists()
        {
            // supplier list (unchanged)
            var businessId = GetCurrentBusinessId();
            var scoped = _context.Materials
                .Where(r => r.IsActive == true && r.BusinessId == businessId);

            var supplierList = scoped
                .Where(x => !string.IsNullOrEmpty(x.Supplier))
                .Select(x => x.Supplier)
                .Distinct()
                .OrderBy(s => s)
                .Select(s => new { value = s, name = s })
                .ToList();

            // compute SellPrice min/max (null-safe)
            decimal? sellMin = _context.Materials.Where(r => r.IsActive == true)
                .Where(x => x.SellPrice != null)
                .Min(x => (decimal?)x.SellPrice);
            decimal? sellMax = _context.Materials.Where(r => r.IsActive == true)
                .Where(x => x.SellPrice != null)
                .Max(x => (decimal?)x.SellPrice);

            // compute CostPrice min/max (null-safe)
            decimal? costMin = _context.Materials.Where(r => r.IsActive == true)
                .Where(x => x.CostPrice != null)
                .Min(x => (decimal?)x.CostPrice);
            decimal? costMax = _context.Materials.Where(r => r.IsActive == true)
                .Where(x => x.CostPrice != null)
                .Max(x => (decimal?)x.CostPrice);

            // sensible fallbacks if DB has no values
            if (!sellMin.HasValue) { sellMin = 0m; sellMax = 1000m; }
            if (!costMin.HasValue) { costMin = 0m; costMax = 1000m; }

            // ensure a non-zero range
            if (sellMin == sellMax) sellMax = sellMin + 1m;
            if (costMin == costMax) costMax = costMin + 1m;

            var priceList = new List<object>
    {
        new { value = "SellPrice", name = "Sell Price", min = sellMin, max = sellMax },
        new { value = "CostPrice", name = "Cost Price", min = costMin, max = costMax }
    };

            var lists = new
            {
                supplierLists = supplierList,
                priceLists = priceList
            };

            var combinedList = new List<object> { lists };
            return new JsonResult(new { lists = combinedList });
        }

        [HttpGet("PriceRange")]
        public JsonResult PriceRange([FromQuery] string field = "SellPrice")
        {
            var businessId = GetCurrentBusinessId();
            var scoped = _context.Materials.Where(m => m.BusinessId == businessId);
            decimal? min = null, max = null;

            if (field?.Equals("CostPrice", StringComparison.OrdinalIgnoreCase) == true)
            {
                min = _context.Materials.Where(x => x.CostPrice != null).Min(x => (decimal?)x.CostPrice);
                max = _context.Materials.Where(x => x.CostPrice != null).Max(x => (decimal?)x.CostPrice);
            }
            else
            {
                min = _context.Materials.Where(x => x.SellPrice != null).Min(x => (decimal?)x.SellPrice);
                max = _context.Materials.Where(x => x.SellPrice != null).Max(x => (decimal?)x.SellPrice);
            }

            if (!min.HasValue) { min = 0m; max = 1000m; }
            if (min == max) max = min + 1m;

            return new JsonResult(new { min, max });
        }



        [HttpPost("Create")]
        public async Task<IActionResult> Create([FromForm] MaterialIndexModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { success = false, errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage) });
            }
            var businessId = GetCurrentBusinessId();
            var entity = new Material
            {
                PartNo = model.PartNo,
                Name = model.Name,
                Description = model.Description,
                CostPrice = model.CostPrice ?? 0m,
                SellPrice = model.SellPrice ?? 0m,
                Supplier = model.Supplier,
                IsActive = true,
                BusinessId = businessId,
                CreatedAt = DateTime.Now,
                // CreatedById = model.CreatedById // ideally set from user claims instead
            };

            _context.Materials.Add(entity);
            await _context.SaveChangesAsync();

            var created = new MaterialIndexModel
            {
                MaterialId = entity.MaterialId,
                PartNo = entity.PartNo,
                Name = entity.Name,
                Description = entity.Description,
                CostPrice = entity.CostPrice,
                SellPrice = entity.SellPrice,
                Supplier = entity.Supplier,
                CreatedAt = entity.CreatedAt,
                CreatedById = entity.CreatedById,
                IsActive = entity.IsActive
            };

            return Ok(new { success = true, item = created });
        }

        [HttpPost("Update")]
        public async Task<IActionResult> Update([FromForm] MaterialIndexModel model)
        {
            var businessId = GetCurrentBusinessId();

            var entity = await _context.Materials
               .FirstOrDefaultAsync(m => m.MaterialId == model.MaterialId && m.BusinessId == businessId);
            if (entity == null)
                return NotFound(new { success = false, message = "Material not found" });

            entity.PartNo = model.PartNo;
            entity.Name = model.Name;
            entity.Description = model.Description;
            entity.CostPrice = model.CostPrice ?? 0m;
            entity.SellPrice = model.SellPrice ?? 0m;
            entity.Supplier = model.Supplier;

            await _context.SaveChangesAsync();

            var updated = new MaterialIndexModel
            {
                MaterialId = entity.MaterialId,
                PartNo = entity.PartNo,
                Name = entity.Name,
                Description = entity.Description,
                CostPrice = entity.CostPrice,
                SellPrice = entity.SellPrice,
                Supplier = entity.Supplier
            };

            return Ok(new { success = true, item = updated });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetMaterialById(int id)
        {
            var businessId = GetCurrentBusinessId();

            var entity = await _context.Materials
                .Where(m => m.BusinessId == businessId)
                .FirstOrDefaultAsync(m => m.MaterialId == id);

            if (entity == null)
                return NotFound(new { success = false, message = "Material not found" });

            var material = new MaterialIndexModel
            {
                MaterialId = entity.MaterialId,
                PartNo = entity.PartNo,
                Name = entity.Name,
                Description = entity.Description,
                CostPrice = entity.CostPrice,
                SellPrice = entity.SellPrice,
                Supplier = entity.Supplier
            };

            return new JsonResult(material);
        }

        [HttpDelete("DeleteMaterial/{id}")]
        public async Task<IActionResult> DeleteMaterial(int id)
        {
            var businessId = GetCurrentBusinessId();

            var entity = await _context.Materials
                 .FirstOrDefaultAsync(m => m.MaterialId == id && m.BusinessId == businessId);

            if (entity == null)
                return NotFound(new { success = false, message = "Material not found" });

            entity.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { success = true });
        }

        [HttpGet("IsMaterialDependent/{id}")]
        public async Task<IActionResult> IsMaterialDependent(int id)
        {
            var businessId = GetCurrentBusinessId();
            var entity = await _context.MaterialComponents
                .AnyAsync(x => x.MaterialId == id);

            if (entity != null)
                return Ok(new { success = true });

            return Ok(new { success = false });
        }


    }
}
