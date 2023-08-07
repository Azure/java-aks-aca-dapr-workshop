---
title: Deploying Azure Key Vault secret store to Azure Container Apps
parent: Using Azure Key Vault as a secret store
grand_parent: Bonus Assignments
has_children: false
nav_order: 5
layout: default
has_toc: true
---

# Deploying Azure Key Vault secret store to Azure Container Apps

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

In this bonus assignment, you will deploy the Azure Key Vault secret store to Azure Container Apps. You will use the [secret management building block](https://docs.dapr.io/developing-applications/building-blocks/secrets/) provided by Dapr. The first step is the deployment of the `secretstore` component to Azure Container Apps.

It is followed by 2 steps that can be done in any order (at least one of them must be done):

- a. Deploy `FineCollectionService` to use the secret store for the license key of fine calculator
- b. Use the secret store for the service bus connection string of the `pubsub` component

{: .important-title }
> Pre-requisite
>
> If the setup of the Azure Key Vault is not done yet, please follow the instructions in [Setup Azure Key Vault as a secret store]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/1-setup-azure-key-vault.md %}).
>

<!-- ---------------- DEPLOY SECRET STORE COMPONENT TO ACA ----------------- -->

{% assign stepNumber = 1 %}
{% include 09-bonus-assignments/03-secret-store/5-1-deploy-secret-store-component-to-aca.md %}

## Step 2: Deploy to Azure Container Apps

### Step 2.a: Retrieve a secret in the application

{: .important-title }
> Pre-requisite
>
> The second part [Retrieve a secret in the application]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/2-use-secret-store-in-code.md %}) is a pre-requisite for this step.
>

To deploy the retrieving of the license key of the fine calculator to Azure Container Apps, you will need to update the `FineCollectionService` container app to use the secret store for the license key of fine calculator.

#### Build and redeploy fine collection service

{% include 09-bonus-assignments/03-secret-store/5-2-a-rebuild-fine-collection-service.md %}

### Step 2.b: Reference a secret in Dapr components

{: .important-title }
> Pre-requisite
>
> The third part [Reference a secret in Dapr components]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/3-use-secret-in-dapr-component.md %}) is a pre-requisite for this step.
>

#### Use a secret in `pubsub` component

{% include 09-bonus-assignments/03-secret-store/5-2-b-1-use-secret-in-pubsub.md %}

#### Restart `FineCollectionService` and `TrafficControlService`

{% include 09-bonus-assignments/03-secret-store/5-2-b-2-restart-services.md %}

<!-- -------------------------------- TEST --------------------------------- -->

{% assign stepNumber = 3 %}
{% include 05-assignment-5-aks-aca/02-aca/0-3-test-application.md %}

{: .important-title }
> Cleanup
>
> When the workshop is done, please follow the [cleanup instructions]({{ site.baseurl }}{% link modules/10-cleanup/index.md %}) to delete the resources created in this workshop.
> 

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< Secret Store setup]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/1-setup-azure-key-vault.md %}){: .btn .mt-7 }
</span>
