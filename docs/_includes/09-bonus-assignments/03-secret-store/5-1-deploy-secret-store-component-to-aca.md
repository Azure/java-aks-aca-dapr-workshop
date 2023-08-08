## Step {{stepNumber}}: Deploy Azure Key Vault secret store component

1. **Copy or Move** this file `dapr/aca-azure-keyvault-secretstore.yam` to `dapr/components/` folder.

1. Open the copied file `dapr/components/aca-azure-keyvault-secretstore.yaml` in your code editor.

1. Set the following values in the metadata section of the component:
   
    - `vaultName`: The name of the Azure Key Vault you created in step 3.
    - `azureTenantId`: The value for `tenant` you noted down in step 1.
    - `azureClientId`: The value for `appId` you noted down in step 1.

1. Set the following values in the secrets section of the component:
   
    - `azure-client-secret`: The value for `password` you noted down in step 1.

1. Go to the root folder of the repository.

1. Enter the following command to deploy the `secretstore` Dapr component:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name secretstore \
      --yaml ./dapr/components/aca-azure-keyvault-secretstore.yaml
    ```

{: .important-title }
> Managed Identity
> 
> By setting a secret in a Dapr component for Azure Container Apps environmnet, the secret is stored [using platform-managed Kubernetes secrets](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#using-platform-managed-kubernetes-secrets). This is useful when connecting non-Azure services or in DEV/TEST scenarios for quickly deployment Dapr components.
> 
> In production scenarios, it is recommended to use [Azure Key Vault secret store](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/) with a [managed identity](https://docs.dapr.io/developing-applications/integrations/azure/azure-authentication/authenticating-azure/#about-authentication-with-azure-ad) instead and to not store secrets as Kubernetes secrets.
>

