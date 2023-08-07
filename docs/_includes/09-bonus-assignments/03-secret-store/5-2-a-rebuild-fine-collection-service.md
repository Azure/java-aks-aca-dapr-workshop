In this step, you will rebuild and redeploy the `FineCollectionService` to use the secret store (i.e. Azure Key Vault) to get the license key of the fine calculator.

1. Delete the image from local docker:

    ```bash
    docker rmi fine-collection-service:1.0-SNAPSHOT
    ```

1. In the root folder of `FineCollectionService`, run the following command to build and push the image:

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:3.0"
    docker push "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:3.0"
    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry.

1. Update `FineCollectionService` container app with the new image:

    ```bash
    az containerapp update \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:3.0"
    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry.