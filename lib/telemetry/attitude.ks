CLEARSCREEN.

RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/science/orbitals".
RUN ONCE "0:lib/science/auto".
RUN ONCE "0:lib/comms".

DECLARE FUNCTION telemetryAttitude {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    PRINT "Yaw: " + ROUND(VectorAngle(SHIP:UP:TOPVECTOR,SHIP:FACING:TOPVECTOR), 1) + "° / Pitch: " + ROUND(VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR), 1) + "° / Roll: " + ROUND(VectorAngle(SHIP:UP:STARVECTOR,SHIP:FACING:STARVECTOR), 1) + "°                    " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF (RCS) { SET tmp TO "ON / ". } ELSE { SET tmp TO "OFF/ ". }
    PRINT "RCS: " + tmp + "                      " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF (SAS) { SET tmp TO "ON / ". } ELSE { SET tmp TO "OFF/ ". }
    PRINT "SAS: " + tmp + SASMODE + "           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Throttle: " + ROUND(THROTTLE * 100, 1) + "%            " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Local G: " + ROUND(getLocalG(), 4) + "m/s²                 " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Available Thrust: " + ROUND(SHIP:availablethrust,1) + "kN             " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Ship Mass: " + ROUND(SHIP:MASS, 2) + "Te                 " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "TWR: " + ROUND(getTWR(),2) + "               " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "deltaV: " + ROUND(SHIP:DELTAV:CURRENT,1) + "m/s               " AT(0,LINENUM).
}
