---
title: Deploying Applications to Azure Container Apps with Dapr
parent: Assignment 5 - Deploying Applications to AKS and Azure Container Apps with Dapr
has_children: false
nav_order: 3
---

# Assignment 5 - Deploying Applications to Azure Container Apps with Dapr

## Setup

### Creating the Azure Resources

Now, let's create the infrastructure for our application, so we can later deploy our microservices to Azure Container Apps.

### Setting Up the Environment Variables

Let's first set a few environment variables that will help us in creating the Azure infrastructure.

### [IMPORTANT]
Some resources in Azure need to have a unique name across the globe (for example Azure Registry or Azure Load Testing).
For that, we use the `UNIQUE_IDENTIFIER` environment variable to make sure we don't have any name collision.
If you are developing in your local machine, the `UNIQUE_IDENTIFIER` will be your username (which is not totally unique, but it's a good start).
Please make sure to use a lowercase value, as it's used as a suffix to create resources that cannot stand uppercase.
###

```
  PROJECT="dapr-java-aca-workshop"
  RESOURCE_GROUP="rg-${PROJECT}"
  LOCATION="eastus"
  TAG="dapr-java-aca"

  LOG_ANALYTICS_WORKSPACE="logs-dapr-java-aca"
  CONTAINERAPPS_ENVIRONMENT="env-dapr-java-aca"

  # If you're using a dev container, you should manually set this to
  # a unique value (like your name) to avoid conflicts with other users.
  UNIQUE_IDENTIFIER=$(whoami)
  REGISTRY="daprjavaacaregistry${UNIQUE_IDENTIFIER}"
  IMAGES_TAG="1.0"
  
  TRAFFICCONTROL_SERVICE="trafficcontrol-service"
  FINECOLLECTION_SERVICE="finecollection-service"
  VEHICLEREGISTRATION_SERVICE="vehicleregistration-service"
```

### [NOTE]
###
Notice that we are using a specific location.
This means that all the Azure resources that we are creating will be created in the same location.
Depending on your geographical location, the resources might be created in different datacenters closer to you.
If you want to know the list of available locations, you can execute the following command:


```
az account list-locations --query "[].name"
```
If you need to force a specific `UNIQUE_IDENTIFIER`, you can set it before running the command with `export UNIQUE_IDENTIFIER=<your-unique-identifier>`.

### Now let's create the Azure resources.

### Resource Group

A https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal[resource group] is a container that holds related resources for an Azure solution.
The resource group can include all the resources for the solution, or only those resources that you want to manage as a group.
In our workshop, all the databases, all the microservices, etc.
will be grouped into a single resource group.

Run the following command to create the Java Runtimes resource group:

```
   az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags system="$TAG"
```


### Log Analytics Workspace

https://learn.microsoft.com/azure/azure-monitor/logs/quick-create-workspace?tabs=azure-portal[Log Analytics workspace] is the environment for Azure Monitor log data.
Each workspace has its own data repository and configuration, and data sources and solutions are configured to store their data in a particular workspace.
We will use the same workspace for most of the Azure resources we will be creating.

Create a Log Analytics workspace with the following command:

```
az monitor log-analytics workspace create \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags system="$TAG" \
    --workspace-name "$LOG_ANALYTICS_WORKSPACE"
```

Let's also retrieve the Log Analytics Client ID and client secret and store them in environment variables:

```
LOG_ANALYTICS_WORKSPACE_CLIENT_ID=$(
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

In the next chapter we will be creating Docker containers and pushing them to the Azure Container Registry.
https://azure.microsoft.com/products/container-registry/[Azure Container Registry] is a private registry for hosting container images.
Using the Azure Container Registry, you can store Docker-formatted images for all types of container deployments.

First, let's created an Azure Container Registry with the following command (notice that we create the registry with admin rights `--admin-enabled true` which is not suited for real production, but good for our workshop):

```
az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags system="$TAG" \
    --name "$REGISTRY" \
    --workspace "$LOG_ANALYTICS_WORKSPACE" \
    --sku Standard \
    --admin-enabled true
```

Update the repository to allow anonymous users to pull the images (this can be handy if you want other attendees to use your registry):

```
az acr update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$REGISTRY" \
    --anonymous-pull-enabled true
```

Get the URL of the Azure Container Registry and set it to the `REGISTRY_URL` variable with the following command:

```
 REGISTRY_URL=$(
    az acr show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$REGISTRY" \
      --query "loginServer" \
      --output tsv
  )

  echo "REGISTRY_URL=$REGISTRY_URL"
```

If you log into the https://portal.azure.com[Azure Portal] and search for the `dapr-java-aca-workshop` resource group, you should see the following created resources.

[Screenshot of Azure Portal showing the resource group](../images/azure-rg.png)

### Creating the Container Apps environment

A container apps environment acts as a boundary for our containers.
Containers deployed on the same environment use the same virtual network and the same Log Analytics workspace.
Create the container apps environment with the following command:

```
az containerapp env create \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags system="$TAG" \
    --name "$CONTAINERAPPS_ENVIRONMENT" \
    --logs-workspace-id "$LOG_ANALYTICS_WORKSPACE_CLIENT_ID" \
    --logs-workspace-key "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"
```

### [NOTE]

Some Azure CLI commands can take some time to execute.
Don't hesitate to have a look at the next assignments to know what you will have to do.
And then, come back to this one when the command is done and execute the next one.


### Creating the Container Apps

Now that we have created the container apps environment, we can create the container apps.
A container app is a containerized application that is deployed to a container apps environment.
We will create three container apps, one for each of our Java services (TrafficControlService, FineCollectionService and VehicleRegistrationService).
Since we don't have any container images ready yet, we'll build and push container images in ACR to get things running.
We'll update the container apps with the actual images later.

## Generate Docker images for applications, and push them to ACR

1. login to your ACR repository

```azurecli
az acr login --name $REGISTRY
```

2. In the root folder/directory of each of the VehicleRegistrationService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag vehicle-registration-service:1.0-SNAPSHOT ""$REGISTRY".azurecr.io/vehicle-registration-service:latest"
docker push daprworkshopjava.azurecr.io/vehicle-registration-service:latest
```

3. In the root folder/directory of each of the FineCollectionService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag fine-collection-service:1.0-SNAPSHOT ""$REGISTRY".azurecr.io/fine-collection-service:latest"
docker push daprworkshopjava.azurecr.io/fine-collection-service:latest
```
4. In the root folder/directory of each of the TrafficControlService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag traffic-control-service:1.0-SNAPSHOT ""$REGISTRY".azurecr.io/traffic-control-service:latest"
docker push ""$REGISTRY".azurecr.io/traffic-control-service:latest"
```
  Create a Container App for the TrafficControlService

  ```
    TRAFFICCONTROL_SERVICE="trafficcontrol-service"
    FINECOLLECTION_SERVICE="finecollection-service"
    VEHICLEREGISTRATION_SERVICE="vehicleregistration-service"

       az containerapp create -n "$TRAFFICCONTROL_SERVICE" -g "$RESOURCE_GROUP" \
              --image ""$REGISTRY".azurecr.io/traffic-control-service:latest" -e "$CONTAINERAPPS_ENVIRONMENT" \
              --enable-dapr --dapr-app-port 6000 \
              --dapr-app-id trafficcontrolservice \
              --dapr-components ../dapr/components
  ```

5. In the root folder/directory of each of the SimulationService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag simulation:1.0-SNAPSHOT daprworkshopjava.azurecr.io/simulation:latest
docker push daprworkshopjava.azurecr.io/simulation:latest
```



The `create` command returns the URL for the container apps.
You can also get the URLs with the following commands:

[source,shell]
----
include::{workshop-github-raw}/scripts/infra/deploy.sh[tag=adocIngressHosts, indent=0]
----


2. Configure Dapr to use kafka for pubsub

```bash
cd deploy
kubectl apply -f kafka-pubsub.yaml
```



## Step 3 - Deploy Kubernetes manifest files for applications to AKS

1. From the root folder/directory of the repo, run the following command.

Please note below the `kubectl apply` is with **-k** option, which is applying `kustomize.yaml` file in the `deploy` folder

```bash
kubectl apply -k deploy
```

## Step 4 - Test the applications running in AKS

1. run the following command to identify the name of each microservice pod

```bash
kubectl get pods
```

2. look at the log file of each application pod to see the same output as seen when running on your laptop. For example,

```bash
kubectl logs trafficcontrolservice-7d8f48b778-rx8l8 -c traffic-control-service
```

3. delete all application deployments

```azurecli
kubectl delete -k deploy
```
