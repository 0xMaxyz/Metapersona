using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MetaPersonaApi.Migrations
{
    /// <inheritdoc />
    public partial class AddNormalizedKeyandValueToConfigEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "NormalizedKey",
                table: "configEntities",
                type: "character varying(256)",
                maxLength: 256,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "NormalizedValue",
                table: "configEntities",
                type: "character varying(2048)",
                maxLength: 2048,
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "3f778b8e-bf98-4a06-8516-12c04453155b", "AQAAAAIAAYagAAAAEADfgzNXL03+/mTvK5TjEBQBKR17nKN08Xk2Ea8gR99brmOtrNuJ4fFOTfuwl1Ts8Q==" });

            migrationBuilder.UpdateData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("53264ca4-0adb-47aa-8f27-20bea645636e"),
                columns: new[] { "NormalizedKey", "NormalizedValue" },
                values: new object[] { "WALLETADDRESS", "0X" });

            migrationBuilder.UpdateData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("8419af8a-bde9-496e-b8f9-76d90adbfaa4"),
                columns: new[] { "NormalizedKey", "NormalizedValue" },
                values: new object[] { "WALLETPRIVATEKEY", "0X" });

            migrationBuilder.UpdateData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("927ed149-f4a1-4cd7-8fcb-d94084f9f1e3"),
                columns: new[] { "NormalizedKey", "NormalizedValue" },
                values: new object[] { "CONTRACTADDRESS", "0X" });

            migrationBuilder.UpdateData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("b3cbe892-2af8-42b6-97e2-5eecf7fa8e44"),
                columns: new[] { "NormalizedKey", "NormalizedValue" },
                values: new object[] { "WALLETPUBLICKEY", "0X" });

            migrationBuilder.CreateIndex(
                name: "IX_configEntities_NormalizedKey",
                table: "configEntities",
                column: "NormalizedKey",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_configEntities_NormalizedKey",
                table: "configEntities");

            migrationBuilder.DropColumn(
                name: "NormalizedKey",
                table: "configEntities");

            migrationBuilder.DropColumn(
                name: "NormalizedValue",
                table: "configEntities");

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "17e08415-f36a-4e7b-b313-eea107cef450", "AQAAAAIAAYagAAAAEKvZzsktDx68MrOr4rkf/ewUSN+P8DweuZN3zHfItMf4+MS6UgzIWk5YcFkU6CSObA==" });
        }
    }
}
