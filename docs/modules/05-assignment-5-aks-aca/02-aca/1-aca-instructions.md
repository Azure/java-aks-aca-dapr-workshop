---
title: Deploying to ACA with Dapr
parent: Deploying to Azure Container Apps
grand_parent: Assignment 5 - Deploying to Azure with Dapr
has_children: false
nav_order: 1
layout: default
has_toc: true
---

# Deploying Applications to Azure Container Apps (ACA) with Dapr

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

This assignement is about deploying our microservices to [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/).

{: .important-title }
> Pre-requisite
>
> Either [Assignment 3 - Using Dapr for pub/sub with Azure Service Bus]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md %}) or [Assignment 3 - Using Dapr for pub/sub with Azure Cache for Redis]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/2-azure-cache-redis.md %}) is a pre-requisite for this assignment.
>

## Setup

{% include 05-assignment-5-aks-aca/02-aca/1-setup.md showObservability=false %}

## Step 1 - Deploy Dapr Components

You are going to deploy the `pubsub` Dapr component. This pubsub is either Azure Service Bus or Azure Cache Redis. You can follow the instructions corresponding to the service you deployed during assignment 3.

### Azure Service Bus

{% include 05-assignment-5-aks-aca/02-aca/2-1-dapr-component-service-bus.md linkToAssignment3="modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md" %}

### Azure Cache for Redis

In [Assignment 3 - Using Dapr for pub/sub with Azure Cache for Redis]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/2-azure-cache-redis.md %}), you copied the file `dapr/aca-azure-redis-pubsub.yaml` to `dapr/components` folder and updated the `redisHost` and `redisPassword` values. This file is used to deploy the `pubsub` Dapr component.

The [Dapr component schema for Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#component-schema) is different from the standard Dapr component yaml schema. It has been slightly simplified. Hence the need for a new component yaml file.

1. Open the file `dapr/aca-redis-pubsub.yaml` in your code editor.

    ```yaml
    componentType: pubsub.redis
    version: v1
    metadata:
      - name: redisHost
        value: <replaceWithRedisHostName>:<replaceWithRedisSSLPort>
      - name: redisPassword
        value: <replaceWithPrimaryKey>
      - name: enableTLS
        value: "true"
    scopes:
      - traffic-control-service
      - fine-collection-service
    ```

2. **Copy or Move** this file `dapr/aca-redis-pubsub.yaml` to `dapr/components` folder.

3. **Replace** the `redisHost` and `redisPassword` values with the values you set in `dapr/components/redis-pubsub.yaml` in [Assignment 3 - Using Dapr for pub/sub with Azure Cache for Redis]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/2-azure-cache-redis.md %}).

3. Go to the root folder of the repository.

4. Enter the following command to deploy the `pubsub` Dapr component:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java --resource-group rg-dapr-workshop-java \
      --dapr-component-name pubsub \
      --yaml ./dapr/components/aca-redis-pubsub.yaml
    ```

<!-- ----------------------- BUILD, DEPLOY AND TEST ------------------------ -->

{% assign stepNumber = 2 %}
{% include 05-assignment-5-aks-aca/02-aca/3-build-deploy-test.md %}

## Next Steps

Well done, you have successfully completed the workshop!

- You can follow the **Optional execices for Azure Container Apps (ACA)** to learn more about observability:
  - [Observability]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/2-observability.md %})
- You can read the **additional topics**:
  - [Prevent port collisions]({{ site.baseurl }}{% link modules/08-additional-topics/1-prevent-port-collisions.md %})
  - [Dapr and Service Meshes]({{ site.baseurl }}{% link modules/08-additional-topics/2-dapr-and-service-meshes.md %})
- You can continue the workshop with the **bonus assignments** to learn more about other Dapr building blocks:
  - [Service invocation using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/index.md %})
  - [Azure Cosmos DB as a state store]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/index.md %})
  - [Azure Key Vault as a secret store]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/index.md %})
  - [Scaling Fine Collection Service using KEDA]({{ site.baseurl }}{% link modules/09-bonus-assignments/04-scaling/index.md %})

<!-- ------------------------------- CLEANUP ------------------------------- -->

{: .important-title }
> Cleanup
>
> When the workshop is done, please follow the [cleanup instructions]({{ site.baseurl }}{% link modules/10-cleanup/index.md %}) to delete the resources created in this workshop.
> 

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Deploy to ACA]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/index.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[(Optional) Observability >]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/2-observability.md %}){: .btn .float-right .mt-7 }
</span>
