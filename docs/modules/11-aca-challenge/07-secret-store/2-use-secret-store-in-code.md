---
title: Retrieve a secret in the application
parent: Assignment 7 - Using Azure Key Vault as a secret store
grand_parent: Azure Container Apps Challenge
has_children: false
nav_order: 2
layout: default
has_toc: true
---

# Retrieve a secret in the application

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

Previously, you have created an Azure Key Vault and added the Dapr component to Azure Container Apps environmnet. Now, you will use the [secret in the application](https://docs.dapr.io/developing-applications/building-blocks/secrets/howto-secrets/). This second part of the assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/) for the `FineCollectionService` to get the license key of the fine calculator.

<!-- -------------------- CREATE SECRET AND UPDATE CODE -------------------- -->

{% include 09-bonus-assignments/03-secret-store/2-use-secret-store-in-code.md %}

## Step 3: Build and redeploy fine collection service

{% include 09-bonus-assignments/03-secret-store/5-2-a-rebuild-fine-collection-service.md %}

<!-- -------------------------------- TEST --------------------------------- -->

{% assign stepNumber = 4 %}
{% include 05-assignment-5-aks-aca/02-aca/0-3-test-application.md %}

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Setup Azure Key Vault]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/1-setup-azure-key-vault.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Reference a secret in Dapr components >]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/3-use-secret-in-dapr-component.md %}){: .btn .float-right .mt-7 }
</span>
