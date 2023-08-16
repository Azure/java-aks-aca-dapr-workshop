## Step 1: Create a secret in the Azure Key Vault for the license key

1. Open a terminal window.
   
1. Create a secret in the Azure Key Vault for the license key:

    ```bash
    az keyvault secret set --vault-name $KEY_VAULT --name license-key --value HX783-5PN1G-CRJ4A-K2L7V
    ```

## Step 2: Use the secret in the application `FineCollectionService`

1. Open the file `FineCollectionService/src/main/java/dapr/fines/fines/DaprFineCalulator.java` in your code editor, and inspect it.

    It implements the `FineCalculator` interface, which is used by the `FineCollectionService` to calculate the fine for a car. The `FineCalculator` interface has a method `calculateFine` that takes the `excessSpeed` as input and returns the amount of the fine as output. If the excess speed is too high, it return `-1`.
   
    The object `FineFines` that computes the fine requires a license Key. The license key is used to validate the license of the fine calculator. This `DaprFineCalculator` is getting the license key from the secret store when the `FineCalculator` bean is created in the class `FineCollectionConfiguration`. The license key is stored in the secret store with the name `license-key`.
   
    ```java
    public class DaprFineCalculator implements FineCalculator {
        private final String fineCalculatorLicenseKey;
        private final FineFines fineFines;

        public DaprFineCalculator(final DaprClient daprClient) {
            if (daprClient == null) {
                throw new IllegalArgumentException("daprClient");
            }
            final Map<String, String> licenseKeySecret = daprClient.getSecret("secretstore", "license-key").block();
            if (licenseKeySecret == null || licenseKeySecret.isEmpty()) {
                throw new RuntimeException("'license-key' is not part of the secret store.");
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

1. Open the file `FineCollectionService/src/main/java/dapr/fines/FineCollectionConfiguration.java` in your code editor.

1. **Comment out** the following lines as the license key is now retrieved from the secret store instead of the environment variable:
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

1. Check all your code-changes are correct by building the code. Execute the following command in the terminal window:

    ```bash
    mvn package
    ```
