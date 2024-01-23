using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MetaPersonaApi.Migrations
{
    /// <inheritdoc />
    public partial class InitConfigsAdded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "17e08415-f36a-4e7b-b313-eea107cef450", "AQAAAAIAAYagAAAAEKvZzsktDx68MrOr4rkf/ewUSN+P8DweuZN3zHfItMf4+MS6UgzIWk5YcFkU6CSObA==" });

            migrationBuilder.InsertData(
                table: "configEntities",
                columns: new[] { "Id", "CreatedAt", "Creater", "CreaterId", "Key", "ModifiedAt", "Modifier", "ModifierId", "Value" },
                values: new object[,]
                {
                    { new Guid("53264ca4-0adb-47aa-8f27-20bea645636e"), null, null, null, "WalletAddress", null, null, null, "0x" },
                    { new Guid("8419af8a-bde9-496e-b8f9-76d90adbfaa4"), null, null, null, "WalletPrivateKey", null, null, null, "0x" },
                    { new Guid("927ed149-f4a1-4cd7-8fcb-d94084f9f1e3"), null, null, null, "ContractAddress", null, null, null, "0x" },
                    { new Guid("b3cbe892-2af8-42b6-97e2-5eecf7fa8e44"), null, null, null, "WalletPublicKey", null, null, null, "0x" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("53264ca4-0adb-47aa-8f27-20bea645636e"));

            migrationBuilder.DeleteData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("8419af8a-bde9-496e-b8f9-76d90adbfaa4"));

            migrationBuilder.DeleteData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("927ed149-f4a1-4cd7-8fcb-d94084f9f1e3"));

            migrationBuilder.DeleteData(
                table: "configEntities",
                keyColumn: "Id",
                keyValue: new Guid("b3cbe892-2af8-42b6-97e2-5eecf7fa8e44"));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: new Guid("8c748df8-6148-45f8-b286-f0a74078aeb0"),
                columns: new[] { "ConcurrencyStamp", "PasswordHash" },
                values: new object[] { "bf6021b8-0257-4041-be26-32e9cea8694d", "AQAAAAIAAYagAAAAEND7Y68eJrNJM/dUhQyjI6uRTXylFnWMgcXuOYHe04f8bL57sywWP1TXfSWzgClu8w==" });
        }
    }
}
