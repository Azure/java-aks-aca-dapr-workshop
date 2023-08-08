You have the choice between running the workshop on your local machine, in GitHub Codespaces or in a Development Containers.

[![Open in GitHub Codespaces](https://img.shields.io/badge/Github_Codespaces-Open-black?style=for-the-badge&logo=github
)](https://codespaces.new/Azure/java-aks-aca-dapr-workshop)
[![Open in Remote - Dev Containers](https://img.shields.io/badge/Dev_Containers-Open-blue?style=for-the-badge&logo=visualstudiocode
)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/Azure/java-aks-aca-dapr-workshop)

### Local machine

Make sure you have the following prerequisites installed on your machine:

- [Git](https://git-scm.com/)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- A code editor or IDE like:
  - [Visual Studio Code](https://code.visualstudio.com/)
  - [IntelliJ IDEA](https://www.jetbrains.com/idea/download/)
  - [Eclipse IDE](https://www.eclipse.org/downloads/)
- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) or [Rancher Desktop](https://rancherdesktop.io/)
- [Install the Dapr CLI](https://docs.dapr.io/getting-started/install-dapr-cli/) and [initialize Dapr locally](https://docs.dapr.io/getting-started/install-dapr-selfhost/)
- [OpenJDK 17](https://learn.microsoft.com/en-us/java/openjdk/download#openjdk-17)
- [Apache Maven 3.8.x+](http://maven.apache.org/download.cgi) (Optional if Maven Wrapper is used)
  - Make sure that Maven uses the correct Java version by running `mvn -version`.
  
  {: .note-title }
  > Using Maven Wrapper
  >
  > Maven wrappers are provided for each maven module (i.e. each microservice) and for the whole project. You can use them instead of installing Maven.
  > To do so, you need to replace `mvn` by `./mvnw` for Linux/Unix shell and by `.\mvnw` for Powershell.
  >
  > When using Dapr CLI, you need to replace `mvn` at the end of the command by `./mvnw` for Linux/Unix shell and by `.\mvnw` for Powershell.
  >
  > To be sure you use the correct Java version, execute the following command at the root of the project: `./mvnw -version` for Linux/Unix shell and `.\mvnw -version` for Powershell.

  
- Clone the source code repository:

    ```bash
    git clone https://github.com/Azure/java-aks-aca-dapr-workshop.git
    ```

**From now on, this folder is referred to as the 'source code' folder.**

{: .important-title }
> Powershell
>
> If you are using Powershell, you need to replace in multiline commands `\` by **`** at then end of each line.
>
