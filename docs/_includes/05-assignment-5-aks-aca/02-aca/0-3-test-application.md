<!-- Require 'stepNumber' as input: the number of the first step of this include.
Return the number of the last step in this include -->
## Step {{stepNumber}} - Run the simulation

1. Set the following environment variable:

    - Linux/Unix shell:

      ```bash
      export TRAFFIC_CONTROL_SERVICE_BASE_URL=https://$TRAFFIC_CONTROL_SERVICE_FQDN
      ```

    - Powershell:
  
      ```powershell
      $env:TRAFFIC_CONTROL_SERVICE_BASE_URL = "https://$TRAFFIC_CONTROL_SERVICE_FQDN"
      ```

1. In the root folder of the simulation (`Simulation`), start the simulation:

    ```bash
    mvn spring-boot:run
    ```

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}} - Test the microservices running in ACA

You can access the log of the container apps from the [Azure Portal](https://portal.azure.com/) or directly in a terminal window. The following steps show how to access the logs from the terminal window for each microservice.

{: .note }
> The logs can take a few minutes to appear in the Log Analytics Workspace. If the logs are not updated, open the log stream in the Azure Portal.
>


### Traffic Control Service

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

2. Run the following command to get the last 10 lines of traffic control service logs from Log Analytics Workspace:

    ```bash
    az monitor log-analytics query \
      --workspace $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID \
      --analytics-query "ContainerAppConsoleLogs_CL | where RevisionName_s == '$TRAFFIC_CONTROL_SERVICE_REVISION' | project TimeGenerated, Log_s | sort by TimeGenerated desc | take 10" \
      --out table
    ```

### Fine Collection Service

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

2. Run the following command to get the last 10 lines of fine collection service logs from Log Analytics Workspace:

    ```bash
    az monitor log-analytics query \
      --workspace $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID \
      --analytics-query "ContainerAppConsoleLogs_CL | where RevisionName_s == '$FINE_COLLECTION_SERVICE_REVISION' | project TimeGenerated, Log_s | sort by TimeGenerated desc | take 10" \
      --out table
    ```

### Vehicle Registration Service

1. Run the following command to identify the running revision of vehicle registration service container apps:

    - Linux/Unix shell:

      ```bash
      VEHICLE_REGISTRATION_SERVICE_REVISION=$(az containerapp revision list -n ca-vehicle-registration-service -g rg-dapr-workshop-java --query "[0].name" -o tsv)
      echo $VEHICLE_REGISTRATION_SERVICE_REVISION
      ```

    - Powershell:

      ```powershell
      $VEHICLE_REGISTRATION_SERVICE_REVISION = az containerapp revision list -n ca-vehicle-registration-service -g rg-dapr-workshop-java --query "[0].name" -o tsv
      $VEHICLE_REGISTRATION_SERVICE_REVISION
      ```

2. Run the following command to get the last 10 lines of vehicle registration service logs from Log Analytics Workspace:

    ```bash
    az monitor log-analytics query \
      --workspace $LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID \
      --analytics-query "ContainerAppConsoleLogs_CL | where RevisionName_s == '$VEHICLE_REGISTRATION_SERVICE_REVISION' | project TimeGenerated, Log_s | sort by TimeGenerated desc | take 10" \
      --out table
    ```
