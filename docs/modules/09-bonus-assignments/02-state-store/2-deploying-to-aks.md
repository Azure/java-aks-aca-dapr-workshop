---
title: Deploying Azure Cosmos DB state store to Azure Kubernetes Service
parent: Use Azure Cosmos DB as a state store
grand_parent: Bonus Assignments
has_children: false
nav_order: 2
layout: default
---

# Deploying Azure Cosmos DB state store to Azure Kubernetes Service
    
<br>

{: .important-title }
> Pre-requisite
>
> The first part [Use Azure Cosmos DB to store the state of a vehicle using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/1-azure-cosmos-db-state-store.md %}) is a pre-requisite for this assignment.
>
> The account URL and the master key of the Azure Cosmos DB instance are required for this assignment. Please use the same Azure Cosmos DB instance as used in the first part of this assignment.
> 

### Step 1: Deploy Azure Cosmos DB state store to AKS

1. Create Kubernetes secret for the Azure Cosmos DB account URL and the master key using the following command:
    
    ```bash
    kubectl create secret generic cosmos-db-secret \
        --from-literal=accountUrl=<cosmos-db-account-url>
        --from-literal=masterKey=<cosmos-db-master-key>
    ```

    Where `<cosmos-db-account-url>` is the account URL of the Azure Cosmos DB instance and `<cosmos-db-master-key>` is the master key of the Azure Cosmos DB instance. Both are set when the Azure Cosmos DB instance is created in the [first part of this assignment]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/1-azure-cosmos-db-state-store.md %}).

1. **Copy** this file `dapr/azure-cosmosdb-statestore.yaml` to `deploy/` folder.

1. **Update** the `deploy/azure-cosmosdb-statestore.yaml` file to use the Azure Cosmos DB instance deployed in the first part of this assignment. The file should look like this:

    ```yaml
    apiVersion: dapr.io/v1alpha1
    kind: Component
    metadata:
      name: statestore
    spec:
      type: state.azure.cosmosdb
      version: v1
      metadata:
      - name: url
        secretKeyRef:
          name: cosmos-db-secret
          key: accountUrl
      - name: masterKey
        secretKeyRef:
          name: cosmos-db-secret
          key: masterKey
      - name: database
        value: dapr-workshop-java-database
      - name: collection
        value: vehicle-state
      - name: actorStateStore
        value: "true"
    scopes:
      - trafficcontrolservice
    ```

    Cosmos DB account URL `url` and master key `masterKey` are set to the secret created in the previous step. The `database` is set to `dapr-workshop-java-database` and the `collection` is set to `vehicle-state`.

    {: .important }
    > Never integrate secret in a kubernetes manifest directly, use kubernetes secret instead.
    >

1. Delete the image from local docker and from the Azure Container Registry

    ```bash
    docker rmi traffic-control-service:1.0-SNAPSHOT
    az acr repository delete -n daprworkshopjava --image traffic-control-service:latest
    ```

1. In the root folder/directory of the TrafficControlService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag traffic-control-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/traffic-control-service:latest
    docker push daprworkshopjava.azurecr.io/traffic-control-service:latest
    ```

1. From the root folder/directory of the repo, run the following command

    ```bash
    kubectl apply -k deploy
    ```

## Step 2. Test the applications running in AKS

1. run the following command to identify the name of each microservice pod

    ```bash
    kubectl get pods
    ```

1. look at the log file of each application pod to see the same output as seen when running on your laptop. For example,

    ```bash
    kubectl logs finecollectionservice-ccf8c9cf5-vr8hr -c fine-collection-service
    ```

1. delete all application deployments

    ```bash
    kubectl delete -k deploy
    ```
