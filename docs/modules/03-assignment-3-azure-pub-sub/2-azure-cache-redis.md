---
title: Using Dapr for pub/sub with Azure Cache for Redis
parent: Assignment 3 - Using Dapr for pub/sub with Azure Services
has_children: false
nav_order: 2
layout: default
has_toc: true
---

# Using Dapr for pub/sub with Azure Cache for Redis

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

Stop Simulation, TrafficControlService and FineCollectionService, and VehicleRegistrationService by pressing Crtl-C in the respective terminal windows.

## Step 1: Create Azure Cache for Redis 

In this assignment, you will use Azure Cache for Redis as the message broker with the Dapr pub/sub building block. To be able to do this, you need to have an Azure subscription. If you don't have one, you can create a free account at [https://azure.microsoft.com/free/](https://azure.microsoft.com/free/).

1. Login to Azure:

    ```bash
    az login
    ```

1. Create a resource group:

    ```bash
    az group create --name rg-dapr-workshop-java --location eastus
    ```

    A [resource group](https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal) is a container that holds related resources for an Azure solution. The resource group can include all the resources for the solution, or only those resources that you want to manage as a group. In our workshop, all the databases, all the microservices, etc. will be grouped into a single resource group.

1. [Azure Cache for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/) is a fully managed, dedicated, in-memory data store for enterprise-grade cloud-native applications. It can be used as a distributed data or content cache, a session store, a message broker, and more. This cache needs to be globally unique. Use the following command to generate a unique name:

    - Linux/Unix shell:

      ```bash
      UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)
      REDIS="redis-dapr-workshop-java-$UNIQUE_IDENTIFIER"
      echo $REDIS
      ```

    - PowerShell:

      ```powershell
      $ACCEPTED_CHAR = [Char[]]'abcdefghijklmnopqrstuvwxyz0123456789'
      $UNIQUE_IDENTIFIER = (Get-Random -Count 5 -InputObject $ACCEPTED_CHAR) -join ''
      $REDIS = "redis-dapr-workshop-java-$UNIQUE_IDENTIFIER"
      echo $REDIS
      ```

1. Create the Azure Cache for Redis:

    ```bash
    az redis create --name $REDIS --resource-group rg-dapr-workshop-java --location eastus --sku basic --vm-size C0 --redis-version 6
    ```

    The `--sku` parameter specifies the SKU of the cache to deploy. In this case, you are using the `basic` SKU. The `--vm-size` parameter specifies the size of the VM to deploy for the cache. Caches in the [Basic tier](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-overview#service-tiers) are deployed in a single VM with no service-level agreement(SLA). The `--redis-version` parameter specifies the version of Redis to deploy. In this case, you are using version 6.

1. Get the hostname, SSL port and the primary key:

    - Linux/Unix shell:

      ```bash
      REDIS_HOSTNAME=$(az redis show --name $REDIS --resource-group rg-dapr-workshop-java --query hostName --output tsv)
      REDIS_SSL_PORT=$(az redis show --name $REDIS --resource-group rg-dapr-workshop-java --query sslPort --output tsv)
      REDIS_PRIMARY_KEY=$(az redis list-keys --name $REDIS --resource-group rg-dapr-workshop-java --query primaryKey --output tsv)
      echo "Hostname: $REDIS_HOSTNAME"
      echo "SSL Port: $REDIS_SSL_PORT"
      echo "Primary Key: $REDIS_PRIMARY_KEY"
      ```

    - PowerShell:

      ```powershell
      $REDIS_HOSTNAME = az redis show --name $REDIS --resource-group rg-dapr-workshop-java --query hostName --output tsv
      $REDIS_SSL_PORT = az redis show --name $REDIS --resource-group rg-dapr-workshop-java --query sslPort --output tsv
      $REDIS_PRIMARY_KEY = az redis list-keys --name $REDIS --resource-group rg-dapr-workshop-java --query primaryKey --output tsv
      Write-Output "Hostname: $REDIS_HOSTNAME"
      Write-Output "SSL Port: $REDIS_SSL_PORT"
      Write-Output "Primary Key: $REDIS_PRIMARY_KEY"
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
        value: "true"
    scopes:
      - trafficcontrolservice
      - finecollectionservice
    ```

    As you can see, you specify a different type of pub/sub component (`pubsub.redis`) and you specify in the `metadata` section how to connect to Azure Cache for Redis created in step 1. For this workshop, you are going to use the redis hostname, password and port you copied in the previous step. For more information, see [Redis  Streams pub/sub component](https://docs.dapr.io/reference/components-reference/supported-pubsub/setup-redis-pubsub/).

    In the `scopes` section, you specify that only the `TrafficControlService` and `FineCollectionService` should use the pub/sub building block. To know more about scopes, see [Application access to components with scopes](https://docs.dapr.io/operations/components/component-scopes/#application-access-to-components-with-scopes).

1. **Copy or Move** this file `dapr/azure-redis-pubsub.yaml` to `dapr/components` folder.

1. **Replace** the `redistHost` and `redisPassword` value with the value you copied from the clipboard.

1. **Move** the files `dapr/components/kafka-pubsub.yaml` and `dap/components/rabbit-pubsub.yaml`  back to `dapr/` folder if they are present in the component folder.

## Step 3: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```bash
   mvn spring-boot:run
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

You should see the same logs as before. Obviously, the behavior of the application is exactly the same as before. But now, instead of messages being published and subscribed via kafka topic, are being processed through Redis Streams.

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Assignment 2 - Run with Dapr]({{ site.baseurl }}{% link modules/02-assignment-2-dapr-pub-sub/index.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Assignment 4 - Observability >]({{ site.baseurl }}{% link modules/04-assignment-4-observability-zipkin/index.md %}){: .btn .float-right .mt-7 }
</span>
