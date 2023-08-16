<!-- Require 'stepNumber' as input: the number of the first step of this include.
Return the number of the last step in this include -->
## Step {{stepNumber}}: Enable Dapr for Vehicle Registration Service

In this step, you will enable Dapr for the `VehicleRegistrationService` to be discoverable by the `FineCollectionService` using Dapr's service invocation building block.

`FineCollectionService` Dapr sidecar uses Vehicle Registration Service `dapr-app-id` to resolve the service invocation endpoint. The name (i.e. `dapr-app-id`) of `VehicleRegistrationService` is set in the application properties of `FineCollectionService` (i.e. `application.yaml`) as shown below:

```yaml
vehicle-registration-service.name: ${VEHICLE_REGISTRATION_SERVICE:vehicleregistrationservice}
```

The default value is `vehicleregistrationservice` that will be override using the environment variable `VEHICLE_REGISTRATION_SERVICE` to the name set in the following step:

1. Open a **new** termninale and run the following command to enable Dapr for `VehicleRegistrationService`:

    ```bash
    az containerapp dapr enable \
      --name ca-vehicle-registration-service \
      --resource-group rg-dapr-workshop-java \
      --dapr-app-id vehicle-registration-service \
      --dapr-app-port 6002 \
      --dapr-app-protocol http
    ```

1. Note the `dapr-app-id` you set in the previous step. It is used to resolve the service invocation endpoint.

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}}: Build and redeploy fine collection service

In this step, you will rebuild and redeploy the `FineCollectionService` to use the `VehicleRegistrationService` service invocation endpoint.

1. Delete the image from local docker:

    ```bash
    docker rmi fine-collection-service:1.0-SNAPSHOT
    ```

1. In the root folder of `FineCollectionService`, run the following command to build and push the image:

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:2.0"
    docker push "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:2.0"
    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry.

1. Update `FineCollectionService` container app with the new image and with the environment variable to set the name (i.e. `dapr-app-id`) of `VehicleRegistrationService`:

    ```bash
    az containerapp update \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:2.0" \
      --set-env-vars "VEHICLE_REGISTRATION_SERVICE=vehicle-registration-service" \
      --remove-env-vars "VEHICLE_REGISTRATION_SERVICE_BASE_URL"

    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry. The `VEHICLE_REGISTRATION_SERVICE_BASE_URL` is removed because it is not used anymore.

<!-- -------------------------------- TEST --------------------------------- -->

{% assign stepNumber = stepNumber | plus: 1 %}
{% include 05-assignment-5-aks-aca/02-aca/0-3-test-application.md %}

Check Application Map of Application Insights in Azure Portal to see the connection between the `FineCollectionService` and the `VehicleRegistrationService`.
