#!/bin/sh

# Set the variables
RANDOM_NUMBER=$RANDOM
PROJECT="dapr-java-demo-$RANDOM_NUMBER"
PROJECT_ALPHANUMERIC=$(echo $PROJECT | tr -dc '[:alnum:]')
RESOURCE_GROUP="rg-$PROJECT"
LOCATION="westeurope"

LOGS_ANALYTICS_WORKSPACE="logs-$PROJECT"
CONTAINER_APPS_ENVIRONMENT="aca-env-$PROJECT"
CONTAINER_REGISTRY="acr$PROJECT_ALPHANUMERIC"

COSMOS_DB="cosmos-$PROJECT"
COSMOS_DB_DATABASE="cosmos-db-$PROJECT"
COSMOS_DB_DATABASE_CONTAINER="traffic-control-vehicle-state"

SERVICE_BUS="sb-$PROJECT"
SERVICE_BUS_TOPIC="test"
SERVICE_BUS_TOPIC_AUTHORIZATION_RULE="ar-test-sb-$PROJECT"

AZURE_AD_APPLICATION="ad-app-$PROJECT"
AZURE_KEYVAULT="kv-$PROJECT"

YOUR_EMAIL="pmalarme@roadtothe.cloud"

IMAGE_TAG="1.0"

VEHICLE_REGISTRATION_SERVICE="vehicle-registration-service"
FINE_COLLECTION_SERVICE="fine-collection-service"
TRAFFIC_CONTROL_SERVICE="traffic-control-service"

# Get the id of the subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
while [ -z "$SUBSCRIPTION_ID" ] ; do
    echo "Waiting for subscription id to be available..."
    sleep 5
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
done
echo "SUBSCRIPTION_ID=$SUBSCRIPTION_ID"

# Create the resource group
az group create --name $RESOURCE_GROUP --location $LOCATION
echo "RESOURCE_GROUP=$RESOURCE_GROUP"

# Create the Log Analytics workspace and get client id and secret
az monitor log-analytics workspace create --resource-group $RESOURCE_GROUP --location $LOCATION --workspace-name $LOGS_ANALYTICS_WORKSPACE

LOGS_ANALYTICS_CLIENT_ID=$(az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP --workspace-name $LOGS_ANALYTICS_WORKSPACE --query customerId -o tsv)
while [ -z "$LOGS_ANALYTICS_CLIENT_ID" ] ; do
    echo "Waiting for Log Analytics client id to be available..."
    sleep 5
    LOGS_ANALYTICS_CLIENT_ID=$(az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP --workspace-name $LOGS_ANALYTICS_WORKSPACE --query customerId -o tsv)
done
echo "LOGS_ANALYTICS_CLIENT_ID=$LOGS_ANALYTICS_CLIENT_ID"

LOGS_ANALYTICS_CLIENT_SECRET=$(az monitor log-analytics workspace get-shared-keys --resource-group $RESOURCE_GROUP --workspace-name $LOGS_ANALYTICS_WORKSPACE --query primarySharedKey -o tsv)
while [ -z "$LOGS_ANALYTICS_CLIENT_SECRET" ] ; do
    echo "Waiting for Log Analytics client secret to be available..."
    sleep 5
    LOGS_ANALYTICS_CLIENT_SECRET=$(az monitor log-analytics workspace get-shared-keys --resource-group $RESOURCE_GROUP --workspace-name $LOGS_ANALYTICS_WORKSPACE --query primarySharedKey -o tsv)
done
echo "LOGS_ANALYTICS_CLIENT_SECRET=$LOGS_ANALYTICS_CLIENT_SECRET"

# Create Application Insights
az monitor app-insights component create --app $PROJECT --location $LOCATION --resource-group $RESOURCE_GROUP --kind web --application-type web --workspace $LOGS_ANALYTICS_WORKSPACE

INSTRUMENTATION_KEY=$(az monitor app-insights component show --app $PROJECT --resource-group $RESOURCE_GROUP --query instrumentationKey -o tsv)
while [ -z "$INSTRUMENTATION_KEY" ] ; do
    echo "Waiting for Application Insights instrumentation key to be available..."
    sleep 5
    INSTRUMENTATION_KEY=$(az monitor app-insights component show --app $PROJECT --resource-group $RESOURCE_GROUP --query instrumentationKey -o tsv)
done
echo "INSTRUMENTATION_KEY=$INSTRUMENTATION_KEY"

# Create the container registry
az acr create --resource-group $RESOURCE_GROUP --name $CONTAINER_REGISTRY --sku Basic --workspace $LOGS_ANALYTICS_WORKSPACE --admin-enabled true

AZURE_CONTAINER_REGISTRY_USERNAME=$(az acr credential show --name $CONTAINER_REGISTRY --query username -o tsv)
while [ -z "$AZURE_CONTAINER_REGISTRY_USERNAME" ] ; do
    echo "Waiting for ACR username to be available..."
    sleep 5
    AZURE_CONTAINER_REGISTRY_USERNAME=$(az acr credential show --name $CONTAINER_REGISTRY --query username -o tsv)
done
echo "REGISTRY_USERNAME=$AZURE_CONTAINER_REGISTRY_USERNAME"

AZURE_CONTAINER_REGISTRY_PASSWORD=$(az acr credential show --name $CONTAINER_REGISTRY --query passwords[0].value -o tsv)
while [ -z "$AZURE_CONTAINER_REGISTRY_PASSWORD" ] ; do
    echo "Waiting for ACR password to be available..."
    sleep 5
    AZURE_CONTAINER_REGISTRY_PASSWORD=$(az acr credential show --name $CONTAINER_REGISTRY --query passwords[0].value -o tsv)
done
echo "REGISTRY_PASSWORD=$AZURE_CONTAINER_REGISTRY_PASSWORD"

AZURE_CONTAINER_REGISTRY_URL=$(az acr show --name $CONTAINER_REGISTRY --query loginServer -o tsv)
while [ -z "$AZURE_CONTAINER_REGISTRY_URL" ] ; do
    echo "Waiting for ACR password to be available..."
    sleep 5
    AZURE_CONTAINER_REGISTRY_URL=$(az acr show --name $CONTAINER_REGISTRY --query loginServer -o tsv)
done
echo "REGISTRY_URL=$AZURE_CONTAINER_REGISTRY_URL"

# Build the images
mvn clean package

az acr login --name $CONTAINER_REGISTRY

cd VehicleRegistrationService
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/$VEHICLE_REGISTRATION_SERVICE:$IMAGE_TAG
docker push $AZURE_CONTAINER_REGISTRY_URL/$VEHICLE_REGISTRATION_SERVICE:$IMAGE_TAG

cd ../FineCollectionService
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/$FINE_COLLECTION_SERVICE:$IMAGE_TAG
docker push $AZURE_CONTAINER_REGISTRY_URL/$FINE_COLLECTION_SERVICE:$IMAGE_TAG

cd ../TrafficControlService
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/$TRAFFIC_CONTROL_SERVICE:$IMAGE_TAG
docker push $AZURE_CONTAINER_REGISTRY_URL/$TRAFFIC_CONTROL_SERVICE:$IMAGE_TAG

cd ../Simulation
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/simulation:$IMAGE_TAG
docker push $AZURE_CONTAINER_REGISTRY_URL/simulation:$IMAGE_TAG
cd ..

# Create the COSMOS DB
az cosmosdb create --resource-group $RESOURCE_GROUP --name $COSMOS_DB --locations regionName=$LOCATION failoverPriority=0 isZoneRedundant=False
az cosmosdb sql database create --resource-group $RESOURCE_GROUP --account-name $COSMOS_DB --name $COSMOS_DB_DATABASE
az cosmosdb sql container create --resource-group $RESOURCE_GROUP --account-name $COSMOS_DB --database-name $COSMOS_DB_DATABASE --name $COSMOS_DB_DATABASE_CONTAINER --partition-key-path /partitionKey --throughput 400

COSMOS_DB_ACCOUNT_URL=$(az cosmosdb show --resource-group $RESOURCE_GROUP --name $COSMOS_DB --query documentEndpoint -o tsv)
while [ -z "$COSMOS_DB_ACCOUNT_URL" ] ; do
    echo "Waiting for Cosmos DB account url to be available..."
    sleep 5
    COSMOS_DB_ACCOUNT_URL=$(az cosmosdb show --resource-group $RESOURCE_GROUP --name $COSMOS_DB --query documentEndpoint -o tsv)
done
echo "COSMOS_DB_ACCOUNT_URL=$COSMOS_DB_ACCOUNT_URL"

COSMOS_DB_ACCOUNT_KEY=$(az cosmosdb keys list --resource-group $RESOURCE_GROUP --name $COSMOS_DB --type keys --query primaryMasterKey -o tsv)
while [ -z "$COSMOS_DB_ACCOUNT_KEY" ] ; do
    echo "Waiting for Cosmos DB account key to be available..."
    sleep 5
    COSMOS_DB_ACCOUNT_KEY=$(az cosmosdb keys list --resource-group $RESOURCE_GROUP --name $COSMOS_DB --type keys --query primaryMasterKey -o tsv)
done
echo "COSMOS_DB_ACCOUNT_KEY=$COSMOS_DB_ACCOUNT_KEY"

# Create Azure Service Bus
az servicebus namespace create --resource-group $RESOURCE_GROUP --name $SERVICE_BUS --location $LOCATION --sku Standard
az servicebus topic create --resource-group $RESOURCE_GROUP --namespace-name $SERVICE_BUS --name $SERVICE_BUS_TOPIC
az servicebus topic authorization-rule create --resource-group $RESOURCE_GROUP --namespace-name $SERVICE_BUS --topic-name $SERVICE_BUS_TOPIC --name $SERVICE_BUS_TOPIC_AUTHORIZATION_RULE --rights Manage Send Listen

SERICE_BUS_CONNECTION_STRING=$(az servicebus topic authorization-rule keys list --resource-group $RESOURCE_GROUP --namespace-name $SERVICE_BUS --topic $SERVICE_BUS_TOPIC --name $SERVICE_BUS_TOPIC_AUTHORIZATION_RULE --query primaryConnectionString -o tsv)
while [ -z "$SERICE_BUS_CONNECTION_STRING" ] ; do
    echo "Waiting for Service Bus connection string to be available..."
    sleep 5
    SERICE_BUS_CONNECTION_STRING=$(az servicebus topic authorization-rule keys list --resource-group $RESOURCE_GROUP --namespace-name $SERVICE_BUS --topic $SERVICE_BUS_TOPIC --name $SERVICE_BUS_TOPIC_AUTHORIZATION_RULE --query primaryConnectionString -o tsv)
done
echo "SERICE_BUS_CONNECTION_STRING=$SERICE_BUS_CONNECTION_STRING"

# Create Azure AD Application
az ad app create --display-name $AZURE_AD_APPLICATION

AZ_AD_APPLICATION_ID=$(az ad app list --display-name $AZURE_AD_APPLICATION --query [].appId -o tsv)
while [ -z "$AZ_AD_APPLICATION_ID" ] ; do
    echo "Waiting for Azure AD Application id to be available..."
    sleep 5
    AZ_AD_APPLICATION_ID=$(az ad app list --display-name $AZURE_AD_APPLICATION --query [].appId -o tsv)
done
echo "AZ_AD_APPLICATION_ID=$AZ_AD_APPLICATION_ID"

AZ_AD_APPLICATION_CREDENTIALS=$(az ad app credential reset --id $AZ_AD_APPLICATION_ID --years 2)
while [ -z "$AZ_AD_APPLICATION_CREDENTIALS" ] ; do
    echo "Waiting for Azure AD Application credentials to be available..."
    sleep 5
    AZ_AD_APPLICATION_CREDENTIALS=$(az ad app credential reset --id $AZ_AD_APPLICATION_ID --years 2)
done

AZ_AD_APPLICATION_PASSWORD=$(echo $AZ_AD_APPLICATION_CREDENTIALS | jq -r '.password')
echo "AZ_AD_APPLICATION_PASSWORD=$AZ_AD_APPLICATION_PASSWORD"

AZ_AD_APPLICATION_TENANT=$(echo $AZ_AD_APPLICATION_CREDENTIALS | jq -r '.tenant')
echo "AZ_AD_APPLICATION_TENANT=$AZ_AD_APPLICATION_TENANT"

# Create Azure AD Service Principal
az ad sp create --id $AZ_AD_APPLICATION_ID

AZ_AD_APPLICATION_SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name $AZURE_AD_APPLICATION --query [].id -o tsv)
while [ -z "$AZ_AD_APPLICATION_SERVICE_PRINCIPAL_ID" ] ; do
    echo "Waiting for Service Principal id to be available..."
    sleep 5
    AZ_AD_APPLICATION_SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name $AZURE_AD_APPLICATION --query [].id -o tsv)
done

# Create Azure Keyvault and assign roles to the service principal
az keyvault create --resource-group $RESOURCE_GROUP --name $AZURE_KEYVAULT --location $LOCATION --enable-rbac-authorization true
az role assignment create --role "Key Vault Secrets User" --assignee $AZ_AD_APPLICATION_SERVICE_PRINCIPAL_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$AZURE_KEYVAULT

# Assign Key Vault Secrets Officer role to your user account
USER_ID=$(az ad user show --id $YOUR_EMAIL --query id -o tsv)
while [ -z "$USER_ID" ] ; do
    echo "Waiting for User id to be available..."
    sleep 5
    USER_ID=$(az ad user show --id $YOUR_EMAIL --query id -o tsv)
done
echo "USER_ID=$USER_ID"

az role assignment create --role "Key Vault Secrets Officer" --assignee $USER_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$AZURE_KEYVAULT

# Create the secret in the keyvault
az keyvault secret set --vault-name $AZURE_KEYVAULT --name license-key --value HX783-5PN1G-CRJ4A-K2L7V # License key
az keyvault secret set --vault-name $AZURE_KEYVAULT --name cosmos-db-account-url --value $COSMOS_DB_ACCOUNT_URL # Cosmos DB Account URL
az keyvault secret set --vault-name $AZURE_KEYVAULT --name cosmos-db-account-key --value $COSMOS_DB_ACCOUNT_KEY # Cosmos DB Account Key
az keyvault secret set --vault-name $AZURE_KEYVAULT --name service-bus-connection-string --value $SERICE_BUS_CONNECTION_STRING # Service Bus Connection String

# Create the Container Apps
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file ./.azure/container-apps.bicep \
    --parameters \
        containerAppsEnvironmentName=$CONTAINER_APPS_ENVIRONMENT \
        logAnalyticsWorkspaceName=$LOGS_ANALYTICS_WORKSPACE \
        appInsightsName=$PROJECT \
        keyvaultName=$AZURE_KEYVAULT \
        keyvaultClientId=$AZ_AD_APPLICATION_ID \
        keyvaultClientSecret=$AZ_AD_APPLICATION_PASSWORD \
        seviceBusConnectionStringKeyvaultSecretName="service-bus-connection-string" \
        serviceBusConnectionString=$SERICE_BUS_CONNECTION_STRING \
        serviceBusTopicName="test" \
        cosmosDbDatabaseName=$COSMOS_DB_DATABASE \
        cosmosDbCollectionName=$COSMOS_DB_DATABASE_CONTAINER \
        cosmosDbAccountKeyKeyvaultSecretName="cosmos-db-account-key" \
        cosmosDbAccountUrlKeyvaultSecretName="cosmos-db-account-url" \
        containerRegistryName=$CONTAINER_REGISTRY \
        tag=$IMAGE_TAG

# TODO create the Dapr components and put the secrets in the keyvault
# TODO Add Keda with Azure Service Bus for Fine Collection Service
# TODO update app insights name
