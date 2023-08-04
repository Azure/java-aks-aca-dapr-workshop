<!-- Require 'stepNumber' as input: the number of the first step of this include.
Return the number of the last step in this include -->
## Step {{stepNumber}}: Use Dapr to invoke the Vehicle Registration Service from the Fine Collection Service

With Dapr, services can invoke other services using their application id. This is done by using the Dapr client to make calls to the Dapr sidecar. The Vehicle Registration Service will be started with a Dapr sidecar.

1. Open the `FineCollectionService` project in your code editor and navigate to the `DaprVehicleRegistrationClient` class. This class implements the `VehicleRegistrationClient` interface and uses the Dapr client to invoke the Vehicle Registration Service. Inspect the implementation of this class.

2. Navigate to the `FineCollectionConfiguration` class to switch between the default and Dapr implementation of the `VehicleRegistrationClient`.

3. **Uncomment** following @Bean method:

    ```java
    //    @Bean
    //    public VehicleRegistrationClient vehicleRegistrationClient(final DaprClient daprClient) {
    //        return new DaprVehicleRegistrationClient(daprClient);
    //    }
    ```

4. **Uncomment** following @Bean method, if not already done:
  
    ```java
    //    @Bean
    //    public DaprClient daprClient() {
    //        return new DaprClientBuilder().build();
    //    }
    ```

5. **Comment out** following @Bean method:

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
