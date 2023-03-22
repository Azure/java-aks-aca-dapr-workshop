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

Now, let's create the infrastructure for our application, so we can later deploy our microservices to [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/).

### Setting Up the Environment Variables

Let's first set a few environment variables that will help us in creating the Azure infrastructure.

{: .important }
Some resources in Azure need to have a unique name across the globe (for example Azure Registry or Azure Load Testing).
For that, we use the `UNIQUE_IDENTIFIER` environment variable to make sure we don't have any name collision.
If you are developing in your local machine, the `UNIQUE_IDENTIFIER` will be your username (which is not totally unique, but it's a good start).
Please make sure to use a lowercase value, as it's used as a suffix to create resources that cannot stand uppercase.


```bash
PROJECT="dapr-java-workshop"
RESOURCE_GROUP="rg-${PROJECT}"
LOCATION="eastus"
TAG="dapr-java-aca"

LOG_ANALYTICS_WORKSPACE="logs-dapr-java-aca"
CONTAINERAPPS_ENVIRONMENT="cae-dapr-java-aca"

# If you're using a dev container, you should manually set this to
# a unique value (here randomly generated) to avoid conflicts with other users.
UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)
REGISTRY="crdaprjavaaca${UNIQUE_IDENTIFIER}"
IMAGES_TAG="1.0"

TRAFFIC_CONTROL_SERVICE="ca-traffic-control-service"
FINE_COLLECTION_SERVICE="ca-fine-collection-service"
VEHICLE_REGISTRATION_SERVICE="ca-vehicle-registration-service"
```

{: .note }
> Notice that we are using a specific location.
> This means that all the Azure resources that we are creating will be created in the same location.
> Depending on your geographical location, the resources might be created in different datacenters closer to you.
> If you want to know the list of available locations, you can execute the following command:
> 
> ```
> az account list-locations --query "[].name"
> ```
>
>You can update the `LOCATION` environment variable to use a different location.
>

{: .note }
> If you need to force a specific `UNIQUE_IDENTIFIER`, you can update the command about with your own identifier: `UNIQUE_IDENTIFIER=<your-unique-identifier>`.
>

### Log Analytics Workspace

[Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) is the environment for Azure Monitor log data. Each workspace has its own data repository and configuration, and data sources and solutions are configured to store their data in a particular workspace. We will use the same workspace for most of the Azure resources we will be creating.

Create a Log Analytics workspace with the following command:

```bash
az monitor log-analytics workspace create \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags system="$TAG" \
  --workspace-name "$LOG_ANALYTICS_WORKSPACE"
```

Let's also retrieve the Log Analytics Client ID and client secret and store them in environment variables:

```bash
LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=$(
  az monitor log-analytics workspace show \
    --resource-group "$RESOURCE_GROUP" \
    --workspace-name "$LOG_ANALYTICS_WORKSPACE" \
    --query customerId  \
    --output tsv | tr -d '[:space:]'
)
echo "LOG_ANALYTICS_WORKSPACE_CLIENT_ID=$LOG_ANALYTICS_WORKSPACE_CLIENT_ID"

LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$(
  az monitor log-analytics workspace get-shared-keys \
    --resource-group "$RESOURCE_GROUP" \
    --workspace-name "$LOG_ANALYTICS_WORKSPACE" \
    --query primarySharedKey \
    --output tsv | tr -d '[:space:]'
)
echo "LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"
```

### Azure Container Registry

In the next chapter we will be creating Docker containers and pushing them to the Azure Container Registry. [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/) is a private registry for hosting container images.
Using the Azure Container Registry, you can store Docker-formatted images for all types of container deployments.

First, let's create an Azure Container Registry with the following command (notice that we create the registry with admin rights `--admin-enabled true` which is not suited for real production, but well for our workshop):

```bash
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags system="$TAG" \
  --name "$REGISTRY" \
  --workspace "$LOG_ANALYTICS_WORKSPACE" \
  --sku Standard \
  --admin-enabled true
```

Update the registry to allow anonymous users to pull the images (this can be handy if you want other attendees of the workshop to use your registry, but this is not suite for production):

```bash
az acr update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$REGISTRY" \
  --anonymous-pull-enabled true
```

Get the URL of the Azure Container Registry and set it to the `REGISTRY_URL` variable with the following command:

```bash
REGISTRY_URL=$(
  az acr show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$REGISTRY" \
    --query "loginServer" \
    --output tsv
)

echo "REGISTRY_URL=$REGISTRY_URL"
```

### Container Apps environment

A [container apps environment](https://learn.microsoft.com/en-us/azure/container-apps/environment) acts as a secure boundary around our container apps. Containers deployed on the same environment use the same virtual network and write the log to the same logging destionation, in our case: Log Analytics workspace.

Create the container apps environment with the following command:

```bash
az containerapp env create \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags system="$TAG" \
  --name "$CONTAINERAPPS_ENVIRONMENT" \
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
      --name "$CONTAINERAPPS_ENVIRONMENT" --resource-group $RESOURCE_GROUP \
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
        value: <replace>.redis.cache.windows.net:6380
      - name: redisPassword
        value: "<replaceWithRedisKey>"
      - name: enableTLS
        value: "true"
    scopes:
      - trafficcontrolservice
      - finecollectionservice
    ```

2. **Copy or Move** this file `dapr/aca-redis-pubsub.yaml` to `dapr/components` folder.

3. **Replace** the `redisHost` and `redisPassword` values with the values you set in `dapr/components/redis-pubsub.yaml` in [Assignment 3 - Using Dapr for pub/sub with Azure Cache for Redis]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/2-azure-cache-redis.md %}).

3. Go to the root folder of the repository.

4. Enter the following command to deploy the `pubsub` Dapr component:

    ```bash
    az containerapp env dapr-component set \
      --name "$CONTAINERAPPS_ENVIRONMENT" --resource-group $RESOURCE_GROUP \
      --dapr-component-name pubsub \
      --yaml ./dapr/components/aca-redis-pubsub.yaml
    ```

## Step 2 - Generate Docker images for applications, and push them to ACR

Since we don't have any container images ready yet, we'll build and push container images in Azure Container Registry (ACR) to get things running.

1. Login to your ACR repository

    ```bash
    az acr login --name $REGISTRY
    ```

2. In the root folder of VehicleRegistrationService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag vehicle-registration-service:1.0-SNAPSHOT "$REGISTRY.azurecr.io/vehicle-registration-service:latest"
    docker push $REGISTRY.azurecr.io/vehicle-registration-service:latest
    ```

3. In the root folder of FineCollectionService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT "$REGISTRY.azurecr.io/fine-collection-service:latest"
    docker push $REGISTRY.azurecr.io/fine-collection-service:latest
    ```

4. In the root folder of TrafficControlService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag traffic-control-service:1.0-SNAPSHOT "$REGISTRY.azurecr.io/traffic-control-service:latest"
    docker push $REGISTRY.azurecr.io/traffic-control-service:latest
    ```

## Step 3 - Deploy the Container Apps

Now that we have created the container apps environment, we can create the container apps. A container app is a containerized application that is deployed to a container apps environment. 

You will create three container apps, one for each of our Java services: TrafficControlService, FineCollectionService and VehicleRegistrationService.

1. Create a Container App for VehicleRegistrationService with the following command:
  
    ```bash
    az containerapp create \
      --name $VEHICLE_REGISTRATION_SERVICE \
      --resource-group $RESOURCE_GROUP \
      --environment $CONTAINERAPPS_ENVIRONMENT \
      --image "$REGISTRY_URL"/vehicle-registration-service:latest \
      --target-port 6002 \
      --ingress internal \
      --min-replicas 1 \
      --max-replicas 1
    ```

    Note that internal ingress is enable. This is because we want to provide access to the service only from within the container apps environment. FineCollectionService will be able to access the VehicleRegistrationService using the internal ingress FQDN.

1. Get the FQDN of VehicleRegistrationService and save it in a variable:
  
    ```bash
    VEHICLE_REGISTRATION_SERVICE_FQDN=$(az containerapp show \
      --name $VEHICLE_REGISTRATION_SERVICE \
      --resource-group $RESOURCE_GROUP \
      --query "properties.configuration.ingress.fqdn" \
      -o tsv)
    echo $VEHICLE_REGISTRATION_SERVICE_FQDN
    ```
    
    Note that the FQDN is in the format `<service-name>.internal.<unique-name>.<region>.azurecontainerapps.io` where internal indicates that the service is only accessible from within the container apps environment, i.e. exposed with internal ingress.

1. Create a Container App for FineCollectionService with the following command:
  
    ```bash
    az containerapp create \
      --name $FINE_COLLECTION_SERVICE \
      --resource-group $RESOURCE_GROUP \
      --environment $CONTAINERAPPS_ENVIRONMENT \
      --image "$REGISTRY_URL"/fine-collection-service:latest \
      --min-replicas 1 \
      --max-replicas 1 \
      --enable-dapr \
      --dapr-app-id finecollectionservice \
      --dapr-app-port 6001 \
      --dapr-app-protocol http \
      --env-vars "VEHICLE_REGISTRATION_SERVICE_BASE_URL=https://$VEHICLE_REGISTRATION_SERVICE_FQDN"
    ```

1. Create a Container App for TrafficControlService with the following command:
  
    ```bash
    az containerapp create \
      --name $TRAFFIC_CONTROL_SERVICE \
      --resource-group $RESOURCE_GROUP \
      --environment $CONTAINERAPPS_ENVIRONMENT \
      --image "$REGISTRY_URL"/traffic-control-service:latest \
      --target-port 6000 \
      --ingress external \
      --min-replicas 1 \
      --max-replicas 1 \
      --enable-dapr \
      --dapr-app-id trafficcontrolservice \
      --dapr-app-port 6000 \
      --dapr-app-protocol http
    ```

1. Get the FQDN of TrafficControlService and save it in a variable:
   
    ```bash
    TRAFFIC_CONTROL_SERVICE_FQDN=$(az containerapp show \
      --name $TRAFFIC_CONTROL_SERVICE \
      --resource-group $RESOURCE_GROUP \
      --query "properties.configuration.ingress.fqdn" \
      -o tsv)
    echo $TRAFFIC_CONTROL_SERVICE_FQDN
    ```

    Note that the FQDN is in the format `<service-name>.<unique-name>.<region>.azurecontainerapps.io` where internal is not present. Indeed, traffic control service is exposed with external ingress, i.e. it is accessible from outside the container apps environment. It will be used by the simulation to test the application.

## Step 4 - Run the simulation

1. Set the following environment variable:

    ```bash
    export TRAFFIC_CONTROL_SERVICE_BASE_URL=https://$TRAFFIC_CONTROL_SERVICE_FQDN
    ```

1. In the root folder of the simulation (`Simulation`), start the simulation using `mvn spring-boot:run`.

## Step 5 - Test the microservices running in ACA

You can access the log of the container apps from the [Azure Portal](https://portal.azure.com/) or directly in a terminal window. The following steps show how to access the logs from the terminal window for each microservice.


### Traffic Control Service

1. Run the following command to identify the running revision of traffic control service container apps:

    ```bash
    TRAFFIC_CONTROL_SERVICE_REVISION=$(az containerapp revision list -n $TRAFFIC_CONTROL_SERVICE -g $RESOURCE_GROUP --query "[0].name" -o tsv)
    echo $TRAFFIC_CONTROL_SERVICE_REVISION
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

    ```bash
    FINE_COLLECTION_SERVICE_REVISION=$(az containerapp revision list -n $FINE_COLLECTION_SERVICE -g $RESOURCE_GROUP --query "[0].name" -o tsv)
    echo $FINE_COLLECTION_SERVICE_REVISION
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

    ```bash
    VEHICLE_REGISTRATION_SERVICE_REVISION=$(az containerapp revision list -n $VEHICLE_REGISTRATION_SERVICE -g $RESOURCE_GROUP --query "[0].name" -o tsv)
    echo $VEHICLE_REGISTRATION_SERVICE_REVISION
    ```

2. Run the following command to get the last 10 lines of vehicle registration service logs from Log Analytics Workspace:

    ```bash
    az monitor log-analytics query \
      --workspace $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID \
      --analytics-query "ContainerAppConsoleLogs_CL | where RevisionName_s == '$VEHICLE_REGISTRATION_SERVICE_REVISION' | project TimeGenerated, Log_s | sort by TimeGenerated desc | take 10" \
      --out table
    ```