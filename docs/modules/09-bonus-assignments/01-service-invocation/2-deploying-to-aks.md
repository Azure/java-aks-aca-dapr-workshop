---
title: Deploying service invocation to Azure Kubernetes Service
parent: Service invocation using Dapr
grand_parent: Bonus Assignments
has_children: false
nav_order: 2
layout: default
has_toc: true
---

# Deploying service invocation to Azure Kubernetes Service
    
{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

In this assignment, you will deploy the service communication to Azure Kubernetes Service (AKS). You will use the [service invocation building block](https://docs.dapr.io/developing-applications/building-blocks/service-invocation/service-invocation-overview/) provided by Dapr.

{: .important-title }
> Pre-requisite
>
> The first part [Invoke Vehicle Registration Service from Fine Collection Service using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/1-invoke-service-using-dapr.md %}) is a pre-requisite for this assignment.
>

## Step 1: Deploy service invocation to AKS

1. Open `deploy/vehicleregistrationservice.yaml` in your code editor and **uncomment** the following lines:

    ```yaml
        # annotations:
            # dapr.io/enabled: "true"
            # dapr.io/app-id: "vehicleregistrationservice"
            # dapr.io/app-port: "6002"
    ```

    to give Vehicle Registration Service an `id` and a `port` known to [Dapr](https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-overview/#adding-dapr-to-a-kubernetes-deployment).

1. Delete the image from local docker and from the Azure Container Registry:

    ```bash
    docker rmi fine-collection-service:1.0-SNAPSHOT
    az acr repository delete -n $CONTAINER_REGISTRY --image fine-collection-service:latest
    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry.

1. In the root folder of `FineCollectionService`, run the following command to build and push the image:

    ```bash
    mvn spring-boot:build-image
    docker tag fine-collection-service:1.0-SNAPSHOT $CONTAINER_REGISTRY.azurecr.io/fine-collection-service:latest
    docker push $CONTAINER_REGISTRY.azurecr.io/fine-collection-service:latest
    ```

    Where `$CONTAINER_REGISTRY` is the name of your Azure Container Registry.

1. From the root folder of the repo, run the following command:

    ```bash
    kubectl apply -k deploy
    ```

## Step 2. Test the applications running in AKS

1. Run the following command to identify the name of each microservice pod:

    ```bash
    kubectl get pods
    ```

1. l\Look at the log file of each application pod to see the same output as seen when running on your laptop. For example:

    ```bash
    kubectl logs finecollectionservice-ccf8c9cf5-vr8hr -c fine-collection-service
    ```

1. Delete all application deployments:

    ```bash
    kubectl delete -k deploy
    ```

{: .important-title }
> Cleanup
>
> When the workshop is done, please follow the [cleanup instructions]({{ site.baseurl }}{% link modules/10-cleanup/index.md %}) to delete the resources created in this workshop.
> 

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Invoke Service using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/1-invoke-service-using-dapr.md %}){: .btn .mt-7 }
</span>
