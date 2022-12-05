---
title: Reference a secret in components
parent: Use Azure Keyvault as a secret store
has_children: false
nav_order: 3
---

# Part 3 - Reference a secret in components

Previously, you have created an Azure Key Vault and added the Dapr component. Now, you will use the secret in the application. If the setup of the Azure Key Vault is not done yet, please follow the instructions in `Part 1 - Setup Azure Key Vault as a secret store`.

This bonus assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/) to store the connection string of the Azure Service Bus.

{: .note }
> The assignment 3 with Azure Service Bus is a prerequisite for the assignment.

## Step 1: Create a secret in the Azure Key Vault for the connetion string

Azure Service Bus' connection string will be store as a string/literal secret:

1. Open a terminal window.
   
1. Create a secret in the Azure Key Vault for Azure Service Bus' connection string:
    ```azurecli
    az keyvault secret set --vault-name kv-dapr-java-workshop --name azSericeBusconnectionString --value "<connection-string>"
    ```
    Replace `<connection-string>` with the connection string of the Azure Service Bus created in assignement 3.

## Step 2: Use the secret in the application `FineCollectionService`

1. Open the file `dapr/components/azure-servicebus-pubsub.yaml` (created in assignment 3) in your code editor, and inspect it

1. **Replace** value:

    ```yaml
    value: "Endpoint=sb://{ServiceBusNamespace}.servicebus.windows.net/;SharedAccessKeyName={PolicyName};SharedAccessKey={Key};EntityPath={ServiceBus}"
    ```
    with:

    ```yaml
    secretKeyRef:
        name: azSericeBusconnectionString
        key: azSericeBusconnectionString
    ```
    When the secret is a string/literal, the `key` is the same as the `name` of the secret, see [How-To: Reference secrets in components](https://docs.dapr.io/operations/components/component-secrets/).

1. **Add** the following lines before `scopes:`:
    
    ```yaml
    auth:
      secretStore: secretstore
    ```
    This tells Dapr to use the secret store component `secretstore` to retrieve the secret.


## Step 3: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```console
   mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:
   
    * Ensure you have run `dapr init` command prior to running the below command

    ```console
    dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
    ```

1. Open a **new** terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService with a Dapr sidecar:

   ```console
   dapr run --app-id trafficcontrolservice --app-port 6000 --dapr-http-port 3600 --dapr-grpc-port 60000 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```console
   mvn spring-boot:run
   ```

You should see the same logs as **Assignment 3** with Azure Service Bus. Obviously, the behavior of the application is exactly the same as before.