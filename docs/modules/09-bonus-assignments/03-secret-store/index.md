---
title: Using Azure Key Vault as a secret store
parent: Bonus Assignments
has_children: true
nav_order: 3
layout: default
---

# Using Azure Key Vault as a secret store

This bonus assignment is about using [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/) as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/) for the `FineCollectionService`. You will use the [Azure Key Vault secret store component](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/) provided by Dapr.

There are 3 main parts in this bonus assignment:

1. [Setup of the Azure Key Vault as a secret store]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/1-setup-azure-key-vault.md %})
2. [Update of `FineCollectionService` to retrieve the license key from the Azure Key Vault using Dapr secret store component]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/2-use-secret-store-in-code.md %}). The license key is used by the fine calculator engine
3. [Use secrets of Azure Key Vault in the definition of other components]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/3-use-secret-in-dapr-component.md %}). Using Dapr, component manifests can reference secrets in a secret store. This is used to reference the Azure Service Bus connection string and the Azure Cosmos DB master key in the definition of the Azure Service Bus and Azure Cosmos DB components

{: .important-title }
> Pre-requisite
> 
> The first part is a pre-requisite for the second and third part. The second and third part can be done in any order.
>

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[Let's start!]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/1-setup-azure-key-vault.md %}){: .btn .mt-7 }
</span>
