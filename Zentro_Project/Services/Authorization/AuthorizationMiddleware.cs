using zentro.Models;
using zentro.library;
using Microsoft.EntityFrameworkCore;
using System.Configuration;
using System.Security.Claims;
using Microsoft.Identity.Client;

namespace zentro.Services.Authorization
{
    public class AuthorizationMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly string menuEndpoint;
        private List<string> publicEndpoints;

        public AuthorizationMiddleware(RequestDelegate next, IConfiguration config)
        {
            _next = next;
            menuEndpoint = config["Endpoints:menu"];
            publicEndpoints = config.GetSection("Endpoints:public").Get<List<string>>();
        }

        public async Task Invoke(HttpContext context, dbContext dbContext)
        {
            string requestPath = context.Request.Path;

            var user = context.User;

            if (user?.Identity != null && user.Identity.IsAuthenticated) //user must be logged in to access apis
            {
                var userIdString = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (userIdString != null)
                {
                    //Check menu access
                    bool isMenuRequest = requestPath.Equals(menuEndpoint);

                    if (isMenuRequest)
                    {
                        List<int> menuPermissions = await GetMenuPermissions(userIdString, dbContext);

                        context.Items["PermittedMenuIds"] = menuPermissions;    //passes menu ids to GetMenuItems()
                    }
                    else
                    {
                        try
                        {

                            // Check permissions

                            // Simplify the request path
                            string simplifiedPath = requestPath;
                            string[] parts = simplifiedPath.Split('/');

                            if (parts.Length > 2)
                            {
                                simplifiedPath = $"/{parts[1]}/{parts[2]}".ToLower();
                            }

                            var userId = Common.GetUserId(dbContext, userIdString);

                            // Get group IDs the user is a member of
                            var userGroupIds = await dbContext.SecurityGroupMembers
                                .Where(m => m.UserId == userId)
                                .Select(m => m.SecurityGroupId)
                                .ToListAsync();


                            // Get names of those groups
                            var userGroupNames = await dbContext.SecurityGroups
                                .Where(g => userGroupIds.Contains(g.SecurityGroupId))
                                .Select(g => g.SecurityGroupName)
                                .ToListAsync();

                            // If the user is in 'Admin' group, allow full access
                            if (userGroupNames.Any(name => name.Equals("Admin", StringComparison.OrdinalIgnoreCase)))
                            {
                                await _next(context);
                                return;
                            }

                            // Otherwise, check secured endpoints
                            List<string> secureEndpoints = await dbContext.SecurityGroups
                                .Select(sg => sg.ApiPath.ToLower())
                                .ToListAsync();

                            if (secureEndpoints.Contains(simplifiedPath))
                            {
                                List<string> userPermissions = await GetApiPermissions(userIdString, dbContext);

                                if (!userPermissions.Contains(simplifiedPath))
                                {
                                    context.Response.StatusCode = StatusCodes.Status403Forbidden;
                                    return;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // Optional: Log the exception (e.g., to console, file, or a logging framework)
                            Console.Error.WriteLine($"[PermissionMiddleware] Error: {ex.Message}");

                            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                            await context.Response.WriteAsync("An unexpected error occurred while checking permissions.");
                        }

                    }

                }
            }

            await _next(context);
        }

        public async Task<List<int>> GetMenuPermissions(string stringUserId, dbContext context)
        {
            int userId = Common.GetUserId(context, stringUserId);

            //Check which security groups user is in
            List<int> userSecurityGroups = await context.SecurityGroupMembers
                .Where(x => x.UserId == userId)
                .Select(x => x.SecurityGroupId)
                .ToListAsync();

            //Check what menu access that group has
            List<int> menuAccess = await context.MenuAccesses
                .Where(x => userSecurityGroups.Contains(x.SecurityGroupId))
                .Select(x => x.MenuId)
                .Distinct()
                .ToListAsync();

            return menuAccess;
        }

        public async Task<List<string>> GetApiPermissions(string stringUserId, dbContext context)
        {
            int userId = Common.GetUserId(context, stringUserId);

            //Check which security groups user is in
            List<int> userSecurityGroups = await context.SecurityGroupMembers
                .Where(x => x.UserId == userId)
                .Select(x => x.SecurityGroupId)
                .ToListAsync();

            List<string> permissions = await context.SecurityGroups
                .Where(x => userSecurityGroups.Contains(x.SecurityGroupId) || (x.ParentId != null && userSecurityGroups.Contains(x.ParentId)))
                .Select(x => x.ApiPath.ToLower())
                .Distinct()
                .ToListAsync();

            return permissions;
        }
    }
}
