1. Open the file `dapr/components/aca-azure-servicebus-pubsub.yaml` (created in assignment 3) in your code editor, and inspect it.

1. Add the following line after`version: v1`:

    ```yaml
    secretStoreComponent: "secretstore"
    ```

    This tells Dapr to use the secret store component `secretstore` to retrieve the secret.

1. **Replace** value:

    ```yaml
    value: "Endpoint=sb://{ServiceBusNamespace}.servicebus.windows.net/;SharedAccessKeyName={PolicyName};SharedAccessKey={Key};EntityPath={ServiceBus}"
    ```
    with:

    ```yaml
    secretRef: azSericeBusconnectionString
    ```

    This tells Dapr to use the secret `azSericeBusconnectionString` from the secret store.

    It should look like:

    ```yaml
    componentType: pubsub.azure.servicebus
    version: v1
    secretStoreComponent: "secretstore"
    metadata:
      - name: connectionString
        secretRef: azSericeBusconnectionString
    scopes:
      - traffic-control-service
      - fine-collection-service
    ```

1. **Update** Darp component using the following command in the root of the project:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name pubsub \
      --yaml ./dapr/components/aca-azure-servicebus-pubsub.yaml
    ```

{: .note }
> To know more about how to use a secret in a Dapr component with Azure Container Apps, please refer to [this documentation](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#referencing-dapr-secret-store-components).
>
