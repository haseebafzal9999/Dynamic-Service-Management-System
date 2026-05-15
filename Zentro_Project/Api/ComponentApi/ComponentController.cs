using Microsoft.AspNetCore.Http;
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

namespace zentro.Api.ComponentApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class ComponentController : ControllerBase
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ComponentController(dbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }
        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }

        // Helper: Generate Component overview
        private List<ComponentIndexModel> GenerateComponentOverview(IQueryable<Component> query)
        {
            return query
                .Include(c => c.MaterialComponents)            // Include materials
                    .ThenInclude(mc => mc.Material)
                .Select(x => new ComponentIndexModel
                {
                    ComponentId = x.ComponentId,
                    PartNo = x.PartNo,
                    Name = x.Name,
                    Description = x.Description,
                    BuildCost = (decimal)x.BuildCost,
                    SellPrice = (decimal)x.SellPrice,
                    Supplier = x.Supplier,
                    IsActive = x.IsActive,
                    CreatedAt = x.CreatedAt,
                    Materials = x.MaterialComponents
                                 .Where(mc => mc.IsActive)
                                 .Select(mc => mc.Material.Name)
                                 .Where(name => !string.IsNullOrEmpty(name))
                                 .Distinct()
                                 .ToList(),
                    Id = x.ComponentId
                }).OrderByDescending(cr=>cr.CreatedAt)
                .ToList();
        }


        // ----------------- GET: All Components -----------------
        [HttpGet]
        public async Task<List<ComponentIndexModel>> GetComponents()
        {
            var businessId = GetCurrentBusinessId();
            var components = await _context.Components
                .Where(r=>r.IsActive==true && r.BusinessId == businessId)
                .Include(c => c.MaterialComponents)
                    .ThenInclude(mc => mc.Material)
                .Select(c => new ComponentIndexModel
                {
                    ComponentId = c.ComponentId,
                    PartNo = c.PartNo,
                    Name = c.Name,
                    Description = c.Description,
                    BuildCost = c.BuildCost,
                    SellPrice = c.SellPrice,
                    Supplier = c.Supplier,
                    IsActive = c.IsActive,
                    CreatedAt = c.CreatedAt,
                    Materials = c.MaterialComponents
                                 .Select(mc => mc.Material.Name)
                                 .Where(name => !string.IsNullOrEmpty(name))
                                 .Distinct()
                                 .ToList()
                }).OrderByDescending(cr => cr.CreatedAt)
                .ToListAsync();

            return components;
        }



        // ----------------- GET: Filtered Components -----------------
        [HttpGet("FilterComponentIndex")]
        public JsonResult FilterComponentIndex([FromQuery] string[] Supplier)
        {
            var businessId = GetCurrentBusinessId();
            IQueryable<Component> query = _context.Components.Where(r => r.IsActive == true && r.BusinessId == businessId);

            // Handle supplier filtering
            if (Supplier != null && Supplier.Length > 0)
            {
                var supplierLowerList = Supplier
                    .Where(s => !string.IsNullOrWhiteSpace(s))
                    .Select(s => s.Trim().ToLower())
                    .ToList();

                query = query.Where(x => !string.IsNullOrEmpty(x.Supplier)
                                         && supplierLowerList.Contains(x.Supplier.ToLower()));
            }

            // Parse Price query params
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

            var filters = new ComponentFiltersModel(); // temp model for price/search handling

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
                    filters.MinPrice = nums.First();
                    filters.MaxPrice = nums.Count > 1 ? nums.Last() : nums.First();
                }

                if (!string.IsNullOrWhiteSpace(parsedField))
                    filters.PriceField = parsedField;
            }

            // Explicit MinPrice/MaxPrice fallback
            string[] minKeys = { "MinPrice", "minPrice", "minprice" };
            string[] maxKeys = { "MaxPrice", "maxPrice", "maxprice" };
            string[] fieldKeys = { "PriceField", "priceField", "pricefield" };

            foreach (var k in minKeys)
                if (Request.Query.TryGetValue(k, out var mv) && mv.Count > 0 && ParseDecimal(mv[0]) is decimal pv)
                {
                    filters.MinPrice = pv;
                    break;
                }

            foreach (var k in maxKeys)
                if (Request.Query.TryGetValue(k, out var mv) && mv.Count > 0 && ParseDecimal(mv[0]) is decimal pv)
                {
                    filters.MaxPrice = pv;
                    break;
                }

            foreach (var k in fieldKeys)
                if (Request.Query.TryGetValue(k, out var fv) && fv.Count > 0)
                    filters.PriceField = fv[0];

            // Normalize min/max
            if (filters.MinPrice.HasValue && filters.MaxPrice.HasValue && filters.MinPrice > filters.MaxPrice)
            {
                var tmp = filters.MinPrice;
                filters.MinPrice = filters.MaxPrice;
                filters.MaxPrice = tmp;
            }
            if (filters.MinPrice.HasValue && !filters.MaxPrice.HasValue) filters.MaxPrice = filters.MinPrice;
            if (!filters.MinPrice.HasValue && filters.MaxPrice.HasValue) filters.MinPrice = filters.MaxPrice;

            // ----------------- SEARCH -----------------
            string? search = null;

            // Accept ?search=... or ?sT=...
            if (Request.Query.TryGetValue("search", out var searchVal) && !string.IsNullOrWhiteSpace(searchVal))
                search = searchVal.ToString();
            else if (Request.Query.TryGetValue("sT", out var sTVal) && !string.IsNullOrWhiteSpace(sTVal))
                search = sTVal.ToString();

            // Apply search if exists
            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.Trim();
                if (s.StartsWith("q", System.StringComparison.OrdinalIgnoreCase))
                    s = s.Substring(1).Trim();

                s = s.ToLower();
                query = query.Where(x =>
                    (!string.IsNullOrEmpty(x.PartNo) && x.PartNo.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.Name) && x.Name.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.Description) && x.Description.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(x.Supplier) && x.Supplier.ToLower().Contains(s))
                );
            }


            // Price filter
            var priceField = (filters?.PriceField ?? "SellPrice").Trim();
            if (filters?.MinPrice != null)
            {
                if (priceField.Equals("BuildCost", StringComparison.OrdinalIgnoreCase))
                    query = query.Where(x => x.BuildCost >= filters.MinPrice.Value);
                else
                    query = query.Where(x => x.SellPrice >= filters.MinPrice.Value);
            }
            if (filters?.MaxPrice != null)
            {
                if (priceField.Equals("BuildCost", StringComparison.OrdinalIgnoreCase))
                    query = query.Where(x => x.BuildCost <= filters.MaxPrice.Value);
                else
                    query = query.Where(x => x.SellPrice <= filters.MaxPrice.Value);
            }

            var components = GenerateComponentOverview(query);
            return new JsonResult(new { lists = components });
        }


        // ----------------- Filter Lists (Supplier / Price Ranges) -----------------
        [HttpGet("ComponentFilterLists")]
        public JsonResult ComponentFilterLists()
        {
            var businessId = GetCurrentBusinessId();

            var scoped = _context.Components
                .Where(r => r.IsActive == true && r.BusinessId == businessId);
            var supplierList = scoped
                .Where(x => !string.IsNullOrEmpty(x.Supplier))
                .Select(x => x.Supplier)
                .Distinct()
                .OrderBy(s => s)
                .Select(s => new { value = s, name = s })
                .ToList();

            decimal? buildMin = _context.Components.Min(x => (decimal?)x.BuildCost);
            decimal? buildMax = _context.Components.Max(x => (decimal?)x.BuildCost);
            decimal? sellMin = _context.Components.Min(x => (decimal?)x.SellPrice);
            decimal? sellMax = _context.Components.Max(x => (decimal?)x.SellPrice);

            if (!buildMin.HasValue) { buildMin = 0m; buildMax = 1000m; }
            if (!sellMin.HasValue) { sellMin = 0m; sellMax = 1000m; }
            if (buildMin == buildMax) buildMax = buildMin + 1m;
            if (sellMin == sellMax) sellMax = sellMin + 1m;

            var priceList = new List<object>
            {
                new { value = "BuildCost", name = "Build Cost", min = buildMin, max = buildMax },
                new { value = "SellPrice", name = "Sell Price", min = sellMin, max = sellMax }
            };

            var lists = new
            {
                supplierLists = supplierList,
                priceLists = priceList
            };

            return new JsonResult(new { lists = new List<object> { lists } });
        }

        // ----------------- Price Range Endpoint -----------------
        [HttpGet("PriceRange")]
        public JsonResult PriceRange([FromQuery] string field = "SellPrice")
        {
            var businessId = GetCurrentBusinessId();
            var scoped = _context.Components.Where(c => c.BusinessId == businessId);
            decimal? min = null, max = null;
            if (field?.Equals("BuildCost", StringComparison.OrdinalIgnoreCase) == true)
            {
                min = scoped.Min(x => (decimal?)x.BuildCost);
                max = scoped.Max(x => (decimal?)x.BuildCost);
            }
            else
            {
                min = scoped.Min(x => (decimal?)x.SellPrice);
                max = scoped.Max(x => (decimal?)x.SellPrice);
            }

            if (!min.HasValue) { min = 0m; max = 1000m; }
            if (min == max) max = min + 1m;

            return new JsonResult(new { min, max });
        }
        [HttpPost("Create")]
        public async Task<IActionResult> Create([FromForm] ComponentIndexModel model)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(new { success = false, errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage) });

                var businessId = GetCurrentBusinessId();

                var component = new Component
                {
                    Name = model.Name,
                    Description = model.Description,
                    BuildCost = model.BuildCost ?? 0m,
                    SellPrice = model.SellPrice ?? 0m,
                    Supplier = model.Supplier,
                    PartNo = model.PartNo,
                    IsActive = true,
                    BusinessId = businessId,
                    CreatedAt = DateTime.UtcNow // ✅ FIXED
                };

                _context.Components.Add(component);
                await _context.SaveChangesAsync();

                if (model.SelectedMaterialIds != null && model.SelectedMaterialIds.Any())
                {
                    foreach (var matId in model.SelectedMaterialIds)
                    {
                        var materialComponent = new MaterialComponent
                        {
                            ComponentId = component.ComponentId,
                            MaterialId = matId,
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow // ✅ FIXED
                        };
                        _context.MaterialComponents.Add(materialComponent);
                    }
                    await _context.SaveChangesAsync();
                }

                // Reload full component info including materials
                var savedComponent = await _context.Components.Where(r => r.IsActive == true && r.BusinessId == businessId)
                    .Include(x => x.MaterialComponents)
                    .ThenInclude(mc => mc.Material)
                    .Where(x => x.ComponentId == component.ComponentId)
                    .Select(x => new
                    {
                        x.ComponentId,
                        x.Name,
                        x.Description,
                        x.BuildCost,
                        x.SellPrice,
                        x.Supplier,
                        x.PartNo,
                        x.CreatedAt,
                        SelectedMaterialIds = x.MaterialComponents
                            .Where(mc => mc.IsActive)
                            .Select(mc => mc.MaterialId)
                            .ToList(),
                        MaterialNames = x.MaterialComponents
                            .Where(mc => mc.IsActive)
                            .Select(mc => mc.Material.Name)
                            .ToList()
                    })
                    .FirstOrDefaultAsync();

                return Ok(new { success = true, item = savedComponent });

            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = ex.Message,
                    inner = ex.InnerException?.Message,
                    stack = ex.StackTrace
                });
            }
        }



        // GET: api/Component/{id}
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetComponent(int id)
        {
            var businessId = GetCurrentBusinessId();
            var c = await _context.Components
                .Where(r => r.IsActive == true && r.BusinessId == businessId)
                .Include(x => x.MaterialComponents)
                .ThenInclude(mc => mc.Material)
                .Where(x => x.ComponentId == id)
                .Select(x => new
                {
                    x.ComponentId,
                    x.Name,
                    x.Description,
                    BuildCost = x.BuildCost,
                    SellPrice = x.SellPrice,
                    x.Supplier,
                    x.PartNo,
                    x.IsActive,
                    SelectedMaterialIds = x.MaterialComponents
                                            .Where(mc => mc.IsActive)
                                            .Select(mc => mc.MaterialId)
                                            .ToList()
    })
                .FirstOrDefaultAsync();

            if (c == null) return NotFound(new { success = false, message = "Component not found" });

            return new JsonResult(c);
            //return Ok(new { success = true, item = c });
        }

        // POST: api/Component/Update
        [HttpPost("Update")]
        public async Task<IActionResult> Update([FromForm] ComponentIndexModel model)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(new { success = false, errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage) });
                
                var businessId = GetCurrentBusinessId();

                var component = await _context.Components.Where(r => r.IsActive == true && r.BusinessId == businessId)
                    .Include(x => x.MaterialComponents)
                    .FirstOrDefaultAsync(x => x.ComponentId == model.ComponentId);

                if (component == null)
                    return NotFound(new { success = false, message = "Component not found" });

                // Update scalar properties
                component.Name = model.Name;
                component.Description = model.Description;
                component.BuildCost = model.BuildCost ?? 0m;
                component.SellPrice = model.SellPrice ?? 0m;
                component.Supplier = model.Supplier;
                component.PartNo = model.PartNo;
                //component.IsActive = model.IsActive; // if your model has IsActive
                //component.UpdatedAt = DateTime.UtcNow;

                // Update MaterialComponents:
                var newMatIds = (model.SelectedMaterialIds ?? new List<int>()).Distinct().ToList();

                // Existing active material components
                var existingMCs = component.MaterialComponents.ToList();

                // Remove (or mark inactive) MCs that are no longer selected
                foreach (var mc in existingMCs)
                {
                    if (!newMatIds.Contains(mc.MaterialId))
                    {
                        // Option A: physically remove
                        _context.MaterialComponents.Remove(mc);

                        // Option B (preferred if you want history): mark inactive:
                        // mc.IsActive = false;
                        // mc.UpdatedAt = DateTime.UtcNow;
                    }
                }

                // Add any new material components
                var existingIds = existingMCs.Select(x => x.MaterialId).ToHashSet();
                foreach (var id in newMatIds)
                {
                    if (!existingIds.Contains(id))
                    {
                        var newMc = new MaterialComponent
                        {
                            ComponentId = component.ComponentId,
                            MaterialId = id,
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow
                        };
                        _context.MaterialComponents.Add(newMc);
                    }
                }

                await _context.SaveChangesAsync();

                // Fetch updated data with materials
                var updatedComponent = await _context.Components.Where(r => r.IsActive == true && r.BusinessId == businessId)
                    .Include(x => x.MaterialComponents)
                    .ThenInclude(mc => mc.Material)
                    .Where(x => x.ComponentId == component.ComponentId)
                    .Select(x => new
                    {
                        x.ComponentId,
                        x.Name,
                        x.Description,
                        x.BuildCost,
                        x.SellPrice,
                        x.Supplier,
                        x.PartNo,
                        x.CreatedAt,
                        SelectedMaterialIds = x.MaterialComponents
                            .Where(mc => mc.IsActive)
                            .Select(mc => mc.MaterialId)
                            .ToList(),
                        MaterialNames = x.MaterialComponents
                            .Where(mc => mc.IsActive)
                            .Select(mc => mc.Material.Name)
                            .ToList()
                    })
                    .FirstOrDefaultAsync();

                return Ok(new { success = true, item = updatedComponent });

            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message, inner = ex.InnerException?.Message });
            }
        }

        [HttpDelete("DeleteComponent/{id}")]
        public async Task<IActionResult> DeleteComponent(int id)
        {
            var businessId = GetCurrentBusinessId();
            var entity = await _context.Components
                .FirstOrDefaultAsync(c => c.ComponentId == id && c.BusinessId == businessId);

            if (entity == null)
                return NotFound(new { success = false, message = "Component not found" });

            entity.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { success = true });
        }


        [HttpGet("IsComponentDependent/{id}")]
        public async Task<IActionResult> IsComponentDependent(int id)
        {
            var entity = await _context.QuestionOptions.Where(x => x.MaterialCompId == id && x.MatCompName == "Component").FirstOrDefaultAsync();

            if (entity != null)
                return Ok(new { success = true });

            return Ok(new { success = false });
        }
    }
}
