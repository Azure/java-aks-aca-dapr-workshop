<!-- Require 'stepNumber' as input: the number of the first step of this include.
Return the number of the last step in this include -->
## Step {{stepNumber}}: Create an Azure AD application

1. Open a terminal window.
   
1. Create an Azure AD application:
   
    ```bash
    az ad app create --display-name dapr-java-workshop-fine-collection-service
    ```

1. Set the application ID in `APP_ID`:

    - Linux/Unix shell:

        ```bash
        APP_ID=$(az ad app list --display-name dapr-java-workshop-fine-collection-service --query [].appId -o tsv)
        ```

    - Powershell:

        ```powershell
        $APP_ID = az ad app list --display-name dapr-java-workshop-fine-collection-service --query [].appId -o tsv
        ```

1. Create the client secret using the following command:
   
    ```bash
    az ad app credential reset --id $APP_ID --years 2
    ```

    Take note of the values above, which will be used in the Dapr component's metadta to allow Dapr to authenticate with Azure:

    - `appId` is the value for `azureClientId`
    - `password` is the value for `azureClientSecret`
    - `tenant` is the value for `azureTenantId`

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}}: Create a Service Principal

1. Create a Service Principal using the following command and replace `<appId>` with the application ID you noted down in the previous step:
   
    ```bash
    az ad sp create --id $APP_ID
    ```

1. Set the Service Principal ID in `SERVICE_PRINCIPAL_ID`. You will need it to assign the role to access the Key Vault.

    - Linux/Unix shell:

        ```bash
        SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name dapr-java-workshop-fine-collection-service --query [].id -o tsv)
        ```

    - Powershell:

        ```powershell
        $SERVICE_PRINCIPAL_ID = az ad sp list --display-name dapr-java-workshop-fine-collection-service --query [].id -o tsv
        ```

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}}: Create an Azure Key Vault

1. Open a terminal window.

1. [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/) is a manage service to securely store and access secrets. This key vault needs to be globally unique. Use the following command to generate a unique name:

    - Linux/Unix shell:

        ```bash
        UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)
        KEY_VAULT="kv-daprworkshopjava$UNIQUE_IDENTIFIER"
        echo $KEY_VAULT
        ```
   
    - PowerShell:

        ```powershell
        $ACCEPTED_CHAR = [Char[]]'abcdefghijklmnopqrstuvwxyz0123456789'
        $UNIQUE_IDENTIFIER = (Get-Random -Count 5 -InputObject $ACCEPTED_CHAR) -join ''
        $KEY_VAULT = "kv-daprworkshopjava$UNIQUE_IDENTIFIER"
        $KEY_VAULT
        ```

    Note the name of the Key Vault. You will need it when creating the Dapr component.

1. Create an Azure Key Vault:
   
    ```bash
    az keyvault create --name $KEY_VAULT --resource-group rg-dapr-workshop-java --location eastus --enable-rbac-authorization true
    ```

1. Set the id of the subscription in `SUBSCRIPTION`. You will need it in the next step.

    - Linux/Unix shell:

        ```bash
        SUBSCRIPTION=$(az account show --query id -o tsv)
        ```

    - Powershell:

        ```powershell
        $SUBSCRIPTION = az account show --query id -o tsv
        ```

1. Assign a role using RBAC to the Azure AD application to access the Key Vault. The role "Key Vault Secrets User" is sufficient for this workshop.
   
    ```bash
    az role assignment create --role "Key Vault Secrets User" --assignee $SERVICE_PRINCIPAL_ID --scope "/subscriptions/$SUBSCRIPTION/resourcegroups/rg-dapr-workshop-java/providers/Microsoft.KeyVault/vaults/$KEY_VAULT"
    ```

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}}: Create a secret in the Azure Key Vault

The service principal created in the previous steps has the role `Key Vault Secrets User` assigned. It means this service principal can only read secrets. When assignining a role, it is recommended to use the [principle of least privilege](https://learn.microsoft.com/en-us/azure/security/fundamentals/identity-management-best-practices#use-role-based-access-control) during all stages of development and deployment. This means that in this workshop, you could have assigned the `Key Vault Secret User` to a specific role instead to the key vault itself. However, for simplicity, you assigned the role to the key vault.

To create a secret in the Azure Key Vault, you can use the Azure Portal or the Azure CLI. In this workshop, you will use the Azure CLI. First you need to assign you the role of `Key Vault Secrets Officer` to be able to create secrets in the Key Vault. To know more about the different roles, see [Azure built-in roles for Key Vault data plane operations](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations).

To assign to you the role of `Key Vault Secrets Officer`, follow these steps:

1. Open a terminal window.
   
1. Set your user id in `USER_ID`. You will need it in the next step.

    - Linux/Unix shell:

        ```bash
        USER_ID=$(az ad user show --id <your-email-address> --query id -o tsv)
        ```

    - Powershell:

        ```powershell
        $USER_ID = az ad user show --id <your-email-address> --query id -o tsv
        ```

    Replace `<your-email-address>` with your email address.

1. Assign you `Key Vault Secrets Officer` role:
   
    ```bash
    az role assignment create --role "Key Vault Secrets Officer" --assignee $USER_ID --scope "/subscriptions/$SUBSCRIPTION_ID/resourcegroups/rg-dapr-workshop-java/providers/Microsoft.KeyVault/vaults/$KEY_VAULT"
    ```
    

1. To create a secret in the Azure Key Vault, use the following command and replace `<secret-name>` and `<secret-value>` with the name and value of the secret you want to create:

    ```bash
    az keyvault secret set --vault-name $KEY_VAULT --name <secret-name> --value <secret-value>
    ```
