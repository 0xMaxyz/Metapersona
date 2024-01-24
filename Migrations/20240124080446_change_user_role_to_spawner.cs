using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MetaPersonaApi.Migrations
{
    /// <inheritdoc />
    public partial class change_user_role_to_spawner : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb2"),
                columns: new[] { "Name", "NormalizedName" },
                values: new object[] { "Spawner", "SPAWNER" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "02265ea8-5c04-47e1-9893-bf0564411aec", "AQAAAAIAAYagAAAAEMy4iunFY1P6FOoKfykrG+dZIKPpOwq0aQ4xiaHWG6kPEhkqZWuM8+k/+N6t1n/ooA==" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb2"),
                columns: new[] { "Name", "NormalizedName" },
                values: new object[] { "User", "USER" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "918b6c82-f68a-4ea8-be50-4dcb4ef3f095", "AQAAAAIAAYagAAAAEPV2mSfIkeDNAZ1Y+PGRI33RrF8q/JVsk2pS/fw8UNde5oKPPCECU5hXo07z2zo1WQ==" });
        }
    }
}
