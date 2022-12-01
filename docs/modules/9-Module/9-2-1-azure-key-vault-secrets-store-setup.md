---
title: Part 1 - Setup Azure Keyvault as a secrets store
parent: Use Azure Keyvault as a secrets store
has_children: false
nav_order: 1
---

# Part 1 - Setup Azure Key Vault as a secrets store

This bonus assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/). You will create the [Azure Key Vault secret store component](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/) provided by Dapr.

## Step 1: Create an Azure AD application

1. Open a terminal window.
   
1. Create an Azure AD application
    ```azurecli
    az ad app create --display-name dapr-java-workshop-fine-collection-service
    ```

1. Get the application ID and note it down. You will need it in the next step.
    ```azurecli
    az ad app list --display-name dapr-java-workshop-fine-collection-service --query [].appId -o tsv
    ```

1. Create the client secret using the following command and replace `<appId>` with the application ID you noted down in the previous step:
    ```azurecli
    az ad app credential reset --id <appId> --years 2
    ```
    Take note of the values above, which will be used in the Dapr component's metadta to allow Dapr to authenticate with Azure:
    - `appId` is the value for `azureClientId`
    - `password` is the value for `azureClientSecret`
    - `tenant` is the value for `azureTenantId`

## Step 2: Create a Service Principal

1. Create a Service Principal using the following command and replace `<appId>` with the application ID you noted down in the previous step:
    ```azurecli
    az ad sp create --id <appId>
    ```

1. Get the Service Principal ID and note it down. You will need it to assign the role to access the Key Vault.
    ```azurecli
    az ad sp list --display-name dapr-java-workshop-fine-collection-service --query [].id -o tsv
    ```

## Step 3: Create an Azure Key Vault

1. Open a terminal window.
   
1. Create an Azure Key Vault
    ```azurecli
    az keyvault create --name kv-dapr-java-workshop --resource-group dapr-workshop-java --location eastus --enable-rbac-authorization true
    ```

1. Get the id of the subscription and note it down. You will need it in the next step.
    ```azurecli
    az account show --query id -o tsv
    ```

1. Assign a role using RBAC to the Azure AD application to access the Key Vault. The role "Key Vault Secrets User" is sufficient for this workshop. Replace `<servicePrincipalId>` with the Service Principal ID you noted down and `<subscriptionId>` with the value you noted in the previous step:
    ```azurecli
    az role assignment create --role "Key Vault Secrets User" --assignee <servicePrincipalId> --scope "/subscriptions/<subscriptionid>/resourcegroups/dapr-workshop-java/providers/Microsoft.KeyVault/vaults/kv-dapr-java-workshop"
    ```

## Step 4: Create a secret in the Azure Key Vault

The service principal created in the previous steps has the role `Key Vault Secrets User` assigned. It means this service principal can only read secrets.

To create a secret in the Azure Key Vault, you can use the Azure Portal or the Azure CLI. In this workshop, we will use the Azure CLI. First you need to assign you the role of `Key Vault Secrets Officer` to be able to create secrets in the Key Vault. To know more about the different roles, see [Azure built-in roles for Key Vault data plane operations](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations).

To assign to you the role of `Key Vault Secrets Officer`, follow these steps:

1. Open a terminal window.
   
1. Get your user id and note it down. You will need it in the next step.
    ```azurecli
    az ad user show --id <your-email-address> --query id -o tsv
    ```
    Replace `<your-email-address>` with your email address.

1. Assign you `Key Vault Secrets Officer` role:
    ```azurecli
    az role assignment create --role "Key Vault Secrets Officer" --assignee <userId> --scope "/subscriptions/<subscriptionid>/resourcegroups/dapr-workshop-java/providers/Microsoft.KeyVault/vaults/kv-dapr-java-workshop"
    ```
    Replace `<userId>` with the value you noted down in the previous step.
    

To create a secret in the Azure Key Vault, use the following command and replace `<secret-name>` and `<secret-value>` with the name and value of the secret you want to create:
    ```azurecli
    az keyvault secret set --vault-name kv-dapr-java-workshop --name <secret-name> --value <secret-value>
    ```

## Step 5: Set the Azure Key Vault secrets store component

1. **Copy or Moive** this file `dapr/azure-keyvault-secretsstore.yam` to `dapr/components/` folder.

1. Open the copied file `dapr/components/azure-keyvault-secretsstore.yaml` in your code editor.

1. Set the following values in the metadata section of the component:
    - `azureTenantId`: The value for `tenant` you noted down in step 1.
    - `azureClientId`: The value for `appId` you noted down in step 1.
    - `azureClientSecret`: The value for `password` you noted down in step 1.

{: .important }
> Certificate can be used instead of client secret, see [Azure Key Vault secret store](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/).
>
> When deployed to Azure Kubernetes Service, the client secret is a kubernetes secret and not set in the component's YAML file. See the *Kubernetes* tab in *Configure the component* of [Azure Key Vault secret store](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/).
>
> When deployed to Azure Kubernetes Service or Azure Container Apps, managed identity can be used instead of client secret. See [Using Managed Service Identities](https://docs.dapr.io/developing-applications/integrations/azure/authenticating-azure/#using-managed-service-identities).