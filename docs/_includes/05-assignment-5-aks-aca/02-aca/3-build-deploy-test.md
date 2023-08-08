<!-- Require 'stepNumber' as input: the number of the first step of this include.
Return the number of the last step in this include -->
## Step {{stepNumber}} - Generate Docker images for applications, and push them to ACR

Since you don't have any container images ready yet, we'll build and push container images in Azure Container Registry (ACR) to get things running.

1. Login to your ACR repository

    ```bash
    az acr login --name $CONTAINER_REGISTRY
    ```

2. In the root folder of VehicleRegistrationService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag vehicle-registration-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/vehicle-registration-service:1.0"
    docker push "$CONTAINER_REGISTRY.azurecr.io/vehicle-registration-service:1.0"
    ```

3. In the root folder of FineCollectionService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:1.0"
    docker push "$CONTAINER_REGISTRY.azurecr.io/fine-collection-service:1.0"
    ```

4. In the root folder of TrafficControlService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag traffic-control-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY.azurecr.io/traffic-control-service:1.0"
    docker push "$CONTAINER_REGISTRY.azurecr.io/traffic-control-service:1.0"
    ```

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}} - Deploy the Container Apps

Now that you have created the container apps environment and push the images, you can create the container apps. A container app is a containerized application that is deployed to a container apps environment. 

You will create three container apps, one for each of our Java services: `TrafficControlService`, `FineCollectionService` and `VehicleRegistrationService`.

1. Create a Container App for `VehicleRegistrationService` with the following command:
  
    ```bash
    az containerapp create \
      --name ca-vehicle-registration-service \
      --resource-group rg-dapr-workshop-java \
      --environment cae-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY_URL/vehicle-registration-service:1.0" \
      --target-port 6002 \
      --ingress internal \
      --min-replicas 1 \
      --max-replicas 1
    ```

    Notice that internal ingress is enable. This is because we want to provide access to the service only from within the container apps environment. FineCollectionService will be able to access the VehicleRegistrationService using the internal ingress FQDN.

1. Get the FQDN of `VehicleRegistrationService` and save it in a variable:
  
    - Linux/Unix shell:

      ```bash
      VEHICLE_REGISTRATION_SERVICE_FQDN=$(az containerapp show \
        --name ca-vehicle-registration-service \
        --resource-group rg-dapr-workshop-java \
        --query "properties.configuration.ingress.fqdn" \
        -o tsv)
      echo $VEHICLE_REGISTRATION_SERVICE_FQDN
      ```

    - Powershell:

      ```powershell
      $VEHICLE_REGISTRATION_SERVICE_FQDN = az containerapp show `
        --name ca-vehicle-registration-service `
        --resource-group rg-dapr-workshop-java `
        --query "properties.configuration.ingress.fqdn" `
        -o tsv
      $VEHICLE_REGISTRATION_SERVICE_FQDN
      ```
    
    Notice that the FQDN is in the format `<service-name>.internal.<unique-name>.<region>.azurecontainerapps.io` where internal indicates that the service is only accessible from within the container apps environment, i.e. exposed with internal ingress.

1. Create a Container App for `FineCollectionService` with the following command:
  
    ```bash
    az containerapp create \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --environment cae-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY_URL/fine-collection-service:1.0" \
      --min-replicas 1 \
      --max-replicas 1 \
      --enable-dapr \
      --dapr-app-id fine-collection-service \
      --dapr-app-port 6001 \
      --dapr-app-protocol http \
      --env-vars "VEHICLE_REGISTRATION_SERVICE_BASE_URL=https://$VEHICLE_REGISTRATION_SERVICE_FQDN"
    ```

1. Create a Container App for `TrafficControlService` with the following command:
  
    ```bash
    az containerapp create \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --environment cae-dapr-workshop-java \
      --image "$CONTAINER_REGISTRY_URL/traffic-control-service:1.0" \
      --target-port 6000 \
      --ingress external \
      --min-replicas 1 \
      --max-replicas 1 \
      --enable-dapr \
      --dapr-app-id traffic-control-service \
      --dapr-app-port 6000 \
      --dapr-app-protocol http
    ```

1. Get the FQDN of traffic control service and save it in a variable:

    - Linux/Unix shell:
   
      ```bash
      TRAFFIC_CONTROL_SERVICE_FQDN=$(az containerapp show \
        --name ca-traffic-control-service \
        --resource-group rg-dapr-workshop-java \
        --query "properties.configuration.ingress.fqdn" \
        -o tsv)
      echo $TRAFFIC_CONTROL_SERVICE_FQDN
      ```
    
    - Powershell:

      ```powershell
      $TRAFFIC_CONTROL_SERVICE_FQDN = $(az containerapp show `
        --name ca-traffic-control-service `
        --resource-group rg-dapr-workshop-java `
        --query "properties.configuration.ingress.fqdn" `
        -o tsv)
      $TRAFFIC_CONTROL_SERVICE_FQDN
      ```

    Notice that the FQDN is in the format `<service-name>.<unique-name>.<region>.azurecontainerapps.io` where internal is not present. Indeed, traffic control service is exposed with external ingress, i.e. it is accessible from outside the container apps environment. It will be used by the simulation to test the application.

<!-- -------------------------------- TEST --------------------------------- -->

{% assign stepNumber = stepNumber | plus: 1 %}
{% include 05-assignment-5-aks-aca/02-aca/0-3-test-application.md %}
