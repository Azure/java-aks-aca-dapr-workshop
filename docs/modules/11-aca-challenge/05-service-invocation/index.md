---
title: Assignment 5 - Service Invocation using Dapr
parent: Azure Container Apps Challenge
has_children: false
nav_order: 6
layout: default
has_toc: true
---

# Assignment 5 - Service Invocation using Dapr

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

This assignment is about using Dapr to invoke the `VehicleRegistrationService` from the `FineCollectionService`. You will use the [service invocation building block](https://docs.dapr.io/developing-applications/building-blocks/service-invocation/service-invocation-overview/) provided by Dapr. This is the second step to reach the final state of the application for this challge. It is represented by the diagram below.

![Azure Container Apps Challenge - Second Deployment](../../../assets/images/aca-deployment-2.png)

<!-- ------------ STEP 1 - INVOKE VEHICLE REGISTRATION SERVICE ------------- -->

{% assign stepNumber = 1 %}
{% include 09-bonus-assignments/01-service-invocation/1-use-dapr-to-invoke-vehicle-registration-service.md %}

<!-- ---------------------------- DEPLOY TO ACA ---------------------------- -->

{% assign stepNumber = stepNumber | plus: 1 %}
{% include 09-bonus-assignments/01-service-invocation/3-deploy-to-aca.md %}

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Assignment 4 - Deploy to Azure Container Apps]({{ site.baseurl }}{% link modules/11-aca-challenge/04-deploy-to-aca/index.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Assignment 6 - Cosmos DB as a state store >]({{ site.baseurl }}{% link modules/11-aca-challenge/06-state-store/index.md %}){: .btn .float-right .mt-7 }
</span>
