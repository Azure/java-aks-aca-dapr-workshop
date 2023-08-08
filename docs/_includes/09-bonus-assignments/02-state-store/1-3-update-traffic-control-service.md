1. Open the `TrafficControlService` project in your code editor and navigate to the `DaprVehicleStateRepository` class. This class use the Dapr client to store and retrieve the state of a vehicle. Inspect the implementation of this class.

1. Navigate to the `TrafficControlConfiguration` class to swith from the `InMemoryVehicleStateRepository` to the `DaprVehicleStateRepository`.

1. **Update** @Bean method to instantiate `DaprVehicleStateRepository` instead of `InMemoryVehicleStateRepository`:

    ```java
    @Bean
    public VehicleStateRepository vehicleStateRepository(final DaprClient daprClient) {
        return new DaprVehicleStateRepository(daprClient);
    }
    ```

1. **Uncomment** following @Bean method if not already done:
  
    ```java
    //    @Bean
    //    public DaprClient daprClient() {
    //        return new DaprClientBuilder()
    //                .withObjectSerializer(new JsonObjectSerializer())
    //                .build();
    //    }
    ```

1. Check all your code-changes are correct by building the code. Execute the following command in the terminal window:

    ```bash
    mvn package
    ```
