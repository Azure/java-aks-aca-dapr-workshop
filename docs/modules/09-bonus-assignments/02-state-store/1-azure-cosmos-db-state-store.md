---
title: Using Azure Cosmos DB to store the state of a vehicle with Dapr
parent: Using Azure Cosmos DB as a state store
grand_parent: Bonus Assignments
has_children: false
nav_order: 1
layout: default
has_toc: true
---

# Using Azure Cosmos DB to store the state of a vehicle wtih Dapr

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

This bonus assignment is about using Azure Cosmos DB as a [state store](https://docs.dapr.io/operations/components/setup-state-store/) for the `TrafficControlService` instead of keeping the sate in memory. You will use the [Azure Cosmos DB state store component](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-azure-cosmosdb/) provided by Dapr.

## Step 1: Create an Azure Cosmos DB

{% include 09-bonus-assignments/02-state-store/1-1-create-cosmos-db.md %}

## Step 2: Configure the Azure Cosmos DB state store component

1. Open the file `dapr/azure-cosmosdb-statestore.yaml` in your code editor and look at the content of the file.

1. **Copy or Move** this file `dapr/azure-cosmosdb-statestore.yaml` to `dapr/components` folder.
   
1. **Replace** the following placeholders in the file `dapr/components/azure-cosmosdb-statestore.yaml` with the values you noted down in the previous step:

    - `<YOUR_COSMOSDB_ACCOUNT_URL>` with the Cosmos DB account URL
    - `<YOUR_COSMOSDB_MASTER_KEY>` with the master key

## Step 3: Add the Azure Cosmos DB state store to the `TrafficControlService`

{% include 09-bonus-assignments/02-state-store/1-3-update-traffic-control-service.md %}

Now you can test the application

## Step 4: Test the application

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

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[Deploy to AKS]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/2-deploying-to-aks.md %}){: .btn }
</span>
<span class="fs-3">
[Deploy to ACA]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/3-deploying-to-aca.md %}){: .btn }
</span>