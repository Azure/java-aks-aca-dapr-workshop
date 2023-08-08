---
title: Bonus Assignments
has_children: true
nav_order: 9
layout: default
---

# Bonus Assignments

The bonus assignments are optional and are not required to complete the workshop.  They are provided as additional learning opportunities. The assigments cover several [building blocks](https://docs.dapr.io/developing-applications/building-blocks/) of Dapr not covered by the workshop:

- Service invocation: [service invocation using Dapr]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/index.md %})
- State management: [Use Azure Cosmos DB as a state store]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/index.md %})
- Secrets Management: [Use Azure Key Vault as a secret store]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/index.md %})

It also covers the scaling of `FineCollectionService` using [KEDA](https://keda.sh/) based on the number of messages in the Azure Service Bus topic: [Scale Fine Collection Service using KEDA]({{ site.baseurl }}{% link modules/09-bonus-assignments/04-scaling/index.md %})
