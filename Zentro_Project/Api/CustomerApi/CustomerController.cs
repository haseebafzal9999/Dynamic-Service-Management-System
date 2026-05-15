using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using zentro.library;
using zentro.Models;
using zentro.View_Model;

namespace zentro.Api.CustomerApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class CustomerController : ControllerBase
    {
        private readonly dbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CustomerController(dbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        [HttpGet]
        public async Task<List<CustomerIndexModel>> GetCustomers()
        {
            var businessId = GetCurrentBusinessId();
            return await _context.Customers
            .Where(c => c.BusinessId == businessId) // only customers for the logged user's business
            //.Where(c => (bool)c.IsActive) // only active customers
            .Select(c => new CustomerIndexModel
            {
                CustomerId = c.CustomerId,
                FirstName = c.FirstName,
                LastName = c.LastName,
                Email = c.Email,
                PhoneNumber = c.PhoneNumber,
                Address = c.Address,
                AppartmentSuite = c.AppartmentSuite,
                City = c.City,
                PostalCode = c.Postalcode,
                Country = c.Country,
                CreatedAt = c.CreatedAt,
                Id = c.CustomerId
            }).OrderByDescending(cr => cr.CreatedAt)
            .ToListAsync();

        }

        private int GetCurrentBusinessId()
        {
            var userId = _httpContextAccessor.HttpContext?.User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            return Common.GetUserBusinessId(_context, userId);
        }

        [HttpPost("Create")]
        public async Task<IActionResult> Create([FromForm] CustomerIndexModel model)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false });

            var createdById = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var businessId = GetCurrentBusinessId();


            var customer = new Customer
            {
                FirstName = model.FirstName,
                LastName = model.LastName,
                Email = model.Email,
                PhoneNumber = model.PhoneNumber,
                Address = model.Address,
                AppartmentSuite = model.AppartmentSuite,
                City = model.City,
                Postalcode = model.PostalCode,
                Country = model.Country,
                CreatedAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified),
                CreatedById = createdById,
                IsActive = true,
                IsDeleted = false,
                BusinessId = businessId

            };

            _context.Customers.Add(customer);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, item = customer });
        }

        [HttpGet("CountryList")]
        public IActionResult CountryList()
        {
            var countries = new List<string>
                                    {
                                        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Argentina",
                                        "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain",
                                        "Bangladesh", "Belarus", "Belgium", "Belize", "Benin", "Bhutan",
                                        "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei",
                                        "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada",
                                        "Chile", "China", "Colombia", "Costa Rica", "Croatia", "Cuba",
                                        "Cyprus", "Czech Republic", "Denmark", "Dominican Republic", "Ecuador",
                                        "Egypt", "El Salvador", "Estonia", "Ethiopia", "Fiji", "Finland",
                                        "France", "Germany", "Ghana", "Greece", "Guatemala", "Honduras",
                                        "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran",
                                        "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan",
                                        "Jordan", "Kazakhstan", "Kenya", "Kuwait", "Laos", "Latvia",
                                        "Lebanon", "Libya", "Liechtenstein", "Lithuania", "Luxembourg",
                                        "Madagascar", "Malaysia", "Maldives", "Mali", "Malta", "Mauritius",
                                        "Mexico", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique",
                                        "Myanmar", "Namibia", "Nepal", "Netherlands", "New Zealand", "Nigeria",
                                        "North Korea", "Norway", "Oman", "Pakistan", "Panama", "Paraguay",
                                        "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania",
                                        "Russia", "Rwanda", "Saudi Arabia", "Senegal", "Serbia", "Singapore",
                                        "Slovakia", "Slovenia", "South Africa", "South Korea", "Spain", "Sri Lanka",
                                        "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania",
                                        "Thailand", "Tunisia", "Turkey", "Uganda", "Ukraine", "United Arab Emirates",
                                        "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Venezuela",
                                        "Vietnam", "Yemen", "Zambia", "Zimbabwe"
                                    };

            return Ok(countries.OrderBy(c => c).ToList());
        }

        [HttpGet("FilterCustomerIndex")]
        public async Task<IActionResult> FilterCustomerIndex(
            [FromQuery] string? country,
            [FromQuery] string? city,
            [FromQuery] string? search,
            [FromQuery] string? status,
            [FromQuery(Name = "sT")] string? sT) // accept frontend's sT param too
        {
            

            if (string.IsNullOrWhiteSpace(search) && !string.IsNullOrWhiteSpace(sT))
            {
                search = sT;
            }
            var query = _context.Customers.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.Trim();
                if (s.StartsWith("q", System.StringComparison.OrdinalIgnoreCase))
                    s = s.Substring(1).Trim();

                s = s.ToLower();
                query = query.Where(t =>
                    (!string.IsNullOrEmpty(t.FirstName) && t.FirstName.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(t.LastName) && t.LastName.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(t.Email) && t.Email.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(t.PhoneNumber) && t.PhoneNumber.ToLower().Contains(s)) ||
                    (!string.IsNullOrEmpty(t.Country) && t.Country.ToLower().Contains(s))||
                    (!string.IsNullOrEmpty(t.City) && t.City.ToLower().Contains(s)) ||
                    ((t.FirstName ?? "") + " " + (t.LastName ?? "")).ToLower().Contains(s)
                );
            }


            // Build statusList robustly: handle multiple status query values, or comma-separated list
            var statusList = new List<string>();

            // 1) If client sent multiple values like ?status=active&status=inactive
            if (Request.Query.TryGetValue("status", out var statusValues) && statusValues.Count > 0)
            {
                foreach (var v in statusValues)
                    if (!string.IsNullOrWhiteSpace(v))
                        statusList.AddRange(v.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries));
            }
            else if (!string.IsNullOrWhiteSpace(status)) // 2) single value (possibly comma-separated)
            {
                statusList.AddRange(status.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries));
            }

            // Normalize and distinct
            statusList = statusList.Select(s => s.Trim().ToLower()).Distinct().ToList();

           
            if (statusList.Count == 1)
            {
                var st = statusList[0];
                if (st == "active")
                    query = query.Where(x => x.IsActive == true);
                else if (st == "inactive")
                    query = query.Where(x => x.IsActive == false);
                // else unknown -> no filter
            }
            // if 0 -> no status filter; if 2+ and includes both -> no status filter

            if (!string.IsNullOrWhiteSpace(country))
                query = query.Where(x => x.Country == country);

            if (!string.IsNullOrWhiteSpace(city))
                query = query.Where(x => x.City == city);

            var result = await query
                .Select(c => new CustomerIndexModel
                {
                    CustomerId = c.CustomerId,
                    FirstName = c.FirstName,
                    LastName = c.LastName,
                    Email = c.Email,
                    PhoneNumber = c.PhoneNumber,
                    Address = c.Address,
                    AppartmentSuite = c.AppartmentSuite,
                    City = c.City,
                    PostalCode = c.Postalcode,
                    Country = c.Country,
                    IsActive = (bool?)c.IsActive ?? false,
                    Id=c.CustomerId
                })
                .ToListAsync();

            return Ok(new { lists = result });
        }

        [HttpGet("CustomerFilterLists")]
        public IActionResult CustomerFilterLists()
        {
            var countryList = _context.Customers
                .Where(x => !string.IsNullOrEmpty(x.Country))
                .Select(x => x.Country)
                .Distinct()
                .OrderBy(x => x)
                .Select(x => new { value = x, name = x })
                .ToList();

            var cityList = _context.Customers
                .Where(x => !string.IsNullOrEmpty(x.City))
                .Select(x => x.City)
                .Distinct()
                .OrderBy(x => x)
                .Select(x => new { value = x, name = x })
                .ToList();

            var statusLists = new List<object>
    {
        new { value = "active", name = "Active" },
        new { value = "inactive", name = "Inactive" }
    };

            // Wrap everything inside a `lists` array
            var result = new
            {
                lists = new[] {
            new {
                countryLists = countryList,
                cityLists = cityList,
                statusLists = statusLists
            }
        }
            };

            return Ok(result);
        }



        // GET api/Customer/{id}
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetCustomer(int id)
        {
            var c = await _context.Customers
                .Where(x => x.CustomerId == id)
                .Select(x => new CustomerIndexModel
                {
                    CustomerId = x.CustomerId,
                    FirstName = x.FirstName,
                    LastName = x.LastName,
                    Email = x.Email,
                    PhoneNumber = x.PhoneNumber,
                    Address = x.Address,
                    AppartmentSuite = x.AppartmentSuite,
                    City = x.City,
                    PostalCode = x.Postalcode,
                    Country = x.Country
                })
                .FirstOrDefaultAsync();

            if (c == null) return NotFound(new { success = false });

            return Ok(c);
        }

        // POST api/Customer/Update
        [HttpPost("Update")]
        public async Task<IActionResult> Update([FromForm] CustomerIndexModel model)
        {
            if (model == null || model.CustomerId == 0)
                return BadRequest(new { success = false });

            var customer = await _context.Customers.FindAsync(model.CustomerId);
            if (customer == null)
                return NotFound(new { success = false });

            // Update allowed fields
            customer.FirstName = model.FirstName;
            customer.LastName = model.LastName;
            customer.Email = model.Email;
            customer.PhoneNumber = model.PhoneNumber;
            customer.Address = model.Address;
            customer.AppartmentSuite = model.AppartmentSuite;
            customer.City = model.City;
            customer.Postalcode = model.PostalCode;
            customer.Country = model.Country;
            //customer.UpdatedAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);

            _context.Customers.Update(customer);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, item = customer });
        }

        [HttpDelete("DeleteCustomer/{id}")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            var entity = await _context.Customers.FindAsync(id);

            if (entity == null)
                return NotFound(new { success = false, message = "Customer not found" });

            entity.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { success = true });
        }

    }
}