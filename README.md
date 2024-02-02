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
You need to clone this project and then add the address of that directory to `docker-compose.yml` file in webapi project ([here](https://github.com/MetaPersona/MetaPersonaApi/blob/1dfbc8a9d6a38bf6932e12dce1b7a32a32cd6f8a/docker-compose.yml#L9)), you may run the project by invoking following command and then invoke the same command in webapi, but updating the webapi docker file is easier.
docker compose up -d
```
