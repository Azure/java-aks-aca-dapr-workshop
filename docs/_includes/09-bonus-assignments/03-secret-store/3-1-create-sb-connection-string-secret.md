## Step 1: Create a secret in the Azure Key Vault for the connetion string

Azure Service Bus' connection string will be store as a string/literal secret:

1. Open a terminal window.
   
1. Create a secret in the Azure Key Vault for Azure Service Bus' connection string:
   
    ```bash
    az keyvault secret set --vault-name $KEY_VAULT --name azSericeBusconnectionString --value "<connection-string>"
    ```
    Replace `<connection-string>` with the connection string of the Azure Service Bus created in assignement 3.
