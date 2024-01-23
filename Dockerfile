FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

ENV ISDUCKER=True

VOLUME /root/.aspnet/DataProtection-Keys

COPY *.csproj ./
RUN dotnet restore


RUN export PATH="$PATH:/root/.dotnet/tools"

RUN dotnet tool install --global dotnet-ef

COPY . ./
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

ENTRYPOINT [ "dotnet", "MetaPersonaApi.dll" ]