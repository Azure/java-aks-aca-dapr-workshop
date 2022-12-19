package dapr.fines.vehicle;

import io.dapr.client.DaprClient;
import io.dapr.client.domain.HttpExtension;

import java.time.Duration;

public class DaprVehicleRegistrationClient implements VehicleRegistrationClient {
    private final DaprClient daprClient;
		private final String vehicleRegistrationServiceName;

    public DaprVehicleRegistrationClient(final DaprClient daprClient, final String vehicleRegistrationServiceName) {
				this.daprClient = daprClient;
				this.vehicleRegistrationServiceName = vehicleRegistrationServiceName;
    }
    
	@Override
	public VehicleInfo getVehicleInfo(String licenseNumber) {
	    
	    var result = daprClient.invokeMethod(
	            vehicleRegistrationServiceName,
	            "vehicleinfo/" + licenseNumber,
	            null,
	            HttpExtension.GET,
	            VehicleInfo.class
	   );

	   return result.block(Duration.ofMillis(1000));
	}
}