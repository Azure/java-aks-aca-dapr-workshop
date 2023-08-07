---
title: Setup Azure Key Vault as a secret store
parent: Assignment 7 - Using Azure Key Vault as a secret store
grand_parent: Azure Container Apps Challenge
has_children: false
nav_order: 1
layout: default
has_toc: true
---

# Setup Azure Key Vault as a secret store

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

The first part of this assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/). It consists in the creation of the Azure Key Vault resource and the deployment of [Azure Key Vault secret store component](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/) to Azure Container Apps environment.

<!-- ------------------------ SETUP AZURE KEYVAULT ------------------------- -->

{% assign stepNumber = 1 %}
{% include 09-bonus-assignments/03-secret-store/1-setup-azure-key-vault.md %}

<!-- ---------------- DEPLOY SECRET STORE COMPONENT TO ACA ----------------- -->

{% assign stepNumber = stepNumber | plus: 1 %}
{% include 09-bonus-assignments/03-secret-store/5-1-deploy-secret-store-component-to-aca.md %}

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Assignment 7 - Key Vault as a secret store]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/index.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Retreive a secret in the application >]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/2-use-secret-store-in-code.md %}){: .btn .float-right .mt-7 }
</span>
