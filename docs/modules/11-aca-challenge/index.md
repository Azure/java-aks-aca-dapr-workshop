---
title: Azure Container Apps Challenge
has_children: true
nav_order: 11
layout: default
---

# Azure Container Apps Challenge

In this challenge, you will cover most of the topics covered in the workshop and the bonus assignments. You will:

- Deploy all 3 microservices to Azure Container Apps (ACA);
- Use Azure Service Bus as a pub/sub Dapr component for the communication between Traffic Control Service and Fine Collection Service;
- Use Azure Cosmos DB as a state store Dapr building block for Traffic Control Service;
- Use the service invocation Dapr building block to invoke the Vehicle Registration Service from the Fine Collection Service;
- Use Azure Key Vault as a secret store Dapr building block for the Fine Collection Service.

The following diagram shows the architecture, that is the final state of this challenge:

![Architecture](../../assets/images/fine-collection-service-secret-store.png)

<span class="fs-3">
[Let's start!]({{ site.baseurl }}{% link modules/11-aca-challenge/00-intro/1-dapr-overview.md %}){: .btn .mt-7 }
</span>
