---
title: Deploying Applications to AKS with Dapr Extension
parent: Assignment 5 - Deploying Applications to AKS with Dapr Extension
has_children: false
nav_order: 2
---

# Assignment 5 - Deploying Applications to AKS with Dapr Extension

## Setup

1. Install [Helm](https://helm.sh/docs/intro/install/)
2. login to azure

```azurecli
az login
```

3. Create an AKS cluster

  - create Resource Group
  
```bash
az group create --name dapr-workshop-java --location eastus
```

  - set Resource Group as default

```bash
az configure --defaults group=dapr-workshop-java
```

  - create AKS cluster

```bash
az aks create \
    --name dapr-workshop-java-aks \
    --generate-ssh-keys 
```

4. Update AKS with Dapr extension

```azurecli
az k8s-extension create --cluster-type managedClusters \
--cluster-name dapr-workshop-java-aks \
--name myDaprExtension \
--extension-type Microsoft.Dapr 
```

5. Download AKS cluster kubecofig file, and install kubectl CLI

```bash
az aks install-cli
az aks get-credentials -n dapr-workshop-java-aks -g <NAME-OF-RESOURCE-GROUP>
```

## Step 1 - Deploy kafka to AKS

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/kafka
```

## Step 2 - Deploy Dapr component (kafka pubsub) and application manifest files to AKS

1. From the root folder/directory of the repo, run the following command.

Please note below the `kubectl apply` is with **-k** option, which is applying `kustomize.yaml` file in the `deploy` folder

```bash
kubectl apply -k deploy
```

## Step 3 - Test the applications running in AKS

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