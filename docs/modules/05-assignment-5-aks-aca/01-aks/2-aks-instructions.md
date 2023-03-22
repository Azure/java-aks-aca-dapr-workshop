---
title: Deploying to AKS with Dapr Extension
parent: Deploying to Azure Kubernetes Service
grand_parent: Assignment 5 - Deploying to Azure with Dapr
has_children: false
nav_order: 2
layout: default
---

# Deploying to AKS with Dapr Extension

## Setup

1. Install [Helm](https://helm.sh/docs/intro/install/)

1. Login to azure

      ```bash
      az login
      ```

1. Create a resource group

     - create Resource Group (if not already created)
     
       ```bash
       az group create --name rg-dapr-workshop-java --location eastus
       ```

     - set Resource Group as default

       ```bash
       az configure --defaults group=rg-dapr-workshop-java
       ```

1. [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/) is a private registry for hosting container images. Using the Azure Container Registry, you can store Docker images for all types of container deployments. This registry needs to be gloablly unique. Use the following command to generate a unique name:

    - Linux/Unix shell:
       
        ```bash
        UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)
        CONTAINER_REGISTRY="crdapr-workshop-java-$UNIQUE_IDENTIFIER"
        echo $CONTAINER_REGISTRY
        ```

    - Powershell:
    
        ```powershell
        $ACCEPTED_CHAR = [Char[]]'abcdefghijklmnopqrstuvwxyz0123456789'
        $UNIQUE_IDENTIFIER = (Get-Random -Count 5 -InputObject $ACCEPTED_CHAR) -join ''
        $CONTAINER_REGISTRY = "sb-dapr-workshop-java-$UNIQUE_IDENTIFIER"
        $CONTAINER_REGISTRY
        ```

1. Create an Azure Container Registry (ACR) resource

    ```bash
    az acr create --name "$CONTAINER_REGISTRY" --sku Basic
    ```


1. Create an AKS cluster with the ACR attached

    ```bash
    az aks create \
        --name aks-dapr-workshop-java \
        --generate-ssh-keys \
        --attach-acr "$CONTAINER_REGISTRY" \
        --enable-managed-identity
    ```

1. Update AKS with Dapr extension

    ```bash
    az k8s-extension create --cluster-type managedClusters \
      --cluster-name aks-dapr-workshop-java \
      --name myDaprExtension \
      --extension-type Microsoft.Dapr
    ```

1. Download AKS cluster kubecofig file, and install kubectl CLI

    ```bash
    az aks install-cli
    az aks get-credentials -n aks-dapr-workshop-java -g rg-dapr-workshop-java
    ```

## Step 1 - Deploy kafka to AKS, and configure Dapr

1. Deploy kafka to kubernetes using helm chart

    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install my-release bitnami/kafka
    ```

2. Configure Dapr to use kafka for pubsub

    ```bash
    cd deploy
    kubectl apply -f kafka-pubsub.yaml
    ```

## Step 2 - Generate Docker images for applications, and push them to ACR

1. login to your ACR repository

    ```bash
    az acr login --name "$CONTAINER_REGISTRY"
    ```

1. In the root folder of TravelRegistrationService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag vehicle-registration-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY".azurecr.io/vehicle-registration-service:latest
    docker push "$CONTAINER_REGISTRY".azurecr.io/vehicle-registration-service:latest
    ```

1. In the root folder of FineCollectionService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY".azurecr.io/fine-collection-service:latest
    docker push "$CONTAINER_REGISTRY".azurecr.io/fine-collection-service:latest
    ```
1. In the root folder of TrafficControlService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag traffic-control-service:1.0-SNAPSHOT "$CONTAINER_REGISTRY".azurecr.io/traffic-control-service:latest
    docker push "$CONTAINER_REGISTRY".azurecr.io/traffic-control-service:latest
    ```

1. In the root folder of the simulation (`Simulation`), run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag simulation:1.0-SNAPSHOT "$CONTAINER_REGISTRY".azurecr.io/simulation:latest
    docker push "$CONTAINER_REGISTRY".azurecr.io/simulation:latest
    ```

## Step 3 - Deploy Kubernetes manifest files for applications to AKS

1. In the `deploy` folder, update all `<service-name>-deployment.yaml` files to use the correct container registry: replace `<REPLACE_WITH_CONTAINER_REGISTRY_NAME>` with the name of the container registry (`$CONTAINER_REGISTRY`).

1. From the root folder of the repo, run the following command:

  ```bash
  kubectl apply -k deploy
  ```

  Please note below the `kubectl apply` is with **-k** option, which is applying `kustomize.yaml` file in the `deploy` folder

## Step 4 - Test the applications running in AKS

1. Run the following command to identify the name of each microservice pod

    ```bash
    kubectl get pods
    ```

2. Look at the log file of each application pod to see the same output as seen when running on your laptop. For example,

    ```bash
    kubectl logs trafficcontrolservice-7d8f48b778-rx8l8 -c traffic-control-service
    ```

3. Delete all application deployments

    ```bash
    kubectl delete -k deploy
    ```
