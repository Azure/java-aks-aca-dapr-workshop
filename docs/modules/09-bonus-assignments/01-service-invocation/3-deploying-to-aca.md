---
title: Deploying service invocation to Azure Container Apps
parent: Service invocation using Dapr
grand_parent: Bonus Assignments
has_children: false
nav_order: 3
layout: default
has_toc: true
---

# Deploying service invocation to Azure Container Apps

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

In this assignment, you will deploy the service communication to Azure Container Apps (ACA). You will use the [service invocation building block](https://docs.dapr.io/developing-applications/building-blocks/service-invocation/service-invocation-overview/) provided by Dapr.

{: .important-title }
> Pre-requisites
>
> * The first part [Invoke Vehicle Registration Service from Fine Collection Service using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/1-invoke-service-using-dapr.md %}) is a pre-requisite for this assignment.
> * Assignment 5 - [Deploying to Azure Container Apps]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/index.md %}) is also a pre-requisite for this assignment.
>

{% assign stepNumber = 1 %}
{% include 09-bonus-assignments/01-service-invocation/3-deploy-to-aca.md %}

{: .important-title }
> Cleanup
>
> When the workshop is done, please follow the [cleanup instructions]({{ site.baseurl }}{% link modules/10-cleanup/index.md %}) to delete the resources created in this workshop.
> 

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Invoke Service using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/1-invoke-service-using-dapr.md %}){: .btn .mt-7 }
</span>
