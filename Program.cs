
using MetaPersonaApi.Data;
using MetaPersonaApi.Identity;
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
using MetaPersonaApi.Services.Authentication;
using MetaPersonaApi.Services.MetaPersona;
using MetaPersonaApi.Endpoints.MetaPersona;

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
            options.AddPolicy("Admin", options => options.RequireAuthenticatedUser().RequireRole("Administrator").Build());

            options.FallbackPolicy = new AuthorizationPolicyBuilder()
            .AddAuthenticationSchemes(JwtBearerDefaults.AuthenticationScheme)
            .RequireAuthenticatedUser()
            .Build();
        });
        builder.Services.AddAutoMapper(typeof(Mappings.Mappings));
        builder.Services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
        builder.Services.AddScoped<IAuthManager, AuthManager>();
        builder.Services.AddScoped<IMetaPersonaManager, MetaPersonaManager>();

        // Repositories
        builder.Services.AddScoped<IConfigEntityRepository, ConfigEntityRepository>();

        // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();

        if (builder.Configuration["ISDUCKER"] is string isDucker && string.Equals(isDucker, "true", StringComparison.CurrentCultureIgnoreCase))
        {
            builder.Services.AddDataProtection().PersistKeysToFileSystem(new DirectoryInfo("/root/.aspnet/DataProtection-Keys"));
        }

        builder.Services.AddCors(options =>
        {
            options.AddDefaultPolicy(policy =>
            {
                // Todo: Add these to env vars
                policy.WithOrigins("https://localhost:7000", "http://localhost:7000", "https://metapersona.fun", "https://www.metapersona.fun", "http://192.168.0.0/24", "http://172.19.0.0/12")
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials();
            });
            options.AddPolicy(Constants.AllowAnyOrigin, policy =>
            {
                policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
            });
        });

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseCors();

        app.UseAuthentication();
        app.UseAuthorization();

        app.UseHttpsRedirection();


        // Map API Endpoints
        app.MapAuthenticationEndpoints();
        app.MapAdministrationEndpoints();
        app.MapMetaPersonaEndpoints();

        app.Run();
    }
}
