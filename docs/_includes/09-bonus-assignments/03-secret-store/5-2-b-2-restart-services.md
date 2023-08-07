1. Run the following command to identify the running revision of fine collection service container apps:

    - Linux/Unix shell:

      ```bash
      FINE_COLLECTION_SERVICE_REVISION=$(az containerapp revision list -n ca-fine-collection-service -g rg-dapr-workshop-java --query "[0].name" -o tsv)
      echo $FINE_COLLECTION_SERVICE_REVISION
      ```

    - Powershell:

      ```powershell
      $FINE_COLLECTION_SERVICE_REVISION = az containerapp revision list -n ca-fine-collection-service -g rg-dapr-workshop-java --query "[0].name" -o tsv
      $FINE_COLLECTION_SERVICE_REVISION
      ```

1. Restart fine collection service revision:

    ```bash
    az containerapp revision restart \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --revision $FINE_COLLECTION_SERVICE_REVISION
    ```

1. Run the following command to identify the running revision of traffic control service container apps:

    - Linux/Unix shell:

      ```bash
      TRAFFIC_CONTROL_SERVICE_REVISION=$(az containerapp revision list -n ca-traffic-control-service -g rg-dapr-workshop-java --query "[0].name" -o tsv)
      echo $TRAFFIC_CONTROL_SERVICE_REVISION
      ```

    - Powershell:

      ```powershell
      $TRAFFIC_CONTROL_SERVICE_REVISION = az containerapp revision list -n ca-traffic-control-service -g rg-dapr-workshop-java --query "[0].name" -o tsv
      $TRAFFIC_CONTROL_SERVICE_REVISION
      ```

1. Restart traffic control service revision:

    ```bash
    az containerapp revision restart \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --revision $TRAFFIC_CONTROL_SERVICE_REVISION
    ```
