---
title: Retrieve a secret in the application
parent: Use Azure Keyvault as a secrets store
has_children: false
nav_order: 2
---

# Part 2 - Retrieve a secret in the application

Previously, you have created an Azure Key Vault and added the Dapr component. Now, you will use the secret in the application. If the setup of the Azure Key Vault is not done yet, please follow the instructions in `Part 1 - Setup Azure Key Vault as a secrets store`.

This bonus assignment is about using Azure Key Vault as a [secrets store](https://docs.dapr.io/operations/components/setup-secret-store/) for the `FineCollectionService` to get the license key.

## Step 1: Create a secret in the Azure Key Vault for the license key

1. Open a terminal window.
   
1. Create a secret in the Azure Key Vault for the license key:
    ```azurecli
    az keyvault secret set --vault-name kv-dapr-java-workshop --name license-key --value HX783-5PN1G-CRJ4A-K2L7V
    ```

## Step 2: Use the secret in the application `FineCollectionService`

1. Open the file `FineCollectionService/src/main/java/dapr/fines/fines/DaprCalulator.java` in your code editor, and inspect it

1. It implements the `FineCalculator` interface, which is used by the `FineCollectionService` to calculate the fine for a car. The `FineCalculator` interface has a method `calculateFine` that takes the `excessSpeed` as input and returns the amount of the fine as output. If the excess speed is too high, it return `-1`.
   
   The object `FineFines` that computes the fine requires a license Key. The license key is used to validate the license of the fine calculator. This `DaprFineCalculator` is getting the license key from the secrets store when the `FineCalculator` bean is created in the class `FineCollectionConfiguration`. The license key is stored in the secrets store with the name `license-key`.
   
    ```java
    public class DaprFineCalculator implements FineCalculator {
        private final String fineCalculatorLicenseKey;
        private final FineFines fineFines;

        public DaprFineCalculator(final DaprClient daprClient) {
            if (daprClient == null) {
                throw new IllegalArgumentException("daprClient");
            }
            final Map<String, String> licenseKeySecret = daprClient.getSecret("secretsstore", "license-key").block();
            if (licenseKeySecret == null || licenseKeySecret.isEmpty()) {
                throw new RuntimeException("'license-key' is not part of the secrets store.");
            }
            this.fineCalculatorLicenseKey = licenseKeySecret.get("license-key");
            this.fineFines = new FineFines();
        }

        @Override
        public int calculateFine(final int excessSpeed) {
            return fineFines.calculateFine(this.fineCalculatorLicenseKey, excessSpeed);
        }
    }
    ```

1. Open the file `FineCollectionService/src/main/java/dapr/fines/FineCollectionConfiguration.java` in your code editor

1. **Comment out** the following lines as the license key is now retrieved from the secrets store instead of the environment variable:
    ```java
    @Value("${finefines.license-key}")
    private String fineCalculatorLicenseKey;
    ```

1. **Comment out** the following @Bean method that creates the bean `FineCalculator`:
    ```java
    @Bean
    public FineCalculator fineCalculator() {
        return new DefaultFineCalculator(fineCalculatorLicenseKey);
    }
    ```

1. **Uncomment** the following @Bean method that creates the bean `FineCalculator`:
    ```java
    // @Bean
    // public FineCalculator fineCalculator(final DaprClient daprClient) {
    //     return new DaprFineCalculator(daprClient);
    // }
    ```

    This method requires the `DaprClient` as input.

1. **Uncomment** the following @Bean method that creates the bean `DaprClient`:
    ```java
    //    @Bean
    //    public DaprClient daprClient() {
    //        return new DaprClientBuilder().build();
    //    }
    ``` 

## Step 3: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

2. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

3. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```console
   mvn spring-boot:run
   ```

4. Open a **new** terminal window and change the current folder to `FineCollectionService`.

5. Enter the following command to run the FineCollectionService with a Dapr sidecar:
  * Ensure you have run `dapr init` command prior to running the below command

   ```console
   dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
   ```

6. Open a **new** terminal window and change the current folder to `TrafficControlService`.

7. Enter the following command to run the TrafficControlService:

   ```console
   mvn spring-boot:run
   ```

8. Open a **new** terminal window and change the current folder to `Simulation`.

9. Start the simulation:

   ```console
   mvn spring-boot:run
   ```

You should see the same logs as **Assignment 1**. Obviously, the behavior of the application is exactly the same as before.