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
- Use the service invocation building block of Dapr to invoke the Vehicle Registration Service from the Fine Collection Service;
- Use Azure Key Vault as a secret store Dapr building block for the Fine Collection Service.
- Use managed identities to access Azure resources from the microservices.
- Use scale rule to scale the Fine Collection Service based on the number of messages in the topic.

The following diagram shows the architecture, that is the final state of this challenge:

![Final architecture of the challenge](../../assets/images/workshop-end-state.png)

<span class="fs-3">
[Let's start!]({{ site.baseurl }}{% link modules/11-aca-challenge/00-intro/1-dapr-overview.md %}){: .btn .mt-7 }
</span>
