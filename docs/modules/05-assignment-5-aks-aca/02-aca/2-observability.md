---
title: (Optional) Observability
parent: Deploying to Azure Container Apps
grand_parent: Assignment 5 - Deploying to Azure with Dapr
has_children: false
nav_order: 2
layout: default

has_toc: true
---


# (Optional) Observability with Dapr using Application Insights


{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

In this section, you will deploy Dapr service-to-service telemetry using [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=java). When [creating the Azure Container Apps environment](https://learn.microsoft.com/en-us/cli/azure/containerapp/env?view=azure-cli-latest#az-containerapp-env-create), you can set Application Insights instrumentation key that is used by Dapr to export service-to-service telemetry to Application Insights.

## Step 1: Create Application Insights resource

{% include 05-assignment-5-aks-aca/02-aca/0-1-setup-application-insights.md %}

## Step 2: Create Azure Container Apps environment

{% include 05-assignment-5-aks-aca/02-aca/0-2-setup-container-apps-env.md showObservability=true %}

## Step 3: Deploy the application

To deploy the application, follow all the instructions after the creation of the container apps environment in [Deploying Applications to Azure Container Apps (ACA) with Dapr]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/1-aca-instructions.md %}). After the completion of the deployment and the testing, you can see the service-to-service telemetry in the Application Insights as shown below.

## Step 4: View the telemetry in Application Insights

1. Open the Application Insights resource in the [Azure portal]([https](https://portal.azure.com/)).

1. Go to `Application Map`, you should see a diagram like the on below

![Dapr Telemetry](../../../assets/image/../images/dapr-telemetry.png)

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Deploy to ACA with Dapr]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/1-aca-instructions.md %}){: .btn .mt-7 }
</span>
