// boot/autoteelemetryOrbiter
//
// Bootfile for telemetry CPU in orbital crafts.
SWITCH TO 0.
//SET CORE:VOLUME:NAME TO "KSC".
RUN "0:boot/boot".

SWITCH TO 1.

// CORE is this CPU.
SET CORE:VOLUME:NAME TO "Telemetry".
SET TargetFileSize TO OPEN("0:/telemetry/orbit"):SIZE.
IF TargetFileSize < CORE:VOLUME:FREESPACE {
    copyPath("0:/telemetry/orbit", "1:/telemetry").
    RUN "1:telemetry".
} ELSE {
    RUN "0:telemetry/orbit".
}


