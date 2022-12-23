package dapr.fines;

import dapr.fines.fines.DefaultFineCalculator;
import dapr.fines.fines.FineCalculator;
import dapr.fines.vehicle.DefaultVehicleRegistrationClient;
import dapr.fines.vehicle.VehicleRegistrationClient;
import dapr.fines.violation.DaprViolationProcessor;
import dapr.fines.violation.DefaultViolationProcessor;
import dapr.fines.violation.ViolationProcessor;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;
import dapr.fines.vehicle.DaprVehicleRegistrationClient;
import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;

@Configuration
public class FineCollectionConfiguration {
    // We need to pass this key with every invocation of the FineFines library
    @Value("${finefines.license-key}")
    private String fineCalculatorLicenseKey;

    @Value("${vehicle-information.address}")
    private String vehicleInformationAddress;

    @Value("${vehicle-registration-service.name}")
    private String vehicleRegistrationServiceName;

    @Bean
    public FineCalculator fineCalculator() {
        return new DefaultFineCalculator(fineCalculatorLicenseKey);
    }

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
    
//    @Bean
//    public VehicleRegistrationClient vehicleRegistrationClient(final DaprClient daprClient) {
//        return new DaprVehicleRegistrationClient(daprClient, vehicleRegistrationServiceName);
//    }
    
   @Bean
    public VehicleRegistrationClient vehicleRegistrationClient(final RestTemplate restTemplate) {
        return new DefaultVehicleRegistrationClient(restTemplate, vehicleInformationAddress);
   }

   @Bean
   public ViolationProcessor violationProcessor(final FineCalculator fineCalculator, final VehicleRegistrationClient vehicleRegistrationClient) {
       return new DefaultViolationProcessor(fineCalculator, vehicleRegistrationClient);
   }
    

//    @Bean
//    public ViolationProcessor violationProcessor(final DaprClient daprClient, final FineCalculator fineCalculator, final VehicleRegistrationClient vehicleRegistrationClient) {
//        return new DaprViolationProcessor(daprClient, fineCalculator, vehicleRegistrationClient);
//    }
    
//    @Bean
//    public DaprClient daprClient() {
//        return new DaprClientBuilder().build();
//    }
}
