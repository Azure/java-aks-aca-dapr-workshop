---
title: Deploying service-to-service invocation to Azure Kubernetes Service
parent: Service-to-service invocation using Dapr
grand_parent: Bonus Assignments
has_children: false
nav_order: 2
layout: default
---

# Deploying service-to-service invocation to Azure Kubernetes Service
    
<br>

{: .important-title }
> Pre-requisite
>
> The first part [Invoke Vehicle Registration Service from Fine Collection Service using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-to-service-invocation/1-invoke-service-using-dapr.md %}) is a pre-requisite for this assignment.
>

## Step 1: Deploy service-to-service communication to AKS

1. Open `deploy/vehicleregistrationservice.yaml` in your IDE and **uncomment** the following lines:

    ```yaml
        # annotations:
            # dapr.io/enabled: "true"
            # dapr.io/app-id: "vehicleregistrationservice"
            # dapr.io/app-port: "6002"
    ```

    to give Vehicle Registration Service an `id` and a `port` known to [Dapr](https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-overview/#adding-dapr-to-a-kubernetes-deployment).

1. Delete the image from local docker and from the Azure Container Registry

    ```bash
    docker rmi fine-collection-service:1.0-SNAPSHOT
    az acr repository delete -n daprworkshopjava --image fine-collection-service:latest
    ```

1. In the root folder/directory of the FineCollectionService microservice, run the following command

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/fine-collection-service:latest
    docker push daprworkshopjava.azurecr.io/fine-collection-service:latest
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
