# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #

function Write-New-File {
  Write-Output "# Set variables script" | Out-File -FilePath .\set-vars.ps1
}

function Write-To-File($Text) {
  Write-Output $Text | Out-File -FilePath .\set-vars.ps1 -Append
}

function Write-Blank-Line {
  Write-To-File ""
}

function Write-Variable {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [string]$Value
  )
  $ValueToSet = ""
  if ($Value) {
    $ValueToSet = "$Value"
  }

  Write-To-File "Set-Variable -Name `"$Name`" -Value `"$ValueToSet`" -Scope `"Global`""
  Write-To-File "Write-Output `"$Name=`$$Name`""
  Write-Blank-Line
}

function Write-Environment-Variable {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [string]$Value
  )
  $ValueToSet = ""
  if ($Value) {
    $ValueToSet = "`"$Value`""
  }

  Write-To-File "`$env:$Name = $ValueToSet"
  Write-To-File "Write-Output `"$Name=`$env:$Name`""
  Write-Blank-Line
}

# ---------------------------------------------------------------------------- #
#                                 FILE CREATION                                #
# ---------------------------------------------------------------------------- #

Write-New-File
Write-Blank-Line

# ---------------------------- Supporting Services --------------------------- #

$SubscriptionId = az account show --query id -o tsv
Write-Variable -Name "SUBSCRIPTION" -Value "$SubscriptionId"

Write-Variable -Name "SERVICE_BUS" -Value "$SERVICE_BUS"
Write-Variable -Name "SERVICE_BUS_ID" -Value "$SERVICE_BUS_ID"

if ($SERVICE_BUS) {
  $ServiceBusConnectionString = az servicebus topic authorization-rule keys list --resource-group rg-dapr-workshop-java --namespace-name $SERVICE_BUS --topic-name test --name DaprWorkshopJavaAuthRule  --query primaryConnectionString --output tsv
  Write-Variable -Name "SERVICE_BUS_CONNECTION_STRING" -Value "$ServiceBusConnectionString"
} else {
  Write-Variable -Name "SERVICE_BUS_CONNECTION_STRING"
}

Write-Variable -Name "REDIS" -Value "$REDIS"
Write-Variable -Name "REDIS_HOSTNAME" -Value "$REDIS_HOSTNAME"
Write-Variable -Name "REDIS_SSL_PORT" -Value "$REDIS_SSL_PORT"
Write-Variable -Name "REDIS_PRIMARY_KEY" -Value "$REDIS_PRIMARY_KEY"

Write-Variable -Name "LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID" -Value "$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID"
Write-Variable -Name "LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET" -Value "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"

Write-Variable -Name "INSTRUMENTATION_KEY" -Value "$INSTRUMENTATION_KEY"

Write-Variable -Name "CONTAINER_REGISTRY" -Value "$CONTAINER_REGISTRY"
Write-Variable -Name "CONTAINER_REGISTRY_ID" -Value "$CONTAINER_REGISTRY_ID"
Write-Variable -Name "CONTAINER_REGISTRY_URL" -Value "$CONTAINER_REGISTRY_URL"

Write-Variable -Name "COSMOS_DB" -Value "$COSMOS_DB"

# Key Vault Application and Service pincipal used to access Key Vault with credentials
Write-Variable -Name "APP_ID" -Value "$APP_ID"
Write-Variable -Name "SERVICE_PRINCIPAL_ID" -Value "$SERVICE_PRINCIPAL_ID"

Write-Variable -Name "KEY_VAULT" -Value "$KEY_VAULT"
Write-Variable -Name "KEY_VAULT_ID" -Value "$KEY_VAULT_ID"

# ---------------------------- Managed Identities ---------------------------- #

Write-Variable -Name "ACR_PULL_UMI_ID" -Value "$ACR_PULL_UMI_ID"
Write-Variable -Name "ACR_PULL_UMI_PRINCIPAL_ID" -Value "$ACR_PULL_UMI_PRINCIPAL_ID"

Write-Variable -Name "SERVICE_BUS_UMI_PRINCIPAL_ID" -Value "$SERVICE_BUS_UMI_PRINCIPAL_ID"

Write-Variable -Name "FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID" -Value "$FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID"
Write-Variable -Name "TRAFFIC_CONTROL_SERVICE_SMI_PRINCIPAL_ID" -Value "$TRAFFIC_CONTROL_SERVICE_SMI_PRINCIPAL_ID"

# ----------------------------------- Apps ----------------------------------- #

Write-Variable -Name "VEHICLE_REGISTRATION_SERVICE_FQDN" -Value "$VEHICLE_REGISTRATION_SERVICE_FQDN"
Write-Variable -Name "TRAFFIC_CONTROL_SERVICE_FQDN" -Value "$TRAFFIC_CONTROL_SERVICE_FQDN"
Write-Environment-Variable -Name "TRAFFIC_CONTROL_SERVICE_BASE_URL" -Value "https://$TRAFFIC_CONTROL_SERVICE_FQDN"
