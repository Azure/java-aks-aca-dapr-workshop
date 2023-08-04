---
title: Deploying Azure Cosmos DB state store to Azure Container Apps
parent: Using Azure Cosmos DB as a state store
grand_parent: Bonus Assignments
has_children: false
nav_order: 3
layout: default
has_toc: true
---

# Deploying Azure Cosmos DB state store to Azure Container Apps

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

In this assignment, you will deploy the Azure Cosmos DB state store to Azure Container Apps (ACA). You will use the [state management building block](https://docs.dapr.io/developing-applications/building-blocks/state-management/state-management-overview/) provided by Dapr.

{: .important-title }
> Pre-requisite
>
> The first part [Use Azure Cosmos DB to store the state of a vehicle using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/1-azure-cosmos-db-state-store.md %}) is a pre-requisite for this assignment.
>
> The account URL and the master key of the Azure Cosmos DB instance are required for this assignment. Please use the same Azure Cosmos DB instance as used in the first part of this assignment.
> 

## Step 1: Deploy Azure Cosmos DB state store component to ACA

1. Remove `azure-cosmosdb-statestore.yaml` from `dapr/components` folder.

1. Open the file `dapr/aca-azure-cosmosdb-statestore.yaml` in your code editor and compare the content of the file with the content of the file `dapr/azure-cosmosdb-statestore.yaml` from the previous assignment.

1. **Copy or Move** this file `dapr/aca-azure-cosmosdb-statestore.yaml` to `dapr/components` folder.

1. **Replace** the following placeholders in this file `dapr/components/aca-azure-cosmosdb-statestore.yaml` with the values you noted down in the previous assignment:

    - `<YOUR_COSMOSDB_ACCOUNT_URL>` with the Cosmos DB account URL
    - `<YOUR_COSMOSDB_MASTER_KEY>` with the master key

1. Go to the root folder of the repository.

1. Enter the following command to deploy the `statestore` Dapr component:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name statestore \
      --yaml ./dapr/components/aca-azure-cosmosdb-statestore.yaml
    ```

<!-- ----------------------- BUILD, DEPLOY AND TEST ------------------------ -->

{% assign stepNumber = 2 %}
{% include 09-bonus-assignments/02-state-store/3-deploy-to-aca.md %}

<!-- ------------------------------- CLEANUP ------------------------------- -->

{: .important-title }
> Cleanup
>
> When the workshop is done, please follow the [cleanup instructions]({{ site.baseurl }}{% link modules/10-cleanup/index.md %}) to delete the resources created in this workshop.
> 

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Cosmos DB as a state store]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/1-azure-cosmos-db-state-store.md %}){: .btn .mt-7 }
</span>

