---
title: Reference a secret in Dapr components
parent: Assignment 7 - Using Azure Key Vault as a secret store
grand_parent: Azure Container Apps Challenge
has_children: false
nav_order: 3
layout: default
has_toc: true
---

# Reference a secret in Dapr components

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

Previously, you have use a secret in `FineCollectionService` code using the `secretstore` component (i.e. Azure Key Vault). Now you will [use a secret from a secret store in another Dapr component](https://docs.dapr.io/operations/components/component-secrets/). This third part of the assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/) to store the connection string of the Azure Service Bus and use it in the `pubsub` component.

<!-- ------------------------ SET CONNECTION STRING ------------------------ -->

{% include 09-bonus-assignments/03-secret-store/3-1-create-sb-connection-string-secret.md %}

## Step 2: Use a secret in `pubsub` component

{% include 09-bonus-assignments/03-secret-store/5-2-b-1-use-secret-in-pubsub.md %}

## Step 3: Restart `FineCollectionService` and `TrafficControlService`

{% include 09-bonus-assignments/03-secret-store/5-2-b-2-restart-services.md %}

<!-- -------------------------------- TEST --------------------------------- -->

{% assign stepNumber = 4 %}
{% include 05-assignment-5-aks-aca/02-aca/0-3-test-application.md %}

{: .new-title }
> Challenge
>
> You can use the secret store to store Cosmos DB master key as well. Try it out! More information on Cosmos DB as a state store can be found in [Bonus Assignment: State Store]({{ site.baseurl }}{% link modules/09-bonus-assignments/02-state-store/index.md %}).
>

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Retreive a secret in the application]({{ site.baseurl }}{% link modules/11-aca-challenge/07-secret-store/2-use-secret-store-in-code.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Assignment 8 - Managed Identities >]({{ site.baseurl }}{% link modules/11-aca-challenge/08-managed-identities/index.md %}){: .btn .float-right .mt-7 }
</span>
