---
title: Retrieve a secret in the application
parent: Using Azure Key Vault as a secret store
grand_parent: Bonus Assignments
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

Previously, you have created an Azure Key Vault and added the Dapr component. Now, you will use the [secret in the application](https://docs.dapr.io/developing-applications/building-blocks/secrets/howto-secrets/). This bonus assignment is about using Azure Key Vault as a [secret store](https://docs.dapr.io/operations/components/setup-secret-store/) for the `FineCollectionService` to get the license key of the fine calculator.

{: .important-title }
> Pre-requisite
>
> If the setup of the Azure Key Vault is not done yet, please follow the instructions in [Setup Azure Key Vault as a secret store]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/1-setup-azure-key-vault.md %}).
>

<!-- -------------------- CREATE SECRET AND UPDATE CODE -------------------- -->

{% include 09-bonus-assignments/03-secret-store/2-use-secret-store-in-code.md %}

## Step 3: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService:

   ```bash
   mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:
   
    * Ensure you have run `dapr init` command prior to running the below command

    ```bash
    dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --resources-path ../dapr/components mvn spring-boot:run
    ```

1. Open a **new** terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService:

   ```bash
   mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```bash
   mvn spring-boot:run
   ```

You should see the same logs as **Assignment 1**. Obviously, the behavior of the application is exactly the same as before.

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[Reference a secret in a component]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/3-use-secret-in-dapr-component.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Deploy to ACA]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/5-deploying-to-aca.md %}){: .btn }
</span>
