---
title: Using Dapr for pub/sub with Azure Cache for Redis
parent: Assignment 3 - Using Dapr for pub/sub with Azure Services
has_children: false
nav_order: 2
layout: default
---

# Using Dapr for pub/sub with Azure Cache for Redis
Stop Simulation, TrafficControlService and FineCollectionService, and VehicleRegistrationService by pressing Crtl-C in the respective terminal windows.

## Step 1: Create Azure Cache for Redis 

In the example, you will use Azure Cache for Redis as the message broker with the Dapr pub/sub building block. To be able to do this, you need to have an Azure subscription. If you don't have one, you can create a free account at [https://azure.microsoft.com/free/](https://azure.microsoft.com/free/).

1. Login to Azure

    ```bash
    az login
    ```

2. Create a C0 Redis Cache

    ```bash
      # Create and manage a C0 Redis Cache

      # Variable block
      let "randomIdentifier=$RANDOM*$RANDOM"
      location="East US"
      resourceGroup="rg-dapr-workshop-java"
      tag="create-manage-cache"
      cache="msdocs-redis-cache-$randomIdentifier"
      sku="basic"
      size="C0"

      # Create a resource group
      echo "Creating $resourceGroup in "$location"..."
      az group create --name $resourceGroup --location "$location" --tags $tag

      # Create a Basic C0 (256 MB) Redis Cache
      echo "Creating $cache"
      az redis create --name $cache --resource-group $resourceGroup --location "$location" --sku $sku --vm-size $size --redis-version 6

      # Get details of an Azure Cache for Redis
      echo "Showing details of $cache"
      az redis show --name $cache --resource-group $resourceGroup 

      # Retrieve the hostname and ports for an Azure Redis Cache instance
      redis=($(az redis show --name $cache --resource-group $resourceGroup --query [hostName,enableNonSslPort,port,sslPort] --output tsv))

      # Retrieve the keys for an Azure Redis Cache instance
      keys=($(az redis list-keys --name $cache --resource-group $resourceGroup --query [primaryKey,secondaryKey] --output tsv))

      # Display the retrieved hostname, keys, and ports
      echo "Hostname:" ${redis[0]}
      echo "Non SSL Port:" ${redis[2]}
      echo "Non SSL Port Enabled:" ${redis[1]}
      echo "SSL Port:" ${redis[3]}
      echo "Primary Key:" ${keys[0]}
      echo "Secondary Key:" ${keys[1]}

      # Delete a redis cache
      # echo "Deleting $cache"
      # az redis delete --name $resourceGroup --resource-group $resourceGroup -y
    ```

## Step 2: Configure the pub/sub component

1. Open the file `dapr/azure-redis-pubsub.yaml` in your code editor.

    ```yaml
    apiVersion: dapr.io/v1alpha1
    kind: Component
    metadata:
      name: pubsub
    spec:
      type: pubsub.redis
      version: v1
      metadata:
       - name: redisHost
         value: <replaceWithRedisHostName>:<replaceWithRedisSSLPort>
       - name: redisPassword
         value: <replaceWithPrimaryKey>
       - name: enableTLS
       - value: "true"
    scopes:
      - trafficcontrolservice
      - finecollectionservice
    ```

    As you can see, you specify a different type of pub/sub component (`pubsub.redis`) and you specify in the `metadata` section how to connect to Azure Cache for Redis created in step 1. For this workshop, you are going to use the redis hostname, password and port you copied in the previous step.

    In the `scopes` section, you specify that only the TrafficControlService and FineCollectionService should use the pub/sub building block.

1. **Copy or Move** this file `dapr/azure-redis-pubsub.yaml` to `dapr/components` folder.

1. **Replace** the `redistHost` and `redisPassword` value with the value you copied from the clipboard.

1. **Move** the files `dapr/components/kafka-pubsub.yaml` and `dap/components/rabbit-pubsub.yaml`  back to `dapr/` folder if they are present in the component folder.

## Step 3: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```bash
   dapr run --app-id vehicleregistrationservice --app-port 6002 --dapr-http-port 3602 --dapr-grpc-port 60002 mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:

   ```bash
   dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService with a Dapr sidecar:

   ```bash
   dapr run --app-id trafficcontrolservice --app-port 6000 --dapr-http-port 3600 --dapr-grpc-port 60000 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```bash
   mvn spring-boot:run
   ```

You should see the same logs as before. Obviously, the behavior of the application is exactly the same as before. But now, instead of messages being published and subscribed via kafka topic, are being processed through Redis streams.

    
