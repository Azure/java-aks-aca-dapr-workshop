---
title: Assignment 5 - Deploying Applications to AKS with Dapr Extension
has_children: false
nav_order: 7
---

# Assignment 5 - Deploying Applications to AKS with Dapr Extension

## Setup

1. Install [Helm](https://helm.sh/docs/intro/install/)
2. login to azure

```azurecli
az login
```

3. Create an Azure Container Registry (ACR) resource

  - create Resource Group
  
```bash
az group create --name dapr-workshop-java --location eastus
```

  - set Resource Group as default

```bash
az configure --defaults group=dapr-workshop-java
```

  - create acr

```bash
az acr create --name daprworkshopjava --sku Basic
```

4. Create an AKS cluster with the ACR attached

```bash
az aks create \
    --name dapr-workshop-java-aks \
    --generate-ssh-keys \
    --attach-acr daprworkshopjava \
    --enable-managed-identity
```

5. Update AKS with Dapr extension

```azurecli
az k8s-extension create --cluster-type managedClusters \
--cluster-name dapr-workshop-java-aks \
--name myDaprExtension \
--extension-type Microsoft.Dapr 
```

6. Download AKS cluster kubecofig file, and install kubectl CLI

```bash
az aks install-cli
az aks get-credentials -n dapr-workshop-java-aks -g <NAME-OF-RESOURCE-GROUP>
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

```azurecli
az acr login --name daprworkshopjava
```

2. In the root folder/directory of each of the TravelRegistrationService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag vehicle-registration-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/vehicle-registration-service:latest
docker push daprworkshopjava.azurecr.io/vehicle-registration-service:latest
```

3. In the root folder/directory of each of the FineCollectionService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag fine-collection-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/fine-collection-service:latest
docker push daprworkshopjava.azurecr.io/fine-collection-service:latest
```
4. In the root folder/directory of each of the TrafficControlService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag traffic-control-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/traffic-control-service:latest
docker push daprworkshopjava.azurecr.io/traffic-control-service:latest
```

5. In the root folder/directory of each of the SimulationService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag simulation:1.0-SNAPSHOT daprworkshopjava.azurecr.io/simulation:latest
docker push daprworkshopjava.azurecr.io/simulation:latest
```

## Step 3 - Deploy Kubernetes manifest files for applications to AKS

1. From the root folder/directory of the repo, run the following command

```bash
kubectl apply -k deploy
```

## Step 4 - Test the applications running in AKS

1. run the following command to identify the name of each microservice pod

```bash
kubectl get pods
```

2. look at the log file of each application pod to see the same output as seen when running on your laptop. For example,

```bash
kubectl logs trafficcontrolservice-7d8f48b778-rx8l8 -c traffic-control-service
```

3. delete all application deployments

```azurecli
kubectl delete -k deploy
```