package dapr.traffic.vehicle;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Optional;

public class DaprVehicleStateRepository implements VehicleStateRepository {
	
    private static final String DAPR_STORE_NAME = "statestore";
    
    private static class DaprStateEntry {
        private final String key;
        private final VehicleState value;

        public DaprStateEntry(final String key, final VehicleState value) {
            this.key = key;
            this.value = value;
        }

        public String getKey() {
            return this.key;
        }

        public VehicleState getValue() {
            return this.value;
        }
    }

    private final RestTemplate restTemplate;

    public DaprVehicleStateRepository(final RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public VehicleState saveVehicleState(VehicleState vehicleState) {
        var entries = new DaprStateEntry[] {
                new DaprStateEntry(vehicleState.licenseNumber(), vehicleState)
        };

        var daprUrl = System.getProperty("DAPR_BASE_URL", "http://localhost:3600/v1.0/state/");
        restTemplate.postForEntity(daprUrl + DAPR_STORE_NAME, entries, Object.class);

        return vehicleState;
    }

    @Override
    public Optional<VehicleState> getVehicleState(String licenseNumber) {
    	var daprUrl = System.getProperty("DAPR_BASE_URL", "http://localhost:3600/v1.0/state/");
        var state = restTemplate.getForObject(daprUrl + DAPR_STORE_NAME + "/" + licenseNumber, VehicleState.class);

        return Optional.ofNullable(state);
    }
}
