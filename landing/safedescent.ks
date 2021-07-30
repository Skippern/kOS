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
    PRINT "Throttle:     " + ROUND(MyThrottle * 100, 1) + "%     " AT(0,1).
    IF SAS { SET SASStatus TO " ON/". } ELSE { SET SASStatus TO "OFF/". }
    PRINT "SASMODE:      " + SASStatus + SASMODE + "            " AT(0,2).
}
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".

PRINT "".
PRINT "Preparing Safe Descent".

LOCK THROTTLE TO 0.

WAIT 1.
Telemetry().

//SAS ON.
WAIT 1.
Telemetry().
SET SASMODE TO "RETROGRADE".
SET MySteer TO SHIP:RETROGRADE.
LOCK STEERING TO MySteer.
WAIT 1.
Telemetry().

WAIT 20.

SET MyStatus TO "Ready to take down Periapsis".
PRINT "Aligned in RETROGRADE".

// Prepare a slow burn to dip Periapsis under athmosphere limit
UNTIL SHIP:periapsis < BODY:ATM:height * 0.95 {
    // Break near Apoapsis
    SET SASMODE TO "RETROGRADE".
    SET MySteer TO SHIP:RETROGRADE.
    IF ETA:apoapsis < 30 {
        SET MyStatus TO "Preparing athmospheric DIP". 
        SET MyThrottle TO 0.1.
    } ELSE {
        SET MyThrottle TO 0.
    }
    LOCK THROTTLE TO MyThrottle.
    LOCK STEERING TO MySteer.
    Telemetry().
    WAIT 0.1.
}
LOCK THROTTLE TO 0.

PRINT "Periapsis inside atmosphere".

// Get Apopasis down
UNTIL SHIP:periapsis < BODY:ATM:height * 0.75 OR SHIP:apoapsis < BODY:ATM:height {
    SET MyStatus TO "Flattening Orbit".
    SET MySteer TO SHIP:RETROGRADE.
    SET SASMODE TO "RETROGRADE".
    IF SHIP:altitude < BODY:ATM:height {
        SET MyThrottle TO 0.05.
    } else {
        SET MyThrottle TO 0.
    }
    LOCK THROTTLE TO MyThrottle.
    LOCK STEERING TO MySteer.
    Telemetry().
    WAIT 0.1.
}
PRINT"Apoapsis inside atmsophere".

SET MyStatus TO "Final Breakdown".
Telemetry().
// If any fuel remaining do hard break
UNTIL (SHIP:LIQUIDFUEL < 5 AND SHIP:SOLIDFUEL < 5) {
    SET SASMODE TO "RETROGRADE".
    SET MySteer TO SHIP:RETROGRADE.
    LOCK STEERING TO MySteer.
    LOCK THROTTLE TO 1.
    Telemetry().
    WAIT 1.
}
PRINT "No more fuel, gravity take care of the rest".
LOCK THROTTLE TO 0.
WAIT 10.

SET MyStatus TO "Staging Out".
UNLOCK THROTTLE.
STAGE.
// Complete all staging

SET MyStatus TO "Brace for Touchdown".
SET RELEASED TO False.

// Launch Drugeshutes
PRINT "Preparing Launch of Parachutes".
WHEN (NOT CHUTESSAFE) THEN {
    PRINT "Parachute activated at " + ROUND(SHIP:altitude,0) +"m".
    CHUTESSAFE ON.
    SAS OFF.
    SET RELEASED TO True.
    WAIT 1.
    UNLOCK STEERING.
    RETURN (NOT CHUTES).
}
Telemetry().

// Make sure program doesn't end until parachutes are deployed
UNTIL SHIP:altitude < 1000 {
    Telemetry().
    IF NOT RELEASED {
        SET MySteer TO SHIP:RETROGRADE.
        LOCK STEERING TO MySteer.
    }
    WAIT 0.1.
}
PRINT "This step completed at " + ROUND(SHIP:altitude,0) +"m".

SAS OFF.
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
UNLOCK STEERING.
UNLOCK THROTTLE.

Telemetry().

PRINT "YOU ARE ON YOUR OWN NOW!!!!".
