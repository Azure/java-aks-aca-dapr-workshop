#!/bin/sh

# ---------------------------------------------------------------------------- #
#                                   VARIABLES                                  #
# ---------------------------------------------------------------------------- #

LOCATION=eastus

# Do not change below variables
UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)

RESOURCE_GROUP=rg-dapr-workshop-java
SERVICE_BUS="sb-dapr-workshop-java-$UNIQUE_IDENTIFIER"
CONTAINER_REGISTRY="crdaprworkshopjava$UNIQUE_IDENTIFIER"
COSMOS_DB="cosno-dapr-workshop-java-$UNIQUE_IDENTIFIER"
KEY_VAULT="kv-daprworkshopjava$UNIQUE_IDENTIFIER"

SUBSCRIPTION=$(az account show --query id -o tsv)


# ---------------------------------------------------------------------------- #
#                                   RESOURCES                                  #
# ---------------------------------------------------------------------------- #

# ------------------------------ RESOURCE GROUP ------------------------------ #

az group create --name $RESOURCE_GROUP --location $LOCATION

# -------------------------------- SERVICE BUS ------------------------------- #

# Namespace
az servicebus namespace create --resource-group $RESOURCE_GROUP --name $SERVICE_BUS --location $LOCATION
# Topic
az servicebus topic create --resource-group $RESOURCE_GROUP --namespace-name $SERVICE_BUS --name test
# Authorization Rule
az servicebus topic authorization-rule create --resource-group $RESOURCE_GROUP --namespace-name $SERVICE_BUS --topic-name test --name DaprWorkshopJavaAuthRule --rights Manage Send Listen
# Connection String
SERVICE_BUS_CONNECTION_STRING=$(az servicebus topic authorization-rule keys list --resource-group $RESOURCE_GROUP --namespace-name $SERVICE_BUS --topic-name test --name DaprWorkshopJavaAuthRule  --query primaryConnectionString --output tsv)
echo SERVICE_BUS_CONNECTION_STRING=$SERVICE_BUS_CONNECTION_STRING

# ------------------------------- AZURE MONITOR ------------------------------ #

# Azure Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --workspace-name log-dapr-workshop-java
# Customner id
LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=$(
  az monitor log-analytics workspace show \
    --resource-group $RESOURCE_GROUP \
    --workspace-name log-dapr-workshop-java \
    --query customerId  \
    --output tsv | tr -d '[:space:]'
)
echo "LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID"
# Client secret
LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$(
  az monitor log-analytics workspace get-shared-keys \
    --resource-group $RESOURCE_GROUP \
    --workspace-name log-dapr-workshop-java \
    --query primarySharedKey \
    --output tsv | tr -d '[:space:]'
)
echo "LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"

# --------------------------- APPLICATION INSIGHTS --------------------------- #

# Application Insights
az monitor app-insights component create --app appi-dapr-workshop-java --location $LOCATION --kind web -g $RESOURCE_GROUP --application-type web
# Instrumentation Key
INSTRUMENTATION_KEY=$(az monitor app-insights component show --app appi-dapr-workshop-java -g $RESOURCE_GROUP --query instrumentationKey)
echo $INSTRUMENTATION_KEY

# ------------------------- AZURE CONTAINER REGISTRY ------------------------- #

# Creation
az acr create \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --name "$CONTAINER_REGISTRY" \
  --workspace log-dapr-workshop-java \
  --sku Standard \
  --admin-enabled true
# Add anonymous pull
az acr update \
  --resource-group $RESOURCE_GROUP \
  --name "$CONTAINER_REGISTRY" \
  --anonymous-pull-enabled true
# Container Registry URL
CONTAINER_REGISTRY_URL=$(
  az acr show \
    --resource-group $RESOURCE_GROUP \
    --name "$CONTAINER_REGISTRY" \
    --query "loginServer" \
    --output tsv
)
echo "CONTAINER_REGISTRY_URL=$CONTAINER_REGISTRY_URL"

# --------------------- AZURE CONTAINER APPS ENVIRONMENT --------------------- #

az containerapp env create \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --name cae-dapr-workshop-java \
  --logs-workspace-id "$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID" \
  --logs-workspace-key "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET" \
  --dapr-instrumentation-key "$INSTRUMENTATION_KEY"

# --------------------------------- COSMOS DB -------------------------------- #

# Cosmos DB Account
az cosmosdb create --name $COSMOS_DB --resource-group $RESOURCE_GROUP --locations regionName=$LOCATION failoverPriority=0 isZoneRedundant=False
# Database
az cosmosdb sql database create --account-name $COSMOS_DB --resource-group $RESOURCE_GROUP --name dapr-workshop-java-database
# Container
az cosmosdb sql container create --account-name $COSMOS_DB --resource-group $RESOURCE_GROUP --database-name dapr-workshop-java-database --name vehicle-state --partition-key-path /partitionKey --throughput 400

# ------------------------------ AZURE KEY VAULT ----------------------------- #

# Azure AD Application
az ad app create --display-name dapr-java-workshop-fine-collection-service
APP_ID=$(az ad app list --display-name dapr-java-workshop-fine-collection-service --query [].appId -o tsv)
echo "APP_ID=$APP_ID"
# Service Principal
az ad sp create --id $APP_ID
SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name dapr-java-workshop-fine-collection-service --query [].id -o tsv)
echo "SERVICE_PRINCIPAL_ID=$SERVICE_PRINCIPAL_ID"
# Key Vault
az keyvault create --name $KEY_VAULT --resource-group $RESOURCE_GROUP --location $LOCATION --enable-rbac-authorization true
# Role Assignment
az role assignment create --role "Key Vault Secrets User" --assignee $SERVICE_PRINCIPAL_ID --scope "/subscriptions/$SUBSCRIPTION/resourcegroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT"

# ---------------------------------------------------------------------------- #
#                            WRITE VARIABLES TO FILE                           #
# ---------------------------------------------------------------------------- #

. ./scripts/export-variables.sh
