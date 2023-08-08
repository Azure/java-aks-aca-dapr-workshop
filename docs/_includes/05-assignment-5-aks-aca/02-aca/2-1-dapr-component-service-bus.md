In [Assignment 3 - Using Dapr for pub/sub with Azure Service Bus]({{ site.baseurl }}{% link {{include.linkToAssignment3}} %}), you copied the file `dapr/azure-servicebus-pubsub.yaml` to `dapr/components` folder and updated the `connectionString` value. This file was used to deploy the `pubsub` Dapr component.

The [Dapr component schema for Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#component-schema) is different from the standard Dapr component yaml schema. It has been slightly simplified. Hence the need for a new component yaml file.

1. Open the file `dapr/aca-azure-servicebus-pubsub.yaml` in your code editor.

    ```yaml
    componentType: pubsub.azure.servicebus
    version: v1
    metadata:
      - name: connectionString
        value: "Endpoint=sb://{ServiceBusNamespace}.servicebus.windows.net/;SharedAccessKeyName={PolicyName};SharedAccessKey={Key};EntityPath={ServiceBus}"
    scopes:
      - traffic-control-service
      - fine-collection-service
    ```

2. **Copy or Move** this file `dapr/aca-servicebus-pubsub.yaml` to `dapr/components` folder.

3. **Replace** the `connectionString` value with the value you set in `dapr/components/azure-servicebus-pubsub.yaml` in [Assignment 3 - Using Dapr for pub/sub with Azure Service Bus]({{ site.baseurl }}{% link {{include.linkToAssignment3}} %}).

4. Go to the root folder of the repository.

5. Enter the following command to deploy the `pubsub` Dapr component:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name pubsub \
      --yaml ./dapr/components/aca-azure-servicebus-pubsub.yaml
    ```
