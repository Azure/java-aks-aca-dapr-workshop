---
title: Deploying to ACA with Dapr
parent: Deploying to Azure Container Apps
grand_parent: Assignment 5 - Deploying to Azure with Dapr
has_children: false
nav_order: 1
layout: default
has_toc: true
---

# Deploying Applications to Azure Container Apps (ACA) with Dapr

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

This assignement is about deploying our microservices to [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/).

{: .important-title }
> Pre-requisite
>
> Either [Assignment 3 - Using Dapr for pub/sub with Azure Service Bus]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md %}) or [Assignment 3 - Using Dapr for pub/sub with Azure Cache for Redis]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/2-azure-cache-redis.md %}) is a pre-requisite for this assignment.
>


## Setup

Now, let's create the infrastructure for our application, so you can later deploy our microservices to [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/).

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

### Azure Container Apps environment

A [container apps environment](https://learn.microsoft.com/en-us/azure/container-apps/environment) acts as a secure boundary around our container apps. Containers deployed on the same environment use the same virtual network and write the log to the same logging destionation, in our case: Log Analytics workspace.


{: .important-title }
> Dapr Telemetry
> 

> If you want to enable Dapr telemetry, you need to create the container apps environment with Application Insights. You can follow these instructions instead of the instructions below: [(Optional) Observability with Dapr using Application Insights]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/2-observability.md %})
>

Create the container apps environment with the following command:

```bash
az containerapp env create \
  --resource-group rg-dapr-workshop-java \
  --location eastus \
  --name cae-dapr-workshop-java \
  --logs-workspace-id "$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID" \
  --logs-workspace-key "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"
```

{: .note }
> Some Azure CLI commands can take some time to execute. Don't hesitate to have a look at the next assignments to know what you will have to do. And then, come back to this one when the command is done and execute the next one.
>

## Step 1 - Deploy Dapr Components

You are going to deploy the `pubsub` Dapr component. This pubsub is either Azure Service Bus or Azure Cache Redis. You can follow the instructions corresponding to the service you deployed during assignment 3.

### Azure Service Bus

In [Assignment 3 - Using Dapr for pub/sub with Azure Service Bus]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md %}), you copied the file `dapr/azure-servicebus-pubsub.yaml` to `dapr/components` folder and updated the `connectionString` value. This file is used to deploy the `pubsub` Dapr component. 

The Dapr component structure for Azure Container Apps is different from the standard Dapr component yaml structure and hence the need for a new component yaml file.

1. Open the file `dapr/aca-azure-servicebus-pubsub.yaml` in your code editor.

    ```yaml
    # pubsub.yaml for Azure Service Bus
    componentType: pubsub.azure.servicebus
    version: v1
    metadata:
      - name: connectionString
        value: "Endpoint=sb://{ServiceBusNamespace}.servicebus.windows.net/;SharedAccessKeyName={PolicyName};SharedAccessKey={Key};EntityPath={ServiceBus}"
    scopes:
      - trafficcontrolservice
      - finecollectionservice
    ```

2. **Copy or Move** this file `dapr/aca-servicebus-pubsub.yaml` to `dapr/components` folder.

3. **Replace** the `connectionString` value with the value you set in `dapr/components/azure-servicebus-pubsub.yaml` in [Assignment 3 - Using Dapr for pub/sub with Azure Service Bus]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md %}).

4. Go to the root folder of the repository.

5. Enter the following command to deploy the `pubsub` Dapr component:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java --resource-group rg-dapr-workshop-java \
      --dapr-component-name pubsub \
      --yaml ./dapr/components/aca-azure-servicebus-pubsub.yaml
    ```

### Azure Cache for Redis

In [Assignment 3 - Using Dapr for pub/sub with Azure Cache for Redis]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/2-azure-cache-redis.md %}), you copied the file `dapr/aca-azure-redis-pubsub.yaml` to `dapr/components` folder and updated the `redisHost` and `redisPassword` values. This file is used to deploy the `pubsub` Dapr component.

The Dapr component structure for Azure Container Apps is different from the standard Dapr component yaml structure and hence the need for a new component yaml file.

1. Open the file `dapr/aca-redis-pubsub.yaml` in your code editor.

    ```yaml
    # pubsub.yaml for Azure Cache for Redis
    componentType: pubsub.redis
    version: v1
    metadata:
      - name: redisHost
        value: <replaceWithRedisHostName>:<replaceWithRedisSSLPort>
      - name: redisPassword
        value: <replaceWithPrimaryKey>
      - name: enableTLS
        value: "true"
    scopes:
      - traffic-control-service
      - fine-collection-service
    ```

2. **Copy or Move** this file `dapr/aca-redis-pubsub.yaml` to `dapr/components` folder.

3. **Replace** the `redisHost` and `redisPassword` values with the values you set in `dapr/components/redis-pubsub.yaml` in [Assignment 3 - Using Dapr for pub/sub with Azure Cache for Redis]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/2-azure-cache-redis.md %}).

3. Go to the root folder of the repository.

4. Enter the following command to deploy the `pubsub` Dapr component:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java --resource-group rg-dapr-workshop-java \
      --dapr-component-name pubsub \
      --yaml ./dapr/components/aca-redis-pubsub.yaml
    ```

## Step 2 - Generate Docker images for applications, and push them to ACR

Since you don't have any container images ready yet, we'll build and push container images in Azure Container Registry (ACR) to get things running.

1. Login to your ACR repository

    ```bash
    az acr login --name $CONTAINER_REGISTRY
    ```

2. In the root folder of VehicleRegistrationService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag vehicle-registration-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/vehicle-registration-service:latest"
    docker push $CONTAINER_REGISTRY.azurecr.io/vehicle-registration-service:latest
    ```

3. In the root folder of FineCollectionService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:latest"
    docker push $CONTAINER_REGISTRY.azurecr.io/fine-collection-service:latest
    ```

4. In the root folder of TrafficControlService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag traffic-control-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/traffic-control-service:latest"
    docker push $CONTAINER_REGISTRY.azurecr.io/traffic-control-service:latest
    ```

## Step 3 - Deploy the Container Apps

Now that you have created the container apps environment and push the images, you can create the container apps. A container app is a containerized application that is deployed to a container apps environment. 

You will create three container apps, one for each of our Java services: TrafficControlService, FineCollectionService and VehicleRegistrationService.

1. Create a Container App for VehicleRegistrationService with the following command:
  
    ```bash
    az containerapp create \
      --name ca-vehicle-registration-service \
      --resource-group rg-dapr-workshop-java \
      --environment cae-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY_URL/vehicle-registration-service:latest" \
      --target-port 6002 \
      --ingress internal \
      --min-replicas 1 \
      --max-replicas 1
    ```

    Notice that internal ingress is enable. This is because we want to provide access to the service only from within the container apps environment. FineCollectionService will be able to access the VehicleRegistrationService using the internal ingress FQDN.

1. Get the FQDN of VehicleRegistrationService and save it in a variable:
  
    - Linux/Unix shell:

      ```bash
      VEHICLE_REGISTRATION_SERVICE_FQDN=$(az containerapp show \
        --name ca-vehicle-registration-service \
        --resource-group rg-dapr-workshop-java \
        --query "properties.configuration.ingress.fqdn" \
        -o tsv)
      echo $VEHICLE_REGISTRATION_SERVICE_FQDN
      ```

    - Powershell:

      ```powershell
      $VEHICLE_REGISTRATION_SERVICE_FQDN = az containerapp show `
        --name ca-vehicle-registration-service `
        --resource-group rg-dapr-workshop-java `
        --query "properties.configuration.ingress.fqdn" `
        -o tsv
      $VEHICLE_REGISTRATION_SERVICE_FQDN
      ```
    
    Notice that the FQDN is in the format `<service-name>.internal.<unique-name>.<region>.azurecontainerapps.io` where internal indicates that the service is only accessible from within the container apps environment, i.e. exposed with internal ingress.

1. Create a Container App for FineCollectionService with the following command:
  
    ```bash
    az containerapp create \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --environment cae-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY_URL/fine-collection-service:latest" \
      --min-replicas 1 \
      --max-replicas 1 \
      --enable-dapr \
      --dapr-app-id fine-collection-service \
      --dapr-app-port 6001 \
      --dapr-app-protocol http \
      --env-vars "VEHICLE_REGISTRATION_SERVICE_BASE_URL=https://$VEHICLE_REGISTRATION_SERVICE_FQDN"
    ```

1. Create a Container App for TrafficControlService with the following command:
  
    ```bash
    az containerapp create \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --environment cae-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY_URL/traffic-control-service:latest" \
      --target-port 6000 \
      --ingress external \
      --min-replicas 1 \
      --max-replicas 1 \
      --enable-dapr \
      --dapr-app-id traffic-control-service \
      --dapr-app-port 6000 \
      --dapr-app-protocol http
    ```

1. Get the FQDN of traffic control service and save it in a variable:

    - Linux/Unix shell:
   
      ```bash
      TRAFFIC_CONTROL_SERVICE_FQDN=$(az containerapp show \
        --name ca-traffic-control-service \
        --resource-group rg-dapr-workshop-java \
        --query "properties.configuration.ingress.fqdn" \
        -o tsv)
      echo $TRAFFIC_CONTROL_SERVICE_FQDN
      ```
    
    - Powershell:

      ```powershell
      $TRAFFIC_CONTROL_SERVICE_FQDN = $(az containerapp show `
        --name ca-traffic-control-service `
        --resource-group rg-dapr-workshop-java `
        --query "properties.configuration.ingress.fqdn" `
        -o tsv)
      $TRAFFIC_CONTROL_SERVICE_FQDN
      ```

    Notice that the FQDN is in the format `<service-name>.<unique-name>.<region>.azurecontainerapps.io` where internal is not present. Indeed, traffic control service is exposed with external ingress, i.e. it is accessible from outside the container apps environment. It will be used by the simulation to test the application.

## Step 4 - Run the simulation

1. Set the following environment variable:

    - Linux/Unix shell:

      ```bash
      export TRAFFIC_CONTROL_SERVICE_BASE_URL=https://$TRAFFIC_CONTROL_SERVICE_FQDN
      ```

    - Powershell:
  
      ```powershell
      $env:TRAFFIC_CONTROL_SERVICE_BASE_URL = "https://$TRAFFIC_CONTROL_SERVICE_FQDN"
      ```

1. In the root folder of the simulation (`Simulation`), start the simulation:

    ```bash
    mvn spring-boot:run
    ```

## Step 5 - Test the microservices running in ACA

You can access the log of the container apps from the [Azure Portal](https://portal.azure.com/) or directly in a terminal window. The following steps show how to access the logs from the terminal window for each microservice.


### Traffic Control Service

1. Run the following command to identify the running revision of traffic control service container apps:

    - Linux/Unix shell:

      ```bash
      TRAFFIC_CONTROL_SERVICE_REVISION=$(az containerapp revision list -n ca-traffic-control-service -g rg-dapr-workshop-java --query "[0].name" -o tsv)
      echo $TRAFFIC_CONTROL_SERVICE_REVISION
      ```

    - Powershell:

      ```powershell
      $TRAFFIC_CONTROL_SERVICE_REVISION = az containerapp revision list -n ca-traffic-control-service -g rg-dapr-workshop-java --query "[0].name" -o tsv
      $TRAFFIC_CONTROL_SERVICE_REVISION
      ```

2. Run the following command to get the last 10 lines of traffic control service logs from Log Analytics Workspace:

    ```bash
    az monitor log-analytics query \
      --workspace $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID \
      --analytics-query "ContainerAppConsoleLogs_CL | where RevisionName_s == '$TRAFFIC_CONTROL_SERVICE_REVISION' | project TimeGenerated, Log_s | sort by TimeGenerated desc | take 10" \
      --out table
    ```

### Fine Collection Service

1. Run the following command to identify the running revision of fine collection service container apps:

    - Linux/Unix shell:

      ```bash
      FINE_COLLECTION_SERVICE_REVISION=$(az containerapp revision list -n ca-fine-collection-service -g rg-dapr-workshop-java --query "[0].name" -o tsv)
      echo $FINE_COLLECTION_SERVICE_REVISION
      ```

    - Powershell:

      ```powershell
      $FINE_COLLECTION_SERVICE_REVISION = az containerapp revision list -n ca-fine-collection-service -g rg-dapr-workshop-java --query "[0].name" -o tsv
      $FINE_COLLECTION_SERVICE_REVISION
      ```

2. Run the following command to get the last 10 lines of fine collection service logs from Log Analytics Workspace:

    ```bash
    az monitor log-analytics query \
      --workspace $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID \
      --analytics-query "ContainerAppConsoleLogs_CL | where RevisionName_s == '$FINE_COLLECTION_SERVICE_REVISION' | project TimeGenerated, Log_s | sort by TimeGenerated desc | take 10" \
      --out table
    ```

### Vehicle Registration Service

1. Run the following command to identify the running revision of vehicle registration service container apps:

    - Linux/Unix shell:

      ```bash
      VEHICLE_REGISTRATION_SERVICE_REVISION=$(az containerapp revision list -n ca-vehicle-registration-service -g rg-dapr-workshop-java --query "[0].name" -o tsv)
      echo $VEHICLE_REGISTRATION_SERVICE_REVISION
      ```

    - Powershell:

      ```powershell
      $VEHICLE_REGISTRATION_SERVICE_REVISION = az containerapp revision list -n ca-vehicle-registration-service -g rg-dapr-workshop-java --query "[0].name" -o tsv
      $VEHICLE_REGISTRATION_SERVICE_REVISION
      ```

2. Run the following command to get the last 10 lines of vehicle registration service logs from Log Analytics Workspace:

    ```bash
    az monitor log-analytics query \
      --workspace $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID \
      --analytics-query "ContainerAppConsoleLogs_CL | where RevisionName_s == '$VEHICLE_REGISTRATION_SERVICE_REVISION' | project TimeGenerated, Log_s | sort by TimeGenerated desc | take 10" \
      --out table
    ```

## Next Steps

This is the end of the workshop!

- You can follow the **Optional execices for Azure Container Apps (ACA)** to learn more about observability:
  - [Observability]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/2-observability.md %})
- You can read the **additional topics**:
  - [Prevent port collisions]({{ site.baseurl }}{% link modules/08-additional-topics/1-prevent-port-collisions.md %})
  - [Dapr and Service Meshes]({{ site.baseurl }}{% link modules/08-additional-topics/2-dapr-and-service-meshes.md %})
- You can continue the workshop with the **bonus assignments** to learn more about other Dapr building blocks:
  - [Service-to-service invocation using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-to-service-invocation/index.md %})
  - [Azure Cosmos DB as a state store]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/index.md %})
  - [Azure Key Vault as a secret store]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/index.md %})

{: .important-title }
> Cleanup
>
> When the workshop is done, please follow the [cleanup instructions]({{ site.baseurl }}{% link modules/10-cleanup/index.md %}) to delete the resources created in this workshop.
> 

<span class="fs-3">
[< Deploy to ACA]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/index.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[(Optional) Observability >]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/2-observability.md %}){: .btn .float-right .mt-7 }
</span>
