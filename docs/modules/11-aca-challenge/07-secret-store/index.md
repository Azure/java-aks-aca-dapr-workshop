---
title: Assignment 7 - Using Azure Key Vault as a secret store
parent: Azure Container Apps Challenge
has_children: true
nav_order: 8
layout: default
has_toc: true
---

This assignment is about using [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/) as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/) for the `FineCollectionService`. You will use the [Azure Key Vault secret store component](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/) provided by Dapr. This the fourth and last step to reach the final state of the application for this challenge. It is represented in the diagram below.

![Final architecture of the challenge](../../../assets/images/fine-collection-service-secret-store.png)

There are 3 main parts in this assignment:

1. [Setup of the Azure Key Vault as a secret store]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/1-setup-azure-key-vault.md %})
2. [Update of `FineCollectionService` to retrieve the license key from the Azure Key Vault using Dapr secret store component]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/2-use-secret-store-in-code.md %}). The license key is used by the fine calculator engine
3. [Use secrets of Azure Key Vault in the definition of other components]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/3-use-secret-in-dapr-component.md %}). Using Dapr, component definitions can reference secrets in a secret store. This is used to reference the Azure Service Bus connection string and the Azure Cosmos DB master key in the definition of the Azure Service Bus and Azure Cosmos DB components

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Assignment 6 - Cosmos DB as a state store]({{ site.baseurl }}{% link modules/11-aca-challenge/06-state-store/index.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Setup Azure Key Vault >]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/1-setup-azure-key-vault.md %}){: .btn .float-right .mt-7 }
</span>
