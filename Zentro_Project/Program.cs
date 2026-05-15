using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using zentro.Services.TemplateDocument;
using zentro.Areas.Identity.Data;
using zentro.Data;
using zentro.IFrames;
using zentro.Models;
using zentro.Quote;
using zentro.Quote;
using zentro.Services;
using zentro.Services.Authorization;
using zentro.Services.Group;
using zentro.Services.Iframes;
using zentro.Services.Metafield;
using zentro.Services.Questions;
using zentro.Services.Questions.zentro.Services.Questions;
//using zentro.Api.TemplateServicesApi;
using zentro.Services.TemplatesVersion;
using zentro.TemplateItems;
using zentro.Templates;
using AuthorizationMiddleware = zentro.Services.Authorization.AuthorizationMiddleware;
//using zentro.Quote;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("AuthDbContextConnection") ?? throw new InvalidOperationException("Connection string 'AuthDbContextConnection' not found.");

builder.Services.AddDbContext<AuthDbContext>(options =>
    options.UseNpgsql(connectionString));

builder.Services.AddDbContext<dbContext>(options =>
            options.UseNpgsql(connectionString));


builder.Services.AddDbContext<AuthDbContext>(options => options.UseSqlServer(connectionString));

builder.Services.AddDefaultIdentity<ApplicationUser>(options => options.SignIn.RequireConfirmedAccount = false).AddEntityFrameworkStores<AuthDbContext>().AddDefaultTokenProviders();

builder.Services.AddScoped<IQuoteService, QuoteService>();
builder.Services.AddScoped<ITemplateItemsService, TemplateItemsService>();
builder.Services.AddScoped<ITemplateService, TemplateService>();
builder.Services.AddScoped<IIFrameService, IFrameService>();

builder.Services.AddScoped<IGroupService, GroupService>();
builder.Services.AddScoped<IQuestionService, QuestionService>();
builder.Services.AddScoped<ITemplateVersionCheckService, TemplateVersionCheckService>();
builder.Services.AddScoped<IMetafieldService, MetafieldService>();
builder.Services.AddScoped<ITemplateDocumentService, TemplateDocumentService>();

builder.Services.Configure<ApiBehaviorOptions>(options =>
{
    options.SuppressModelStateInvalidFilter = true;
});

builder.Services.AddHttpContextAccessor();
// Add CORS services
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowLocalhost", policy =>
    {
        policy.WithOrigins("http://127.0.0.1:5500")  // Allow specific frontend origin
              .AllowAnyHeader()                       // Allows any headers
              .AllowAnyMethod()                       // Allows any methods (GET, POST, etc.)
              .AllowCredentials();                    // Allow credentials (cookies, etc.)
    });
});

// Add services to the container.
builder.Services.AddControllersWithViews().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
}); ;
builder.Services.AddRazorPages();
builder.Services.AddHttpClient();
builder.Services.AddScoped<TemplateService>();



var app = builder.Build();

// Enable CORS middleware
app.UseCors("AllowLocalhost");


// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseMiddleware<AuthorizationMiddleware>();

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();


app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.MapControllerRoute(
    name: "Quotes",
    pattern: "page/quotes", 
    defaults: new { controller = "Home", action = "Quotes" } 
);

app.MapControllerRoute(
    name: "QuoteDetails",
    pattern: "page/quote/{id:int}",
    defaults: new { controller = "Home", action = "QuoteDetails" }
);

app.MapControllerRoute(
    name: "Customers",
    pattern: "page/customers",
    defaults: new { controller = "Home", action = "Customer" }
);

app.MapControllerRoute(
    name: "Components",
    pattern: "page/components", 
    defaults: new { controller = "Home", action = "Components" } 
);

app.MapControllerRoute(
    name: "Materials",
    pattern: "page/materials",
    defaults: new { controller = "Home", action = "Materials" }
);

app.MapControllerRoute(
    name: "Templates",
    pattern: "page/templates",
    defaults: new { controller = "Home", action = "Templates" }
);

app.MapControllerRoute(
    name: "TemplateDetail",
    pattern: "page/template/{id:int}",
    defaults: new { controller = "Home", action = "TemplateDetail" }
);

app.MapControllerRoute(
    name: "TemplatePreview",
    pattern: "page/template/preview/{id:int}",
    //pattern: "page/template/preview/{templateVersionId:int}",
    defaults: new { controller = "Home", action = "TemplatePreview" }
);

app.MapControllerRoute(
    name: "TemplateDefault",
    pattern: "page/template/default",
    defaults: new { controller = "Home", action = "TemplateDefault" }
);

app.MapControllerRoute(
    name: "CreateQuote",
    pattern: "page/Quote/create",
    defaults: new { controller = "Home", action = "CreateQuote" }
);

app.MapRazorPages();

app.Run();
