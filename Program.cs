
using MetaPersonaApi.Data;
using MetaPersonaApi.Identity;
using MetaPersonaApi.Services;
using MetaPersonaApi.Endpoints.Auth;
using MetaPersonaApi.Endpoints.Administration;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using MetaPersonaApi.Data.Contracts;
using MetaPersonaApi.Data.Repositories;
using Microsoft.AspNetCore.Authorization;

namespace MetaPersonaApi;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        var conn = builder.Configuration.GetConnectionString("DefaultConnection");
        
        // Add services to the container.
        builder.Services.AddDbContext<MetaPersonaDbContext>(options =>
        {
            options.UseNpgsql(conn);
        });
        

        builder.Services.AddIdentityCore<MetaPersonaIdentityUser>()
        .AddRoles<IdentityRole<Guid>>()
        .AddEntityFrameworkStores<MetaPersonaDbContext>();

        builder.Services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        }).AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new()
            {
                ValidateIssuer = true,
                ValidIssuer = builder.Configuration["JwtSettings:Issuer"],
                ValidateAudience = true,
                ValidAudience = builder.Configuration["JwtSettings:Audience"],
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JKEY"]))
            };
        });

        builder.Services.AddAuthorization(options =>
        {
            options.FallbackPolicy = new AuthorizationPolicyBuilder()
            .AddAuthenticationSchemes(JwtBearerDefaults.AuthenticationScheme)
            .RequireAuthenticatedUser()
            .Build();
        });

        builder.Services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
        builder.Services.AddScoped<IAuthManager, AuthManager>();
        // Repositories
        builder.Services.AddScoped<IConfigEntityRepository, ConfigEntityRepository>();

        // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();

        if (builder.Configuration["ISDUCKER"] is string isDucker && string.Equals(isDucker, "true", StringComparison.CurrentCultureIgnoreCase))
        {
            builder.Services.AddDataProtection().PersistKeysToFileSystem(new DirectoryInfo("/root/.aspnet/DataProtection-Keys"));
        }

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        //if (app.Environment.IsDevelopment())
        //{
        app.UseSwagger();
        app.UseSwaggerUI();
        //}

        app.UseAuthentication();
        app.UseAuthorization();

        app.UseHttpsRedirection();


        // Map API Endpoints
        app.MapAuthenticationEndpoints();
        app.MapAdministrationEndpoints();

        app.Run();
    }
}

