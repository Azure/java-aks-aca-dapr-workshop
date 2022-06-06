package dapr.fines.violation;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import com.fasterxml.jackson.databind.JsonNode;
import java.time.LocalDateTime;
import org.springframework.web.bind.annotation.GetMapping;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import dapr.traffic.violation.SpeedingViolation;

import io.dapr.Topic;
import io.dapr.client.domain.CloudEvent;

//@RestController
public class ViolationController {
    private final ViolationProcessor violationProcessor;

    public ViolationController(final ViolationProcessor violationProcessor) {
        this.violationProcessor = violationProcessor;
    }
    

//    @PostMapping(path = "/collectfine")
//    @Topic(name = "test", pubsubName = "pubsub")
//    public ResponseEntity<Void> registerViolation(@RequestBody final CloudEvent<SpeedingViolation> event) {
//    	var violation = event.getData();
//    	violationProcessor.processSpeedingViolation(violation);
//        return ResponseEntity.ok().build();
//    }
    
    
}
