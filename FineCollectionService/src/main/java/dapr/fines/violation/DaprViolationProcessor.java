package dapr.fines.violation;

import dapr.fines.fines.FineCalculator;
import dapr.fines.vehicle.VehicleInfo;
import dapr.fines.vehicle.VehicleRegistrationClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.StringWriter;
import java.time.format.DateTimeFormatter;
import java.util.Map;

import dapr.traffic.violation.SpeedingViolation;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateExceptionHandler;
import io.dapr.client.DaprClient;

public class DaprViolationProcessor implements ViolationProcessor {
    private static final Logger log = LoggerFactory.getLogger(DefaultViolationProcessor.class);

    private static final String BINDING_NAME = "smtp";
    private static final String BINDING_OPERATION = "create";

    private final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("LLLL, dd y");
    private final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm:ss");

    private final DaprClient daprClient;
    private final FineCalculator fineCalculator;
    private final VehicleRegistrationClient vehicleRegistrationClient;
    private final Configuration templateConfiguration;

    public DaprViolationProcessor(final DaprClient daprClient,
                                final FineCalculator fineCalculator,
                                final VehicleRegistrationClient vehicleRegistrationClient) {
        this.daprClient = daprClient;
        this.fineCalculator = fineCalculator;
        this.vehicleRegistrationClient = vehicleRegistrationClient;
        this.templateConfiguration = new Configuration(Configuration.VERSION_2_3_30);
        this.templateConfiguration.setClassForTemplateLoading(DefaultViolationProcessor.class, "/email");
        this.templateConfiguration.setDefaultEncoding("UTF-8");
        this.templateConfiguration.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
    }

    public void processSpeedingViolation(final SpeedingViolation violation) {
        int fine = fineCalculator.calculateFine(violation.excessSpeed());
        final VehicleInfo vehicleInfo = vehicleRegistrationClient.getVehicleInfo(violation.licenseNumber());

        final String nowDate = DATE_FORMAT.format(violation.timestamp());
        final String dateSpeedingViolation = DATE_FORMAT.format(violation.timestamp());
        final String timeSpeedingViolation = TIME_FORMAT.format(violation.timestamp());
        final Map<String, Object> metadataEmailTemplate = Map.of(
            "customerName", vehicleInfo.ownerName(),
            "fineDate", nowDate,
            "vehicleBrand", vehicleInfo.make(),
            "vehicleModel", vehicleInfo.model(),
            "vehicleLicenseNumber", violation.licenseNumber(),
            "road", violation.roadId(),
            "timeOfDay", timeSpeedingViolation,
            "violationDate", dateSpeedingViolation,
            "excessSpeed", violation.excessSpeed(),
            "fineAmount", fine);
        Template template;
        try {
            template = templateConfiguration.getTemplate("email-template.ftl");
            final StringWriter writer = new StringWriter();
            template.process(metadataEmailTemplate, writer);
            writer.flush();
            final String emailBody = writer.toString();

            final Map<String, String> metadataBinding = Map.of(
            "emailFrom", "donotreply@roadtothe.cloud",
            "emailTo", "pmalarme@roadtothe.cloud",
            "subject", "Speeding violation on the " + violation.roadId() + " for vehicle " + violation.licenseNumber(),
            "priority", "1");
        daprClient.invokeBinding(BINDING_NAME, BINDING_OPERATION, emailBody, metadataBinding, String.class).block();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
