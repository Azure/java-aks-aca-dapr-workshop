package dapr.fines.violation;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import dapr.traffic.violation.SpeedingViolation;

@Component
public class KafkaViolationConsumer {
	private final ViolationProcessor violationProcessor;

    public KafkaViolationConsumer(final ViolationProcessor violationProcessor) {
        this.violationProcessor = violationProcessor;
    }
	
	@KafkaListener(topics = "test", groupId = "test", containerFactory = "kafkaListenerContainerFactory")
    public void listen(SpeedingViolation violation) {
        violationProcessor.processSpeedingViolation(violation);
    }
	

}
