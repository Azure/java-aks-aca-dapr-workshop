#!/bin/bash

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #

writeNewFile() {
  echo "#!/bin/bash" > set-vars.sh
}

writeToFile() {
  local text=$1
  echo "$text" >> set-vars.sh
}

writeBlankLine() {
  writeToFile ""
}

writeVariable() {
  local variableName=$1
  local variableValue=$2
  writeToFile "$variableName=\"$2\""
  writeToFile "echo \"$variableName=\$$variableName\""
  writeBlankLine
}

writeEnvironmentVariable() {
  local variableName=$1
  local variableValue=$2
  writeToFile "export $variableName=\"$2\""
  writeToFile "echo \"$variableName=\$$variableName\""
  writeBlankLine
}

# ---------------------------------------------------------------------------- #
#                                 FILE CREATION                                #
# ---------------------------------------------------------------------------- #

writeNewFile
writeBlankLine

# ---------------------------- Supporting Services --------------------------- #

writeVariable "SUBSCRIPTION" "$(az account show --query id -o tsv)"

writeVariable "SERVICE_BUS" "$SERVICE_BUS"
writeVariable "SERVICE_BUS_ID" "$SERVICE_BUS_ID"

if [ -v SERVICE_BUS ]; then
  writeVariable "SERVICE_BUS_CONNECTION_STRING" "$(az servicebus topic authorization-rule keys list --resource-group rg-dapr-workshop-java --namespace-name $SERVICE_BUS --topic-name test --name DaprWorkshopJavaAuthRule  --query primaryConnectionString --output tsv)"
else
  writeVariable "SERVICE_BUS_CONNECTION_STRING" ""
fi

writeVariable "REDIS" "$REDIS"
writeVariable "REDIS_HOSTNAME" "$REDIS_HOSTNAME"
writeVariable "REDIS_SSL_PORT" "$REDIS_SSL_PORT"
writeVariable "REDIS_PRIMARY_KEY" "$REDIS_PRIMARY_KEY"

writeVariable "LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID" "$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID"
writeVariable "LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET" "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"

writeVariable "INSTRUMENTATION_KEY" "$INSTRUMENTATION_KEY"

writeVariable "CONTAINER_REGISTRY" "$CONTAINER_REGISTRY"
writeVariable "CONTAINER_REGISTRY_ID" "$CONTAINER_REGISTRY_ID"
writeVariable "CONTAINER_REGISTRY_URL" "$CONTAINER_REGISTRY_URL"

writeVariable "COSMOS_DB" "$COSMOS_DB"

# Key Vault Application and Service pincipal used to access Key Vault with credentials
writeVariable "APP_ID" "$APP_ID"
writeVariable "SERVICE_PRINCIPAL_ID" "$SERVICE_PRINCIPAL_ID"

writeVariable "KEY_VAULT" "$KEY_VAULT"
writeVariable "KEY_VAULT_ID" "$KEY_VAULT_ID"

# ---------------------------- Managed Identities ---------------------------- #

writeVariable "ACR_PULL_UMI_ID" "$ACR_PULL_UMI_ID"
writeVariable "ACR_PULL_UMI_PRINCIPAL_ID" "$ACR_PULL_UMI_PRINCIPAL_ID"

writeVariable "SERVICE_BUS_UMI_PRINCIPAL_ID" "$SERVICE_BUS_UMI_PRINCIPAL_ID"

writeVariable "FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID" "$FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID"
writeVariable "TRAFFIC_CONTROL_SERVICE_SMI_PRINCIPAL_ID" "$TRAFFIC_CONTROL_SERVICE_SMI_PRINCIPAL_ID"

# ----------------------------------- Apps ----------------------------------- #

writeVariable "VEHICLE_REGISTRATION_SERVICE_FQDN" "$VEHICLE_REGISTRATION_SERVICE_FQDN"
writeVariable "TRAFFIC_CONTROL_SERVICE_FQDN" "$TRAFFIC_CONTROL_SERVICE_FQDN"
writeEnvironmentVariable "TRAFFIC_CONTROL_SERVICE_BASE_URL" "https://$TRAFFIC_CONTROL_SERVICE_FQDN"
