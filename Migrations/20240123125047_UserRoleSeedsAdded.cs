using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MetaPersonaApi.Migrations
{
    /// <inheritdoc />
    public partial class UserRoleSeedsAdded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { new Guid("8c748df8-6148-45f8-b286-f0a74078aeb1"), new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0") });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "918b6c82-f68a-4ea8-be50-4dcb4ef3f095", "AQAAAAIAAYagAAAAEPV2mSfIkeDNAZ1Y+PGRI33RrF8q/JVsk2pS/fw8UNde5oKPPCECU5hXo07z2zo1WQ==" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { new Guid("8c748df8-6148-45f8-b286-f0a74078aeb1"), new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0") });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "3f778b8e-bf98-4a06-8516-12c04453155b", "AQAAAAIAAYagAAAAEADfgzNXL03+/mTvK5TjEBQBKR17nKN08Xk2Ea8gR99brmOtrNuJ4fFOTfuwl1Ts8Q==" });
        }
    }
}
