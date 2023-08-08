---
title: Setup Azure Key Vault as a secret store
parent: Using Azure Key Vault as a secret store
grand_parent: Bonus Assignments
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

This bonus assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/). You will create the [Azure Key Vault secret store component](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/) provided by Dapr.

<!-- ------------------------ SETUP AZURE KEYVAULT ------------------------- -->

{% assign stepNumber = 1 %}
{% include 09-bonus-assignments/03-secret-store/1-setup-azure-key-vault.md %}

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}}: Set the Azure Key Vault secret store component

1. **Copy or Move** this file `dapr/azure-keyvault-secretstore.yam` to `dapr/components/` folder.

1. Open the copied file `dapr/components/azure-keyvault-secretstore.yaml` in your code editor.

1. Set the following values in the metadata section of the component:
    - `vaultName`: The name of the Azure Key Vault you created in step 3.
    - `azureTenantId`: The value for `tenant` you noted down in step 1.
    - `azureClientId`: The value for `appId` you noted down in step 1.
    - `azureClientSecret`: The value for `password` you noted down in step 1.

{: .important }
> Certificate can be used instead of client secret, see [Azure Key Vault secret store](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/).
>
> When deployed to Azure Kubernetes Service, the client secret is a kubernetes secret and not set in the component's YAML file. See the *Kubernetes* tab in *Configure the component* of [Azure Key Vault secret store](https://docs.dapr.io/reference/components-reference/supported-secret-stores/azure-keyvault/).
>
> When deployed to Azure Kubernetes Service and Azure Container Apps, managed identity can should used instead of client secret for production workloads. See [Using Managed Service Identities](https://docs.dapr.io/developing-applications/integrations/azure/azure-authentication/authenticating-azure/#about-authentication-with-azure-ad).
>

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[Retreive a secret in the application]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/2-use-secret-store-in-code.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Reference a secret in a component]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/3-use-secret-in-dapr-component.md %}){: .btn .ml-3 }
</span>
