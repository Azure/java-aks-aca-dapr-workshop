package dapr.fines.violation;

import dapr.traffic.violation.SpeedingViolation;

public interface ViolationProcessor {
  void processSpeedingViolation(final SpeedingViolation violation);
}
