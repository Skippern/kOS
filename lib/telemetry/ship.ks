RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/science/orbitals".
RUN ONCE "0:lib/science/auto".
RUN ONCE "0:lib/comms".

DECLARE FUNCTION telemetryShip {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    PRINT SHIP:TYPE + ": " + SHIPNAME + "                           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF SHIP:STATUS = "ORBITING" {
        PRINT "In Orbit around " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "LANDED" {
        PRINT "Landed on " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "SPLASHED" {
        PRINT "Splashed in " + SHIP:BODY:NAME + "'s Oceans                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "PRELAUNCH" {
        PRINT "Pre-Launche preparations at " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "FLYING" {
        PRINT "Flying over " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "SUB_ORBITAL" {
        PRINT "In Sub-Orbital flight over " + SHIP:BODY:NAME  + "                   "AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "ESCAPING" {
        PRINT "Escaping " + SHIP:BODY:NAME + "'s SOI                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "DOCKED" {
        PRINT "Docked in orbit over " + SHIP:BODY:NAME + "                   " AT(0,LINENUM). // Get target name for dock.
    }

    SET LINENUM TO LINENUM + 1.
    IF (hasConnection()) {
        PRINT "Connected to " + connectedTo() + " with signal delay of " + ROUND(getKSCDelay(),5) + "s                     " AT(0,LINENUM).
    } ELSE {
        PRINT "NO RADIO CONNECTION!!!                                                                          " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    PRINT "Mission Time: " + printMissionTime() + "          " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "KSC Time: " + TIME:calendar + " at " + TIME:clock + "         " AT(0,LINENUM).
}
