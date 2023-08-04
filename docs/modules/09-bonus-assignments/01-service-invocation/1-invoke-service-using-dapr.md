---
title: Invoke Vehicle Registration Service from Fine Collection Service
parent: Service invocation using Dapr
grand_parent: Bonus Assignments
has_children: false
nav_order: 1
layout: default
has_toc: true
---

# Invoke Vehicle Registration Service from Fine Collection Service

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

In this assignment, you will use Dapr to invoke the `VehicleRegistrationService` from the `FineCollectionService`. You will use the [service invocation building block](https://docs.dapr.io/developing-applications/building-blocks/service-invocation/service-invocation-overview/) provided by Dapr.

<!-- ------------ STEP 1 - INVOKE VEHICLE REGISTRATION SERVICE ------------- -->

{% assign stepNumber = 1 %}
{% include 09-bonus-assignments/01-service-invocation/1-use-dapr-to-invoke-vehicle-registration-service.md %}

Now you can test the application.

{% assign stepNumber = stepNumber | plus: 1 %}
## Step {{stepNumber}}: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```bash
   dapr run --app-id vehicleregistrationservice --app-port 6002 --dapr-http-port 3602 --dapr-grpc-port 60002 --components-path ../dapr/components mvn spring-boot:run
   ```

   `FineCollectionService` Dapr sidecar uses Vehicle Registration Service `app-id` to resolve the service invocation endpoint. The name (i.e. `app-id`) of `VehicleRegistrationService` is set in the application properties of `FineCollectionService` (i.e. `application.yaml`) as shown below:

   ```yaml
   vehicle-registration-service.name: ${VEHICLE_REGISTRATION_SERVICE:vehicleregistrationservice}
   ```

   The default value is `vehicleregistrationservice` that can be override using the environment variable `VEHICLE_REGISTRATION_SERVICE`.

1. Open a **new** terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:

   ```bash
   dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService with a Dapr sidecar:

   ```bash
   dapr run --app-id trafficcontrolservice --app-port 6000 --dapr-http-port 3600 --dapr-grpc-port 60000 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```bash
   mvn spring-boot:run
   ```

You should see the same logs as before. Obviously, the behavior of the application is exactly the same as before.

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[Deploy to AKS]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/2-deploying-to-aks.md %}){: .btn }
</span>
<span class="fs-3">
[Deploy to ACA]({{ site.baseurl }}{% link modules/09-bonus-assignments/01-service-invocation/3-deploying-to-aca.md %}){: .btn }
</span>