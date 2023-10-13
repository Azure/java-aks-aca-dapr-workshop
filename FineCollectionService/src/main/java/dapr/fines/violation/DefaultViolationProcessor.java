package dapr.fines.violation;

import dapr.fines.fines.FineCalculator;
import dapr.fines.vehicle.VehicleInfo;
import dapr.fines.vehicle.VehicleRegistrationClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.format.DateTimeFormatter;

import dapr.traffic.violation.SpeedingViolation;

public class DefaultViolationProcessor implements ViolationProcessor {
    private static final Logger log = LoggerFactory.getLogger(DefaultViolationProcessor.class);

    private final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("LLLL, dd y");
    private final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm:ss");

    private final FineCalculator fineCalculator;
    private final VehicleRegistrationClient vehicleRegistrationClient;

    public DefaultViolationProcessor(final FineCalculator fineCalculator,
                                final VehicleRegistrationClient vehicleRegistrationClient) {
        this.fineCalculator = fineCalculator;
        this.vehicleRegistrationClient = vehicleRegistrationClient;
    }

    public void processSpeedingViolation(final SpeedingViolation violation) {
        int fine = fineCalculator.calculateFine(violation.excessSpeed());
        String fineText = fine == -1 ? "to be decided by the prosecutor" : String.format("EUR %.2f", (float) fine);
        final VehicleInfo vehicleInfo = vehicleRegistrationClient.getVehicleInfo(violation.licenseNumber());

        final String fineMessage = constructLogMessage(violation, vehicleInfo, fineText);
        log.info(fineMessage);
    }

    private String constructLogMessage(final SpeedingViolation violation, final VehicleInfo vehicleInfo, final String fineText) {
        final String date = DATE_FORMAT.format(violation.timestamp());
        final String time = TIME_FORMAT.format(violation.timestamp());

        return String.format("""
                        Sent fine notification
                        \t\t\tTo %s, registered owner of license number %s.
                        \t\t\tViolation of %d km/h detected on the %s road on %s at %s.
                        \t\t\tFine: %s.%n
                        """,
                vehicleInfo.ownerName(),
                violation.licenseNumber(),
                violation.excessSpeed(),
                violation.roadId(),
                date,
                time,
                fineText
        );
    }
}
