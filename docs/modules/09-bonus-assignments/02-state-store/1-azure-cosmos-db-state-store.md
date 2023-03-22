---
title: Use Azure Cosmos DB to store the state of a vehicle using Dapr
parent: Use Azure Cosmos DB as a state store
grand_parent: Bonus Assignments
has_children: false
nav_order: 1
layout: default
---

# Use Azure Cosmos DB to store the state of a vehicle using Dapr

This bonus assignment is about using Azure Cosmos DB as a [state store](https://docs.dapr.io/operations/components/setup-state-store/) for the `TrafficControlService`. You will use the [Azure Cosmos DB state store component](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-azure-cosmosdb/) provided by Dapr.

## Step 1: Create an Azure Cosmos DB

1. Open a terminal window.

1. Azure Cosmos DB account for SQL API is a globally distributed multi-model database service. This account needs to be globally unique. Use the following command to generate a unique name:

    - Linux/Unix shell:
       
        ```bash
        UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)
        COSMOS_DB="cosno-dapr-workshop-java-$UNIQUE_IDENTIFIER"
        echo $COSMOS_DB
        ```

    - Powershell:
    
        ```powershell
        $ACCEPTED_CHAR = [Char[]]'abcdefghijklmnopqrstuvwxyz0123456789'
        $UNIQUE_IDENTIFIER = (Get-Random -Count 5 -InputObject $ACCEPTED_CHAR) -join ''
        $COSMOS_DB = "cosno-dapr-workshop-java-$UNIQUE_IDENTIFIER"
        $COSMOS_DB
        ```

1. Create a Cosmos DB account for SQL API

    ```bash
    az cosmosdb create --name $COSMOS_DB --resource-group rg-dapr-workshop-java --locations regionName=eastus failoverPriority=0 isZoneRedundant=False
    ```

    {: .important }
    > The name of the Cosmos DB account must be unique across all Azure Cosmos DB accounts in the world. If you get an error that the name is already taken, try a different name. In the following steps, please update the name of the Cosmos DB account accordingly.

1. Create a SQL API database

    ```bash
    az cosmosdb sql database create --account-name $COSMOS_DB --resource-group rg-dapr-workshop-java --name dapr-workshop-java-database
    ```

1. Create a SQL API container

    ```bash
    az cosmosdb sql container create --account-name $COSMOS_DB --resource-group rg-dapr-workshop-java --database-name dapr-workshop-java-database --name vehicle-state --partition-key-path /partitionKey --throughput 400
    ```

    {: .important }
    > The partition key path is `/partitionKey` as mentionned in [Dapr documentation](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-azure-cosmosdb/#setup-azure-cosmosdb).

1. Get the Cosmos DB account URL and note it down. You will need it in the next step and to deploy it to Azure.
   
    ```bash
    az cosmosdb show --name $COSMOS_DB --resource-group rg-dapr-workshop-java --query documentEndpoint -o tsv
    ```

1. Get the master key and note it down. You will need it in the next step and to deploy it to Azure.

    ```bash
    az cosmosdb keys list --name $COSMOS_DB --resource-group rg-dapr-workshop-java --type keys --query primaryMasterKey -o tsv
    ```

## Step 2: Configure the Azure Cosmos DB state store component

1. Open the file `dapr/azure-cosmosdb-statestore.yaml` in your code editor.

1. **Copy or Move** this file `dapr/azure-cosmosdb-statestore.yaml` to `dapr/components` folder.
   
1. **Move** the file `dapr/components/redis-statestore.yaml` back to `dapr/` folder.

1. **Replace** the following placeholders in the file `dapr/components/azure-cosmosdb-statestore.yaml` with the values you noted down in the previous step:

    - `<YOUR_COSMOSDB_ACCOUNT_URL>` with the Cosmos DB account URL
    - `<YOUR_COSMOSDB_MASTER_KEY>` with the master key

## Step 3: Add the Azure Cosmos DB state store to the `TrafficControlService`

1. Open the `TrafficControlService` project in your code editor and navigate to the `DaprVehicleStateRepository` class. This class use the Dapr client to store and retrieve the state of a vehicle. Inspect the implementation of this class.

1. Navigate to the `TrafficControlConfiguration` class to swith from the `InMemoryVehicleStateRepository` to the `DaprVehicleStateRepository`.

1. **Update** @Bean method to instantiate `DaprVehicleStateRepository` instead of `InMemoryVehicleStateRepository`

    ```java
        @Bean
        public VehicleStateRepository vehicleStateRepository(final DaprClient daprClient) {
            return new DaprVehicleStateRepository(daprClient);
        }
    ```

1. **Uncomment** following @Bean method if not already done
  
    ```java
    //    @Bean
    //    public DaprClient daprClient() {
    //        return new DaprClientBuilder()
    //                .withObjectSerializer(new JsonObjectSerializer())
    //                .build();
    //    }
    ```

1. Check all your code-changes are correct by building the code. Execute the following command in the terminal window:

    ```bash
    mvn package
    ```

Now you can test the application

### Step 4: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService:

   ```bash
   mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:

   ```bash
   dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService with a Dapr sidecar:

   ```bash
   dapr run --app-id trafficcontrolservice --app-port 6000 --dapr-http-port 3600 --dapr-grpc-port 60000 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```bash
   mvn spring-boot:run
   ```

You should see the same logs as before. Obviously, the behavior of the application is exactly the same as before.
