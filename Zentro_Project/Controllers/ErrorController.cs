using Microsoft.AspNetCore.Mvc;

namespace zentro.Controllers
{
    [Route("Error")]
    public class ErrorController : Controller
    {
        [Route("404")]
        public IActionResult NotFoundError()
        {
            return View("NotFound");  // Render the custom 404 page
        }
    }
}
