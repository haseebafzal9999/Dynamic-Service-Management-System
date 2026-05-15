using zentro.Areas.Identity.Data;
using zentro.Models;
using zentro.View_Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Antiforgery;

namespace zentro.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserAuthController : Controller
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly dbContext _context;

        public UserAuthController(dbContext context, SignInManager<ApplicationUser> signInManager, UserManager<ApplicationUser> userManager)
        {
            _signInManager = signInManager;
            _userManager = userManager;
            _context = context;
        }


        private async Task<JsonResult> VerifyUserAsync(LoginModel loginModel)
        {
            if (!ModelState.IsValid)
            {
                return new JsonResult(new { status = "Fail", message = "Invalid input." });
            }

            try
            {
                var result = await _signInManager.PasswordSignInAsync(loginModel.Email, loginModel.Password, false, false);

                return new JsonResult(new
                {
                    status = result.Succeeded ? "Pass" : "Fail"
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);

                return new JsonResult(new
                {
                    status = "Error",
                    message = "An error occurred. Please try again later."
                })
                {
                    StatusCode = 500
                };
            }
        }


        [AllowAnonymous]
        [HttpPost("app/login")]
        public async Task<JsonResult> AppLogin([FromBody] LoginModel loginModel)
        {
            return await VerifyUserAsync(loginModel);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        [ValidateAntiForgeryToken]
        public async Task<JsonResult> Login(LoginModel loginModel)
        {
            return await VerifyUserAsync(loginModel);
        }



        [AllowAnonymous]
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await _signInManager.SignOutAsync();

            // Return a simple success response
            return Ok(new { message = "Logged out successfully" });
        }

        public IActionResult Index()
        {
            return View();
        }
    }
}
