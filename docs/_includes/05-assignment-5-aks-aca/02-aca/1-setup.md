Now, let's create the infrastructure for our application, so you can later deploy our microservices to [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/).

<!-- ----------------------------------------------------------------------- -->
<!--                         LOG ANALYTICS WORKSPACE                         -->
<!-- ----------------------------------------------------------------------- -->

### Log Analytics Workspace

[Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) is the environment for Azure Monitor log data. Each workspace has its own data repository and configuration, and data sources and solutions are configured to store their data in a particular workspace. You will use the same workspace for most of the Azure resources you will be creating.

1. Create a Log Analytics workspace with the following command:

    ```bash
    az monitor log-analytics workspace create \
      --resource-group rg-dapr-workshop-java \
      --location eastus \
      --workspace-name log-dapr-workshop-java
    ```

1. Retrieve the Log Analytics Client ID and client secret and store them in environment variables:

     - Linux/Unix shell:

        ```bash
        LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=$(
          az monitor log-analytics workspace show \
            --resource-group rg-dapr-workshop-java \
            --workspace-name log-dapr-workshop-java \
            --query customerId  \
            --output tsv | tr -d '[:space:]'
        )
        echo "LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID"

        LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$(
          az monitor log-analytics workspace get-shared-keys \
            --resource-group rg-dapr-workshop-java \
            --workspace-name log-dapr-workshop-java \
            --query primarySharedKey \
            --output tsv | tr -d '[:space:]'
        )
        echo "LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"
        ```

     - Powershell:
        
        ```powershell
        $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID="$(
          az monitor log-analytics workspace show `
            --resource-group rg-dapr-workshop-java `
            --workspace-name log-dapr-workshop-java `
            --query customerId  `
            --output tsv
        )"
        Write-Output "LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID"

        $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET="$(
          az monitor log-analytics workspace get-shared-keys `
            --resource-group rg-dapr-workshop-java `
            --workspace-name log-dapr-workshop-java `
            --query primarySharedKey `
            --output tsv
        )"
        Write-Output "LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"
        ```

<!-- ----------------------------------------------------------------------- -->
<!--                          APPLICATION INSIGTHS                           -->
<!-- ----------------------------------------------------------------------- -->

<!-- If observability is shown, Application Insights is required -->
{% if include.showObservability %}

### Application Insights

[Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=java) is used to enable Dapr service-to-service telemetry. The telemetry is used to visualize the microservices communication in the Application Insigts `Application Map`. When [creating the Azure Container Apps environment](https://learn.microsoft.com/en-us/cli/azure/containerapp/env?view=azure-cli-latest#az-containerapp-env-create), you can set Application Insights instrumentation key that is used by Dapr to export service-to-service telemetry to Application Insights.

{% include 05-assignment-5-aks-aca/02-aca/0-1-setup-application-insights.md %}

{% endif %}

<!-- ----------------------------------------------------------------------- -->
<!--                           CONTAINER REGISTRY                            -->
<!-- ----------------------------------------------------------------------- -->

### Azure Container Registry

Later, you will be creating Docker containers and pushing them to the Azure Container Registry.

1. [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/) is a private registry for hosting container images. Using the Azure Container Registry, you can store Docker images for all types of container deployments. This registry needs to be gloablly unique. Use the following command to generate a unique name:

    - Linux/Unix shell:
       
        ```bash
        UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)
        CONTAINER_REGISTRY="crdaprworkshopjava$UNIQUE_IDENTIFIER"
        echo $CONTAINER_REGISTRY
        ```

    - Powershell:
    
        ```powershell
        $ACCEPTED_CHAR = [Char[]]'abcdefghijklmnopqrstuvwxyz0123456789'
        $UNIQUE_IDENTIFIER = (Get-Random -Count 5 -InputObject $ACCEPTED_CHAR) -join ''
        $CONTAINER_REGISTRY = "crdaprworkshopjava$UNIQUE_IDENTIFIER"
        $CONTAINER_REGISTRY
        ```

1. Create an Azure Container Registry with the following command:

    ```bash
    az acr create \
      --resource-group rg-dapr-workshop-java \
      --location eastus \
      --name "$CONTAINER_REGISTRY" \
      --workspace log-dapr-workshop-java \
      --sku Standard \
      --admin-enabled true
    ```

    Notice that you created the registry with admin rights `--admin-enabled true` which is not suited for real production, but well for our workshop

1. Update the registry to allow anonymous users to pull the images ():

    ```bash
    az acr update \
      --resource-group rg-dapr-workshop-java \
      --name "$CONTAINER_REGISTRY" \
      --anonymous-pull-enabled true
    ```

    This can be handy if you want other attendees of the workshop to use your registry, but this is not suitable for production.

1. Get the URL of the Azure Container Registry and set it to the `CONTAINER_REGISTRY_URL` variable with the following command:

    - Linux/Unix shell:

      ```bash
      CONTAINER_REGISTRY_URL=$(
        az acr show \
          --resource-group rg-dapr-workshop-java \
          --name "$CONTAINER_REGISTRY" \
          --query "loginServer" \
          --output tsv
      )

      echo "CONTAINER_REGISTRY_URL=$CONTAINER_REGISTRY_URL"
      ```

    - Powershell:

      ```powershell
      $CONTAINER_REGISTRY_URL="$(
        az acr show `
          --resource-group rg-dapr-workshop-java `
          --name "$CONTAINER_REGISTRY" `
          --query "loginServer" `
          --output tsv
      )"

      Write-Output "CONTAINER_REGISTRY_URL=$CONTAINER_REGISTRY_URL"
      ```

<!-- ----------------------------------------------------------------------- -->
<!--                       CONTAINER APPS ENVIRONMENT                        -->
<!-- ----------------------------------------------------------------------- -->

### Azure Container Apps Environment

{% include 05-assignment-5-aks-aca/02-aca/0-2-setup-container-apps-env.md %}
