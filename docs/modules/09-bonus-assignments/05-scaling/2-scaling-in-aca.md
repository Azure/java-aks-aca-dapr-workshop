---
title: Scaling Fine Collection Service in Azure Container Apps
parent: Scaling Fine Collection Service using KEDA
grand_parent: Bonus Assignments
has_children: false
nav_order: 2
layout: default
has_toc: true
---

# Scaling Fine Collection Service in Azure Container Apps

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

<!-- -------------------------------- INTRO -------------------------------- -->

{% include 09-bonus-assignments/05-scaling/2-1-intro.md relativeAssetsPath="../../../assets/" %}

{: .important-title }
> Pre-requisites
>
> * The `Assignment 3 - Setup Azure Service Bus` is a pre-requisite for this bonus assignment. If not done yet, please follow the instructions in [Assignment 3 - Setup Azure Service Bus]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md %}).
> * Assignment 5 - [Deploying to Azure Container Apps]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/index.md %}) is also a pre-requisite for this assignment.
> 

<!-- --------------------------- DEPLOY AND TEST --------------------------- -->

{% include 09-bonus-assignments/05-scaling/2-2-deploy-and-test.md relativeAssetsPath="../../../assets/" showWithoutSecret=true %}

<!-- ------------------------------- CLEANUP ------------------------------- -->

{: .important-title }
> Cleanup
>
> When the workshop is done, please follow the [cleanup instructions]({{ site.baseurl }}{% link modules/10-cleanup/index.md %}) to delete the resources created in this workshop.
>
