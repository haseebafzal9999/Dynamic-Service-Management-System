using zentro.Areas.Identity.Data;
using zentro.Controllers;
using zentro.Models;
using zentro.View_Model;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace zentro.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class CommonController : Controller
    {
        private readonly IWebHostEnvironment _env;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly dbContext _context;

        public CommonController(IWebHostEnvironment env, UserManager<ApplicationUser> userManager, dbContext context)
        {
            _env = env;
            _userManager = userManager;
            _context = context;
        }

        [HttpGet("MenuItems")]
        public JsonResult GetMenuItems()
        {
            var permittedMenuIds = HttpContext.Items["PermittedMenuIds"] as List<int>; 
            List<MenuList> menuList = new List<MenuList>();
 
            List<Menu> menuFromDb = _context.Menus.OrderBy(m => m.ParentId).ThenBy(m => m.SequenceNumber).Where(m => permittedMenuIds.Contains(m.MenuId)).ToList();

            List<MenuList> menuItem = menuFromDb.Where(x => x.ParentId == 0).Select(x => new MenuList()
            {
                optionName = x.Name,
                optionSVG = GetSvgFile(x.ImageRef),
                optionLink = x.Link,
                children = menuFromDb.Where(y => x.MenuId == y.ParentId)
                .Select(y => new ChildrenValues()
                {
                    Name = y.Name,
                    Link = y.Link,
                }).ToList(),
                pageName = x.Name,
                position = x.LinkType
            }).ToList();



            menuList.AddRange(menuItem);
            return new JsonResult(
                new
                {
                    menu = menuList,
                    permissions = 1
                });
        }

        public string GetSvgFile(string filePath)
        {
            if (string.IsNullOrWhiteSpace(filePath))
                return string.Empty;

            var svgFilePath = Path.Combine(
                _env.WebRootPath,
                filePath.TrimStart('/', '\\')
            );

            if (!System.IO.File.Exists(svgFilePath))
                return string.Empty;

            return System.IO.File.ReadAllText(svgFilePath);
        }

        public IActionResult Index()
        {
            return View();
        }
    }
}
