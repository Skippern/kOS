// orbit/gravityturn.ks
//
// Launch with a controlled gravity turn into orbit (100km Ap)
//
// At end of this, even though Periapsis might still be under horizon, 
// maneuvernodes.ks can activate from here, and controlled start planned maneuvers
CLEARSCREEN.

SET MyStatus TO "Preparing Safe Descent".
SET MyThrottle TO 0.

DECLARE FUNCTION Telemetry {
    PRINT MyStatus + "                             " AT(0,0).
//    PRINT "TWR:          " + ROUND(getTWR(),2) + "      " AT(0,2).
    PRINT "Throttle:     " + ROUND(MyThrottle * 100, 1) + "%     " AT(0,3).
    IF SAS { SET SASStatus TO " ON/". } ELSE { SET SASStatus TO "OFF/". }
    PRINT "SASMODE:      " + SASStatus + SASMODE + "            " AT(0,4).
}
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".

PRINT "".
PRINT "Preparing Safe Descent".

WAIT 1.
Telemetry().

SAS ON.
SET SASMODE TO "RETROGRADE".
SET MYSTEER TO SHIP:RETROGRADE.
SET STEERING TO MySteer.

WAIT 30.

SET MyStatus TO "Ready to take down Periapsis".
PRINT "Aligned in RETROGRADE".

// Prepare a slow burn to dip Periapsis under athmosphere limit
UNTIL SHIP:periapsis < BODY:ATM:height {
    // Break near Apoapsis
    IF ETA:apoapsis < 30 {
        SET MyStatus TO "Preparing athmospheric DIP". 
        SET SASMODE TO "RETROGRADE".
        SET MYSTEER TO SHIP:RETROGRADE.
        SET MyThrottle TO 0.1.
    } ELSE {
        SET MyThrottle TO 0.
    }
    SET THROTTLE TO MyThrottle.
    SET STEERING TO MySteer.
    Telemetry().
    WAIT 0.1.
}
SET THROTTLE TO 0.

PRINT "Periapsis inside atmosphere".

// Get Apopasis down
UNTIL SHIP:periapsis < BODY:ATM:height * 0.75 OR SHIP:apoapsis < BODY:ATM:height {
    SET MyStatus TO "Flattening Orbit".
    IF SHIP:altitude < BODY:ATM:height {
        SET SASMODE TO "RETROGRADE".
        SET MYSTEER TO SHIP:RETROGRADE.
        SET MyThrottle TO 0.1.
    } else {
        SET MyThrottle TO 0.
    }
    SET THROTTLE TO MyThrottle.
    SET STEERING TO MySteer.
    Telemetry().
    WAIT 0.1.
}
SET MyStatus TO "Final Breakdown".
// If any fuel remaining do hard break


SET MyStatus TO "Staging Out".
// Complete all staging

SET MyStatus TO "Brace for Touchdown".

SAS OFF.
SET THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.

PRINT "YOU ARE ON YOUR OWN NOW!!!!".
