---
title: Assignment 4 - Deploying to Azure Container Apps
parent: Azure Container Apps Challenge
has_children: false
nav_order: 5
layout: default
has_toc: true
---

# Assignment 4 - Deploying to Azure Container Apps

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

This assignment is about deploying the 3 microservices to [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/) with Dapr enabled for pub/sub. This is the first deployment of the microservices to Azure. The next assignments provide step by step instructions for deploying the microservices using more Dapr building blocks. The camera simulation runs locally and is not deployed to Azure.

![Azure Container Apps Challenge - First Deployment](../../../assets/images/aca-deployment-1.png)

## Setup

{% include 05-assignment-5-aks-aca/02-aca/1-setup.md showObservability=true %}

## Step 1 - Deploy Dapr Component for pub/sub

You are going to deploy the `pubsub` Dapr component to use Azure Service Bus as the pub/sub message broker.

{% include 05-assignment-5-aks-aca/02-aca/2-1-dapr-component-service-bus.md linkToAssignment3="modules/11-aca-challenge/03-assignment-3-azure-pub-sub/index.md" %}

<!-- ----------------------- BUILD, DEPLOY AND TEST ------------------------ -->

{% assign stepNumber = 2 %}
{% include 05-assignment-5-aks-aca/02-aca/3-build-deploy-test.md %}

<!-- ---------------------------- OBSERVABILITY ---------------------------- -->

{% assign stepNumber = stepNumber | plus: 1 %}
{% include 05-assignment-5-aks-aca/02-aca/4-observability.md relativeAssetsPath="../../../assets/" %}

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Assignment 3 - Pub/sub with Azure Service Bus]({{ site.baseurl }}{% link modules/11-aca-challenge/03-assignment-3-azure-pub-sub/index.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Assignment 5 - Service invocation >]({{ site.baseurl }}{% link modules/11-aca-challenge/05-service-invocation/index.md %}){: .btn .float-right .mt-7 }
</span>