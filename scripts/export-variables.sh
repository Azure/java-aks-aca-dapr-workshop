#!/bin/bash

echo "#!/bin/bash" > set-vars.sh
echo "" >> set-vars.sh

# ---------------------------------------------------------------------------- #
#                              SUPPORTING SERVICES                             #
# ---------------------------------------------------------------------------- #

# ------------------------------- SUBSCRIPTION ------------------------------- #

echo "SUBSCRIPTION=\"$(az account show --query id -o tsv)\"" >> set-vars.sh
echo "echo \"SUBSCRIPTION=\$SUBSCRIPTION\"" >> set-vars.sh
echo "" >> set-vars.sh

# -------------------------------- SERVICE BUS ------------------------------- #

echo "SERVICE_BUS=$SERVICE_BUS" >> set-vars.sh
echo "echo \"SERVICE_BUS=\$SERVICE_BUS\"" >> set-vars.sh
echo "" >> set-vars.sh

if [ -v SERVICE_BUS ]; then
  echo "SERVICE_BUS_CONNECTION_STRING=\"$(az servicebus topic authorization-rule keys list --resource-group rg-dapr-workshop-java --namespace-name $SERVICE_BUS --topic-name test --name DaprWorkshopJavaAuthRule  --query primaryConnectionString --output tsv)\"" >> set-vars.sh
else
  echo "SERVICE_BUS_CONNECTION_STRING=\"\"" >> set-vars.sh
fi
echo "echo \"SERVICE_BUS_CONNECTION_STRING=\$SERVICE_BUS_CONNECTION_STRING\"" >> set-vars.sh
echo "" >> set-vars.sh

# ----------------------------------- REDIS ---------------------------------- #

echo "REDIS=\"$REDIS\"" >> set-vars.sh
echo "echo \"REDIS=\$REDIS\"" >> set-vars.sh
echo "" >> set-vars.sh

echo "REDIS_HOSTNAME=\"$REDIS_HOSTNAME\"" >> set-vars.sh
echo "echo \"REDIS_HOSTNAME=\$REDIS_HOSTNAME\"" >> set-vars.sh
echo "" >> set-vars.sh

echo "REDIS_SSL_PORT=\"$REDIS_SSL_PORT\"" >> set-vars.sh
echo "echo \"REDIS_SSL_PORT=\$REDIS_SSL_PORT\"" >> set-vars.sh
echo "" >> set-vars.sh

echo "REDIS_PRIMARY_KEY=\"$REDIS_PRIMARY_KEY\"" >> set-vars.sh
echo "echo \"REDIS_PRIMARY_KEY=\$REDIS_PRIMARY_KEY\"" >> set-vars.sh
echo "" >> set-vars.sh

# -------------------------- LOG ANALYTICS WORKSPACE ------------------------- #

echo "LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=\"$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID\"" >> set-vars.sh
echo "echo \"LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID=\$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID\"" >> set-vars.sh
echo "" >> set-vars.sh

echo "LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=\"$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET\"" >> set-vars.sh
echo "echo \"LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=\$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET\"" >> set-vars.sh
echo "" >> set-vars.sh

# --------------------------- APPLICATION INSIGHTS --------------------------- #

echo "INSTRUMENTATION_KEY=\"$INSTRUMENTATION_KEY\"" >> set-vars.sh
echo "echo \"INSTRUMENTATION_KEY=\$INSTRUMENTATION_KEY\"" >> set-vars.sh
echo "" >> set-vars.sh

# ---------------------------- CONTAINER REGISTRY ---------------------------- #

echo "CONTAINER_REGISTRY=\"$CONTAINER_REGISTRY\"" >> set-vars.sh
echo "echo \"CONTAINER_REGISTRY=\$CONTAINER_REGISTRY\"" >> set-vars.sh
echo "" >> set-vars.sh

echo "CONTAINER_REGISTRY_URL=\"$CONTAINER_REGISTRY_URL\"" >> set-vars.sh
echo "echo \"CONTAINER_REGISTRY_URL=\$CONTAINER_REGISTRY_URL\"" >> set-vars.sh
echo "" >> set-vars.sh

# --------------------------------- COSMOS DB -------------------------------- #

echo "COSMOS_DB=\"$COSMOS_DB\"" >> set-vars.sh
echo "echo \"COSMOS_DB=\$COSMOS_DB\"" >> set-vars.sh
echo "" >> set-vars.sh

# --------------------------- USER MANAGED IDENTITY -------------------------- #

echo "APP_ID=\"$APP_ID\"" >> set-vars.sh
echo "echo \"APP_ID=\$APP_ID\"" >> set-vars.sh
echo "" >> set-vars.sh

echo "SERVICE_PRINCIPAL_ID=\"$SERVICE_PRINCIPAL_ID\"" >> set-vars.sh
echo "echo \"SERVICE_PRINCIPAL_ID=\$SERVICE_PRINCIPAL_ID\"" >> set-vars.sh
echo "" >> set-vars.sh

# --------------------------------- KEY VAULT -------------------------------- #

echo "KEY_VAULT=\"$KEY_VAULT\"" >> set-vars.sh
echo "echo \"KEY_VAULT=\$KEY_VAULT\"" >> set-vars.sh
echo "" >> set-vars.sh

# ---------------------------------------------------------------------------- #
#                                     APPS                                     #
# ---------------------------------------------------------------------------- #

# ----------------------- VEHICLE REGISTRATION SERVICE ----------------------- #

echo "VEHICLE_REGISTRATION_SERVICE_FQDN=\"$VEHICLE_REGISTRATION_SERVICE_FQDN\"" >> set-vars.sh
echo "echo \"VEHICLE_REGISTRATION_SERVICE_FQDN=\$VEHICLE_REGISTRATION_SERVICE_FQDN\"" >> set-vars.sh
echo "" >> set-vars.sh

# -------------------------- TRAFFIC CONTROL SERVICE ------------------------- #

echo "TRAFFIC_CONTROL_SERVICE_FQDN=\"$TRAFFIC_CONTROL_SERVICE_FQDN\"" >> set-vars.sh
echo "echo \"TRAFFIC_CONTROL_SERVICE_FQDN=\$TRAFFIC_CONTROL_SERVICE_FQDN\"" >> set-vars.sh
echo "" >> set-vars.sh

# -------------------------------- SIMULATION -------------------------------- #

echo "export TRAFFIC_CONTROL_SERVICE_BASE_URL=https://$TRAFFIC_CONTROL_SERVICE_FQDN" >> set-vars.sh
echo "echo \"TRAFFIC_CONTROL_SERVICE_BASE_URL=\$TRAFFIC_CONTROL_SERVICE_BASE_URL\"" >> set-vars.sh
echo "" >> set-vars.sh

# ---------------------------------------------------------------------------- #
#                               CREATE EXECUTABLE                              #
# ---------------------------------------------------------------------------- #

chmod +x set-vars.sh
