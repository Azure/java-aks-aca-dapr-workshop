---
title: Running Applications without using Dapr
parent: Assignment 1 - Running Applications with Kafka without using Dapr
has_children: false
nav_order: 2
layout: default
has_toc: true
---

# Running Applications without using Dapr

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

In this assignment, you'll run the application to make sure everything works correctly.

## Assignment goals

To complete this assignment, you must reach the following goals:

- Apache Kafka - either run as a docker container (see below) or install and run on your machine ([download](https://kafka.apache.org/downloads))
- All services are running.
- The logging indicates that all services are working correctly.

## Step 1. Running Kafka using Docker or Rancher Desktop

From the root of **source code** folder, run the following command to configure and start Kafka from your locally installed Docker or Rancher Desktop:

```bash
docker-compose up -d
```

This command will read the docker-compose.yml file located within the root folder and download and run Kafka containers for this workshop.

## Step 2. Run the VehicleRegistration service

1. Open the source code folder in your code editor.

2. Open a terminal window.

3. Make sure the current folder is `VehicleRegistrationService`.

4. Start the service:

   ```bash
   mvn spring-boot:run
   ```

> If you receive an error here, please double-check whether or not you have installed all the [prerequisites](../Module0/index.md) for the workshop!

## Step 3. Run the FineCollection service

1. Make sure the VehicleRegistrationService service is running (result of step 1).

1. Open a **new** terminal window.

1. Make sure the current folder is `FineCollectionService`.

1. Start the service:

   ```bash
   mvn spring-boot:run
   ```

## Step 4. Run the TrafficControl service

1. Make sure the VehicleRegistrationService and FineCollectionService are running (results of step 1 and 2).

2. Open a **new** terminal window and make sure the current folder is `TrafficControlService`.

3. Start the service:

   ```bash
   mvn spring-boot:run
   ```

## Step 5. Run the simulation

Now you're going to run the simulation that actually simulates cars driving on the highway. The simulation will simulate 3 entry- and exit-cameras (one for each lane).

1. Open a new terminal window and make sure the current folder is `Simulation`.

2. Start the simulation:

   ```bash
   mvn spring-boot:run
   ```

3. In the simulation window you should see something like this:

   ```bash
   2021-09-15 13:47:59.599  INFO 22875 --- [           main] dapr.simulation.SimulationApplication    : Started SimulationApplication in 0.98 seconds (JVM running for 1.289)
   2021-09-15 13:47:59.603  INFO 22875 --- [pool-1-thread-2] dapr.simulation.Simulation               : Start camera simulation for lane 1
   2021-09-15 13:47:59.603  INFO 22875 --- [pool-1-thread-1] dapr.simulation.Simulation               : Start camera simulation for lane 0
   2021-09-15 13:47:59.603  INFO 22875 --- [pool-1-thread-3] dapr.simulation.Simulation               : Start camera simulation for lane 2
   2021-09-15 13:47:59.679  INFO 22875 --- [pool-1-thread-2] dapr.simulation.Simulation               : Simulated ENTRY of vehicle with license number 77-ZK-59 in lane 1
   2021-09-15 13:47:59.869  INFO 22875 --- [pool-1-thread-3] dapr.simulation.Simulation               : Simulated ENTRY of vehicle with license number LF-613-D in lane 2
   2021-09-15 13:48:00.852  INFO 22875 --- [pool-1-thread-1] dapr.simulation.Simulation               : Simulated ENTRY of vehicle with license number 12-LZ-KS in lane 0
   2021-09-15 13:48:04.797  INFO 22875 --- [pool-1-thread-2] dapr.simulation.Simulation               : Simulated  EXIT of vehicle with license number 77-ZK-59 in lane 0
   2021-09-15 13:48:04.894  INFO 22875 --- [pool-1-thread-3] dapr.simulation.Simulation               : Simulated  EXIT of vehicle with license number LF-613-D in lane 0
   ```

4. Also check the logging in all the other Terminal windows. You should see all entry- and exit events and any speeding-violations that were detected in the logging.

Now you know the application runs correctly. It's time to start adding Dapr to the application.

## Next assignment

Make sure you stop all running processes and close all the terminal windows before proceeding to the next assignment. Stopping a service or the simulation is done by pressing `Ctrl-C` in the terminal window.

<span class="fs-3">
[< Spring for Apache Kafka Usage]({{ site.baseurl }}{% link modules/01-assignment-1-lab/2-lab-instructions.md %}){: .btn .mt-7 }
</span>
<span class="fs-3">
[Assignment 2 - Run with Dapr >]({{ site.baseurl }}{% link modules/02-assignment-2-dapr-pub-sub/index.md %}){: .btn .float-right .mt-7 }
</span>
