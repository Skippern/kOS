CLEARSCREEN.

RUN ONCE "0:lib/telemetry/ship".
// RUN ONCE "0:lib/telemetry/comms".
RUN ONCE "0:lib/telemetry/attitude".
RUN ONCE "0:lib/telemetry/orbitNav".
RUN ONCE "0:lib/telemetry/sensors".
RUN ONCE "0:lib/telemetry/resources".
// RUN ONCE "0:lib/telemetry/athmosphericNav".
// RUN ONCE "0:lib/telemetry/surfaceNav".

UNTIL false {
    telemetryShip(0).
    telemetryAttitude(6).
    telemetrySensors(16).
    telemetryOrbit(22).
    telemetryResources(38).

    WAIT 0.05.
}
