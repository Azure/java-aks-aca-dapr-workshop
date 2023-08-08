<!-- Require 'stepNumber' as input: the number of the first step of this include.
Return the number of the last step in this include -->
## Step {{stepNumber}}: Build and redeploy traffic control service

In this step, you will rebuild and redeploy the `TrafficControlService` to use the Azure Cosmos DB state store instead of keeping the state in memory.

1. Delete the image from local docker:

    ```bash
    docker rmi traffic-control-service:1.0-SNAPSHOT
    ```

1. In the root folder of `TrafficControlService`, run the following command to build and push the image:

    ```bash
    mvn spring-boot:build-image
    docker tag traffic-control-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/traffic-control-service:2.0"
    docker push "$CONTAINER_REGISTRY.azurecr.io/traffic-control-service:2.0"
    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry.

1. Update `TrafficControlService` container with the new image:

    ```bash
    az containerapp update \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY.azurecr.io/traffic-control-service:2.0"
    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry.

<!-- -------------------------------- TEST --------------------------------- -->

{% assign stepNumber = stepNumber | plus: 1 %}
{% include 05-assignment-5-aks-aca/02-aca/0-3-test-application.md %}

Check Application Map of Application Insights in Azure Portal to see the connection between the `TrafficControlService` and the `aca-azure-cosmosdb-statestore`. Check in Azure Portal the data in Cosmos DB.
