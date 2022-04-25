// boot/autoteelemetryOrbiter
//
// Bootfile for telemetry CPU in orbital crafts.
SWITCH TO 0.
RUN "0:boot/boot".
SWITCH TO 1.

RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/science/auto".
RUN ONCE "0:lib/science/orbitals".

RUN ONCE "0:telemetry/science".

