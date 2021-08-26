// orbit/gravityturn.ks
//
// Launch with a controlled gravity turn into orbit (100km Ap)
//
// At end of this, even though Periapsis might still be under horizon, 
// maneuvernodes.ks can activate from here, and controlled start planned maneuvers
WAIT 1.
CLEARSCREEN.

RUN ONCE "0:/lib/utils/std".

WAIT 1.
SET MyStatus TO "Preparing Safe Descent".
SET MyThrottle TO 0.
//UNSET TARGET. This does not work
SET TARGET TO SHIP:BODY. // apparently this works, dunno why

PRINT "".
PRINT "Preparing Safe Descent".

setSteering().

WAIT 1.

WAIT 1.
setRetrograde().
setSteering().
WAIT 1.

WAIT 20.

SET MyStatus TO "Ready to take down Periapsis".
PRINT "Aligned in RETROGRADE".

// Prepare a slow burn to dip Periapsis under athmosphere limit
UNTIL SHIP:periapsis < BODY:ATM:height * 0.90 {
    // Break near Apoapsis
    setRetrograde().
    IF ETA:apoapsis < 30 OR (SHIP:ORBIT:PERIOD - ETA:apoapsis) < 30 {
        SET MyStatus TO "Preparing athmospheric DIP". 
        SET MyThrottle TO 0.05.
        IF SHIP:periapsis > 100000 { SET MyThrottle TO 1. }
    } ELSE IF SHIP:ALTITUDE < BODY:ATM:HEIGHT {
        SET MyThrottle TO 0.05.
    } ELSE {
        SET MyThrottle TO 0.
    }
    LOCK THROTTLE TO MyThrottle.
    setSteering().
    WAIT 0.1.
}
LOCK THROTTLE TO 0.

PRINT "Periapsis inside atmosphere".
PANELS OFF. // Foldable solar panels should be stowed

// Get Apopasis down
UNTIL SHIP:periapsis < (BODY:ATM:height * 0.70) OR SHIP:apoapsis < BODY:ATM:height {
    SET MyStatus TO "Flattening Orbit".
    setRetrograde().
    setSteering().
    IF SHIP:altitude < BODY:ATM:height {
        IF ETA:periapsis < 30 OR (SHIP:ORBIT:PERIOD - ETA:periapsis) < 30 {
            SET MyThrottle TO ROUND( MAX( (( 110 - ( MIN(ETA:periapsis, SHIP:ORBIT:PERIOD - ETA:periapsis) * 12)) / 100), 0), 4).
            SET MyThrottle TO MIN(MAX(MyThrottle, 0.05), 1).
        } ELSE {
            SET MyThrottle TO 0.001.
        }
    } else {
        SET MyThrottle TO 0.
    }
    WAIT 0.1.
}
IF SHIP:apoapsis < BODY:ATM:HEIGHT {
    PRINT "Apoapsis inside atmsophere".
} ELSE {
    PRINT "PERIAPSIS VERY LOW".
}

SET MyStatus TO "Final Breakdown".
// If any fuel remaining do hard break
UNTIL (SHIP:LIQUIDFUEL < 5 AND SHIP:SOLIDFUEL < 5) {
    setRetrograde().
    setSteering().
    SET MyThrottle TO 1.
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
BAYS OFF.
LEGS OFF.
GEAR OFF.
PANELS OFF.
// Launch Drugeshutes
PRINT "Preparing Launch of Parachutes".
WHEN (NOT CHUTESSAFE) THEN {
    PRINT "Parachute activated at " + ROUND(SHIP:altitude,0) +"m / " + ROUND(SHIP:AIRSPEED,1) + "m/s".
    CHUTESSAFE ON.
    SAS OFF.
    SET RELEASED TO True.
    WAIT 1.
    UNLOCK STEERING.
    RETURN (NOT CHUTES).
}

// Make sure program doesn't end until parachutes are deployed
UNTIL SHIP:airspeed < 150 {
    IF NOT RELEASED {
        setRetrograde().
        setSteering().
    }
    WAIT 0.1.
}
PRINT "This step completed at " + ROUND(SHIP:altitude,0) +"m".

resetSteering().
PRINT "YOU ARE ON YOUR OWN NOW!!!!".
