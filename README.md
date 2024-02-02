## Instructions
This project could be run by  `dotnet` or by `docker`, 
### Using dotnet
You need to [install dotnet](https://dotnet.microsoft.com/en-us/download) sdk first, in ubuntu you could install it by following script and then add the dotnet to path
```shell
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest
```
After installing `dotnet`, you could run the project using `dotnet run`, the current implementation makes calls to metapersona.fun website, you can edit it to your liking.
### Docker
docker compose up -d
```
