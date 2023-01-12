package dapr.fines.fines;

import java.util.Map;

import finefines.FineFines;
import io.dapr.client.DaprClient;

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
