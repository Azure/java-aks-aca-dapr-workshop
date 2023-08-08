---
title: Introduction
has_children: false
nav_order: 1
layout: home
---

# Workshop to implement Pub/Sub and Observability in Java Applications using Dapr

## Introduction

This workshop teaches you how to apply [Dapr](https://dapr.io) to a Java microservices application and enable developers to move between multiple pub-sub, state stores and secret store components seamlessly. It also demonstrates Dapr's builtin support for [distributed tracing](https://docs.dapr.io/concepts/observability-concept/) using any backend monitoring tools. Finally, the workshop provides hands on experience in deploying the microservices in both [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/) and [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview)

### The domain

For the assignments you will be working with a speeding-camera setup as can be found on several Dutch highways. This is an overview of the fictitious setup you're simulating:

![Speeding cameras](assets/images/speed-trap-overview.png)

There's 1 entry-camera and 1 exit-camera per lane. When a car passes an entry-camera, the license-number of the car and the timestamp is registered.

When the car passes an exit-camera, this timestamp is also registered by the system. The system then calculates the average speed of the car based on the entry- and exit-timestamp. If a speeding violation is detected, a message is sent to the Central Fine Collection Agency (or CJIB in Dutch). They will retrieve the information of the owner of the vehicle and send him or her a fine.

### Architecture

At the begining of the workshop, the microservices application is as follows:

![Services](assets/images/application-diagram-without-dapr.png)

1. The **Camera Simulation** generates a random license-number and sends a *VehicleRegistered* message (containing this license-number, a random entry-lane (1-3) and the timestamp) to the `/entrycam` endpoint of the TrafficControlService.
2. The **Traffic Control Service** stores the *VehicleState* (license-number and entry-timestamp).
3. After some random interval, the Camera Simulation sends a *VehicleRegistered* message to the `/exitcam` endpoint of the TrafficControlService (containing the license-number generated in step 1, a random exit-lane (1-3) and the exit timestamp).
4. The TrafficControlService retrieves the *VehicleState* that was stored at vehicle entry.
5. The TrafficControlService calculates the average speed of the vehicle using the entry- and exit-timestamp. It also stores the *VehicleState* with the exit timestamp for audit purposes, but this is left out of the sequence diagram for clarity.
6. If the average speed is above the speed-limit, the TrafficControlService publishes *SpeedingViolation* payload to kafka topic *test*. 
7. The FineCollectionService subscribes to kafka topic *test*.
8. The FineCollectionService calculates the fine for the speeding-violation.
9. The FineCollectionSerivice calls the `/vehicleinfo/{license-number}` endpoint of the VehicleRegistrationService with the license-number of the speeding vehicle to retrieve its vehicle- and owner-information.
10. The **Vehicle Registration Service** offers 1 HTTP endpoint: `/getvehicleinfo/{license-number}` for getting the vehicle- and owner-information of a vehicle.

### End-state with Dapr applied

During the workshop, you will be adding Dapr to the microservices application to use several pub/sub components and you will deploy the application to AKS and ACA. After completing all the assignments (including the bonus assignments), you should have the following architcture:

![End State with Dapr Telemetry](assets/images/workshop-end-state.png)

The pub/sub component could differ from the one used in the diagram above. You can also try other state stores and secret stores. Please refer to the [Dapr documentation](https://docs.dapr.io/) for more information.

If you want to deploy the architecture above to Azure Container Apps, you can follow the [Azure Container Apps Challenge]({{ site.baseurl }}{% link modules/11-aca-challenge/index.md %}) that is a step-by-step workshop dedicated to Azure Container Apps, Dapr, Keda and Java.

<span class="fs-3">
[Let's start!]({{ site.baseurl }}{% link modules/00-intro/1-dapr-overview.md %}){: .btn .mt-7 }
</span>
