---
title: Scaling Fine Collection Service using KEDA
parent: Bonus Assignments
has_children: true
nav_order: 5
layout: default
---

# Scaling Fine Collection Service using KEDA

This bonus assignment is about usig [KEDA](https://keda.sh/) to scale the `FineCollectionService` based on the number of messages in the Azure Service Bus queue. You will use the [Azure Service Bus Scaler](https://keda.sh/docs/2.11/scalers/azure-service-bus/) provided by KEDA.

{: .important-title }
> Pre-requisite
>
> The `Assignment 3 - Setup Azure Service Bus` is a pre-requisite for this bonus assignment. If not done yet, please follow the instructions in [Assignment 3 - Setup Azure Service Bus]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md %}).
>

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<!-- <span class="fs-3">
[Azure Kubernetes Service]({{ site.baseurl }}{% link modules/03-assignment-3-azure-pub-sub/1-azure-service-bus.md %}){: .btn }
</span> -->
<span class="fs-3">
[Azure Container Apps]({{ site.baseurl }}{% link modules/09-bonus-assignments/05-scaling/2-scaling-in-aca.md %}){: .btn }
</span>