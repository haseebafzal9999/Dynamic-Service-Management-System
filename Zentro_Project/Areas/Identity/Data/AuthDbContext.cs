using zentro.Areas.Identity.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System.Reflection.Emit;

namespace zentro.Data;

public class AuthDbContext : IdentityDbContext<ApplicationUser>
{
    public AuthDbContext(DbContextOptions<AuthDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        // Customize the ASP.NET Identity model and override the defaults if needed.
        // For example, you can rename the ASP.NET Identity table names and more.
        // Add your customizations after calling base.OnModelCreating(builder);

        // Map Identity tables to 'security' schema
        builder.Entity<ApplicationUser>(entity =>
        {
            entity.ToTable("users", "security");  // Mapping Users to 'security' schema
        });

        builder.Entity<IdentityRole>(entity =>
        {
            entity.ToTable("roles", "security");  // Mapping Roles to 'security' schema
        });

        builder.Entity<IdentityUserRole<string>>(entity =>
        {
            entity.ToTable("user_roles", "security");  // Mapping UserRoles to 'security' schema
        });

        builder.Entity<IdentityUserClaim<string>>(entity =>
        {
            entity.ToTable("user_claims", "security");  // Mapping UserClaims to 'security' schema
        });

        builder.Entity<IdentityUserLogin<string>>(entity =>
        {
            entity.ToTable("user_logins", "security");  // Mapping UserLogins to 'security' schema
        });

        builder.Entity<IdentityRoleClaim<string>>(entity =>
        {
            entity.ToTable("roles_claims", "security");  // Mapping RoleClaims to 'security' schema
        });

        builder.Entity<IdentityUserToken<string>>(entity =>
        {
            entity.ToTable("user_tokens", "security");  // Mapping UserTokens to 'security' schema
        });
    }
}
