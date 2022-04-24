clearScreen.

WAIT 1.

RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/science/auto".
RUN ONCE "0:lib/science/orbitals".
RUN ONCE "0:lib/telemetry/science".

SET TimeToTransmit TO (TIME).
SET OrbitingBody TO BODY:NAME.

WAIT 4.

print " ".
print " ".
print " ".
print " ".
print " ".
print " ".
print " ".

UNTIL False {
    telemetryScience().
    IF NOT (OrbitingBody = BODY:NAME) {
        SET TimeToTransmit TO (TIME - 1).
        SET OrbitingBody TO BODY:NAME.
    }
    IF TIME > TimeToTransmit {
        IF SCIENCE_INTERVAL:haskey(BODY:NAME) {
            SET TimeToTransmit TO (TIME + SCIENCE_INTERVAL[BODY:NAME]).
        }
        print "GATHERING SCIENCE".
        getScience().
        // WAIT 5.
        print "TRANSMITING SCIENCE LAB DATA".
        transmitScienceLab().
        // WAIT 5.
        // print "TRANSFERING DATA TO SCIENCE LAB".
        // transferScienceToLab().
        // WAIT 5.
        // print "TRANSMITTING DATA TO KERBIN".
        // transmitScience().
        // WAIT 5.
        print "Mission Time: " + printMissionTime().
    }
    WAIT 1.
}

