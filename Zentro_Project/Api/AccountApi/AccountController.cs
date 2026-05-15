using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Mvc;
using zentro.Areas.Identity.Data;
using zentro.Models;
using zentro.View_Model;

namespace zentro.Api.AccountApi
{
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerBase
    {
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IUserStore<ApplicationUser> _userStore;
        private readonly IUserEmailStore<ApplicationUser> _emailStore;
        private readonly IEmailSender _emailSender;
        private dbContext _context;

        public AccountController(UserManager<ApplicationUser> userManager,
            IUserStore<ApplicationUser> userStore,
            IEmailSender emailSender,
            SignInManager<ApplicationUser> signInManager,
            dbContext context
            )
        {
            _userManager = userManager;
            _userStore = userStore;
            _emailStore = GetEmailStore();
            _signInManager = signInManager;
            _emailSender = emailSender;
            _context = context;
            //  _roleManager = roleManager;
        }


        [HttpPost("OnPostAsync")]
        [Consumes("application/x-www-form-urlencoded")]
        public async Task<IActionResult> OnPostAsync([FromForm] RegisterVM Input, string? returnUrl = null)
        {
            returnUrl ??= Url.Content("~/");
            if (ModelState.IsValid)
            {
                var user = CreateUser();

                await _userStore.SetUserNameAsync(user, Input.Email, CancellationToken.None);

                user.FirstName = Input.FirstName;
                user.LastName = Input.LastName;
                //user.Address = "N/A";
                user.PhoneNumber = Input.PhoneNumber;

                await _userStore.SetUserNameAsync(user, Input.Email, CancellationToken.None);
                await _emailStore.SetEmailAsync(user, Input.Email, CancellationToken.None);
                var result = await _userManager.CreateAsync(user, Input.Password);

                if (result.Succeeded)
                {
                    //await _userManager.AddToRoleAsync(user, RolesSD.CUSTOMER);

                    var userId = await _userManager.GetUserIdAsync(user);

                    if (userId != null)
                    {
                        int? businessId = null;

                        if (!string.IsNullOrWhiteSpace(Input.token))
                        {
                            const int keyPartLength = 32;

                            // Input.token = token + keyPart (per IFrameService)
                            if (Input.token.Length > keyPartLength)
                            {
                                var keyPart = Input.token[^keyPartLength..];

                                var iframe = _context.Iframes
                                    .FirstOrDefault(i => i.IsActive
                                        && i.Full_key != null
                                        && i.Full_key.EndsWith(keyPart));

                                businessId = iframe?.BusinessId;

                                //// Validate FK exists in Businesses table

                                //var candidateBusinessId = iframe?.BusinessId;

                                //if (candidateBusinessId.HasValue)
                                //{
                                //    var exists = _context.Businesses.Any(b => b.BusinessId == candidateBusinessId.Value);
                                //    businessId = exists ? candidateBusinessId : null;
                                //}
                            }
                        }

                        var customer = new Customer()
                        {
                            FirstName = Input.FirstName,
                            LastName = Input.LastName,
                            Email = Input.Email,
                            PhoneNumber = Input.PhoneNumber,
                            UserId = userId,
                            BusinessId = businessId
                        };

                        _context.Customers.Add(customer);
                        _context.SaveChanges();
                    }
                    
                    //await _signInManager.SignInAsync(user, isPersistent: false);
                    return RedirectToAction("TemplateDefault", "Home", new { token = Input.token });
                }
                foreach (var error in result.Errors)
                {
                    ModelState.AddModelError(string.Empty, error.Description);
                }
            }

            return RedirectToAction("TemplateDefault", "Home", new { token = Input.token });
        }

        private ApplicationUser CreateUser()
        {
            try
            {
                return Activator.CreateInstance<ApplicationUser>();
            }
            catch
            {
                throw new InvalidOperationException($"Can't create an instance of '{nameof(IdentityUser)}'. " +
                    $"Ensure that '{nameof(IdentityUser)}' is not an abstract class and has a parameterless constructor, or alternatively " +
                    $"override the register page in /Areas/Identity/Pages/Account/Register.cshtml");
            }
        }

        [HttpPost("SignInAsync")]
        [Consumes("application/x-www-form-urlencoded")]
        public async Task<IActionResult> SignInAsync([FromForm] SignInVM Input, string? returnUrl = null)
        {

            if (ModelState.IsValid)
            {
                // This doesn't count login failures towards account lockout
                // To enable password failures to trigger account lockout, set lockoutOnFailure: true
                var result = await _signInManager.PasswordSignInAsync(Input.Email, Input.Password, false, lockoutOnFailure: false);
                if (result.Succeeded)
                {
                    return RedirectToAction("TemplateDefault", "Home", new { token = Input.token });
                }

            }

            return RedirectToAction("TemplateDefault", "Home", new { token = Input.token });
        }


        private IUserEmailStore<ApplicationUser> GetEmailStore()
        {
            if (!_userManager.SupportsUserEmail)
            {
                throw new NotSupportedException("The default UI requires a user store with email support.");
            }
            return (IUserEmailStore<ApplicationUser>)_userStore;
        }

    }
}
