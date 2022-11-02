---
title: Using Dapr for pub/sub with Azure Service Bus
parent: Assignment 3 - Using Dapr for pub/sub with other brokers
has_children: false
nav_order: 2
---

# Using Dapr for pub/sub with Azure Service Bus

Stop Simulation, TrafficControlService and FineCollectionService, and VehicleRegistrationService by pressing Crtl-C in the respective terminal windows.

## Step 1: Create Azure Service Bus 

In the example, you will use Azure Service Bus as the message broker with the Dapr pub/sub building block. You're going to create an Azure Service Bus namespace and a topic in it. To be able to do this, you need to have an Azure subscription. If you don't have one, you can create a free account at [https://azure.microsoft.com/free/](https://azure.microsoft.com/free/).

1. Login to Azure

    ```azurecli
    az login
    ```

1. Create a resource group

    ```azurecli
    az group create --name dapr-workshop-java --location eastus
    ```

1. Create a Service Bus messaging namespace

    ```azurecli
    az servicebus namespace create --resource-group dapr-workshop-java --name DaprWorkshopJavaNS --location eastus
    ```

1. Create a Service Bus topic

    ```azurecli
    az servicebus topic create --resource-group dapr-workshop-java --namespace-name DaprWorkshopJavaNS --name test
    ```

1. Create authorization rules for the Service Bus topic

    ```azurecli
    az servicebus topic authorization-rule create --resource-group dapr-workshop-java --namespace-name DaprWorkshopJavaNS --topic-name test --name DaprWorkshopJavaAuthRule --rights Manage Send Listen
    ```

1. Get the connection string for the Service Bus topic and copy it to the clipboard

    ```azurecli
    az servicebus topic authorization-rule keys list --resource-group dapr-workshop-java --namespace-name DaprWorkshopJavaNS --topic-name test --name DaprWorkshopJavaAuthRule  --query primaryConnectionString --output tsv
    ```

## Step 2: Configure the pub/sub component

1. Open the file `dapr/azure-servicebus-pubsub.yaml` in your IDE.

    ```yaml
    apiVersion: dapr.io/v1alpha1
    kind: Component
    metadata:
      name: pubsub
    spec:
      type: pubsub.azure.servicebus
      version: v1
      metadata:
      - name: connectionString # Required when not using Azure Authentication.
        value: "Endpoint=sb://{ServiceBusNamespace}.servicebus.windows.net/;SharedAccessKeyName={PolicyName};SharedAccessKey={Key};EntityPath={ServiceBus}"
    scopes:
      - trafficcontrolservice
      - finecollectionservice
    ```

    As you can see, you specify a different type of pub/sub component (`pubsub.azure.servicebus`) and you specify in the `metadata` section how to connect to Azure Service Bus created in step 1. For this workshop, you are going to use the connection string you copied in the previous step. You can also configure the component to use Azure Active Directory authentication. For more information, see [Azure Service Bus pub/sub component](https://docs.dapr.io/reference/components-reference/supported-pubsub/setup-azure-servicebus/).

    In the `scopes` section, you specify that only the TrafficControlService and FineCollectionService should use the pub/sub building block.

1. **Copy or Move** this file `dapr/azure-servicebus-pubsub.yaml` to `dapr/components` folder.

1. **Replace** the `connectionString` value with the value you copied from the clipboard.

1. **Move** the files `dapr/components/kafka-pubsub.yaml` and `dap/components/rabbit-pubsub.yaml`  back to `dapr/` folder if they are present in the component folder.

## Step 3: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```console
   mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:

   ```console
   dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService with a Dapr sidecar:

   ```console
   dapr run --app-id trafficcontrolservice --app-port 6000 --dapr-http-port 3600 --dapr-grpc-port 60000 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```console
   mvn spring-boot:run
   ```

You should see the same logs as before. Obviously, the behavior of the application is exactly the same as before. But now, instead of messages being published and subscribed via kafka topic, are being processed through RabbitMQ.

    