package dapr.fines.fines;

import finefines.FineFines;

public class DefaultFineCalculator implements FineCalculator {
    private final String fineCalculatorLicenseKey;
    private final FineFines fineFines;

    public DefaultFineCalculator(final String fineCalculatorLicenseKey) {
        if (fineCalculatorLicenseKey == null) {
            throw new IllegalArgumentException("fineCalculatorLicenseKey");
        }
        this.fineCalculatorLicenseKey = fineCalculatorLicenseKey;
        this.fineFines = new FineFines();
    }

    @Override
    public int calculateFine(final int excessSpeed) {
        return fineFines.calculateFine(this.fineCalculatorLicenseKey, excessSpeed);
    }
}
