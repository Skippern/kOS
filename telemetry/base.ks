CLEARSCREEN.

RUN ONCE "0:lib/telemetry/ship".
RUN ONCE "0:lib/telemetry/comms".
RUN ONCE "0:lib/telemetry/sensors".
RUN ONCE "0:lib/telemetry/resources".
RUN ONCE "0:lib/telemetry/science".

UNTIL false {
    telemetryShip(0).
    telemetrySensors(16).
    telemetryScience().
    telemetryComms().
    telemetryResources(38).

    PRINT "" AT(0,55).
    WAIT 0.05.
}
