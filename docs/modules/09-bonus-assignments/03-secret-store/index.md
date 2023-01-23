---
title: Use Azure Keyvault as a secret store
parent: Bonus Assignments
has_children: true
nav_order: 3
layout: default
---

# Use Azure Keyvault as a secret store

This bonus assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/) for the `FineCollectionService`. You will use the [Azure Key Vault secret store component](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/) provided by Dapr.

The [first part]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/1-azure-key-vault-secret-store-setup.md %}) is the setup of the Azure Key Vault. The [second part]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/2-azure-key-vault-secret-store-code.md %}) is the configuration of the `FineCollectionService` to use the Azure Key Vault as a secret store for the license key of the fine calculator. The [third part]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/3-azure-key-vault-secret-store-component.md %}) is to use the secret store in the `FineCollectionService` and the `TrafficControllerService` to get the connection string for Azure Service Bus.

{: .note }
> The first part is a pre-requisite for the second and third part. The second and third part can be done in any order.
>
