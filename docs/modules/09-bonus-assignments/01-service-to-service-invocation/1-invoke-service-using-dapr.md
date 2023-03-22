---
title: Invoke Vehicle Registration Service from Fine Collection Service
parent: Service-to-service invocation using Dapr
grand_parent: Bonus Assignments
has_children: false
nav_order: 1
layout: default
---

# Invoke Vehicle Registration Service from Fine Collection Service

## Step 1: Use Dapr to invoke the Vehicle Registration Service from the Fine Collection Service

With Dapr, services can invoke other services using their application id. This is done by using the Dapr client to make calls to the Dapr sidecar. The Vehicle Registration Service will be started with a Dapr sidecar.

1. Open the `FineCollectionService` project in your code editor and navigate to the `DaprVehicleRegistrationClient` class. This class implements the `VehicleRegistrationClient` interface and uses the Dapr client to invoke the Vehicle Registration Service. Inspect the implementation of this class.

2. Navigate to the `FineCollectionConfiguration` class to switch between the default and Dapr implementation of the `VehicleRegistrationClient`.

3. **Uncomment** following @Bean method

    ```java
    //    @Bean
    //    public VehicleRegistrationClient vehicleRegistrationClient(final DaprClient daprClient) {
    //        return new DaprVehicleRegistrationClient(daprClient);
    //    }
    ```

4. **Uncomment** following @Bean method
  
    ```java
    //    @Bean
    //    public DaprClient daprClient() {
    //        return new DaprClientBuilder().build();
    //    }
    ```

5. **Comment out** following @Bean method

    ```java
        @Bean
        public VehicleRegistrationClient vehicleRegistrationClient(final RestTemplate restTemplate) {
            return new DefaultVehicleRegistrationClient(restTemplate, vehicleInformationAddress);
        }
    ```

6. Check all your code-changes are correct by building the code. Execute the following command in the terminal window:

    ```bash
    mvn package
    ```

Now you can test the application

## Step 2: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```bash
   dapr run --app-id vehicleregistrationservice --app-port 6002 --dapr-http-port 3602 --dapr-grpc-port 60002 --components-path ../dapr/components mvn spring-boot:run
   ```

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