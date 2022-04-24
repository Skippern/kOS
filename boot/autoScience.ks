// boot/autoteelemetryOrbiter
//
// Bootfile for telemetry CPU in orbital crafts.
SWITCH TO 0.
RUN "0:boot/boot".
SWITCH TO 1.
// CORE is this CPU.
// SET CORE:VOLUME:NAME TO "Telemetry".
// SET TargetFileSize TO OPEN("0:/telemetry/orbit"):SIZE.
// IF TargetFileSize < CORE:VOLUME:FREESPACE {
//     copyPath("0:/telemetry/orbit", "1:/telemetry").
//     RUN "1:telemetry".
// } ELSE {
//     RUN "0:telemetry/orbit".
// }

RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/science/auto".
RUN ONCE "0:lib/science/orbitals".

UNTIL False {
    // autoRunScience().
    print "GATHERING SCIENCE".
    getScience().
    WAIT 5.
    print "TRANSMITING SCIENCE LAB DATA".
    transmitScienceLab().
    WAIT 5.
    print "TRANSFERING DATA TO SCIENCE LAB".
    transferScienceToLab().
    WAIT 5.
    print "TRANSMITTING DATA TO KERBIN".
    transmitScience().
    WAIT 5.
    print "Mission Time: " + printMissionTime().
    IF SCIENCE_INTERVAL:HASKEY(BODY:NAME) {
        print "ENTER SLEEP MODE ("+ SCIENCE_INTERVAL[BODY:NAME] +"s)".
        WAIT SCIENCE_INTERVAL[BODY:NAME].
    } ELSE {
        print "ENTER SLEEP MODE (2000s)".
        WAIT 2000.
    }
}

