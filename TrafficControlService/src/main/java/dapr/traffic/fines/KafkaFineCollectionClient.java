package dapr.traffic.fines;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;

import dapr.traffic.violation.SpeedingViolation;

public class KafkaFineCollectionClient implements FineCollectionClient {
	
	@Autowired
	private KafkaTemplate<String, SpeedingViolation> kafkaTemplate;

	@Override
	public void submitForFine(SpeedingViolation speedingViolation) {
		kafkaTemplate.send("test", speedingViolation);

	}

}
