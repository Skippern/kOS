CLEARSCREEN.

LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

//This is our countdown loop, which cycles from 10 to 0
PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

//This is a trigger that constantly checks to see if our thrust is zero.
//If it is, it will attempt to stage and then return to where the script
//left off. The PRESERVE keyword keeps the trigger active even after it
//has been triggered.
WHEN MAXTHRUST = 0 THEN {
    PRINT "Staging".
    STAGE.
    PRESERVE.
}.


DECLARE FUNCTION CalcAzi {
    DECLARE parameter i.

    SET R TO i + 90.
    IF R > 360 {
        RETURN R - 360.
    }
    RETURN R.
}.


SET INC TO 131. // Desired inclination
SET APO to 56377040. // Desired Apopasis
SET PERI to 39049260. // Desired Periapsis
SET AZI TO CalcAzi(INC). // Launch azimut, will impact the inclination of the orbit

SET MYSTEER TO HEADING(AZI,90).
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:APOAPSIS > 100000 { //Remember, all altitudes will be in meters, not kilometers

    //For the initial ascent, we want our steering to be straight
    //up and rolled due east
    IF SHIP:VELOCITY:SURFACE:MAG < 100 {
        //This sets our steering 90 degrees up and yawed to the compass
        //heading of 90 degrees (east)
        SET MYSTEER TO HEADING(AZI,90).

    //Once we pass 100m/s, we want to pitch down ten degrees
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 AND SHIP:VELOCITY:SURFACE:MAG < 500 {
        SET MYSTEER TO HEADING(AZI,80).
        PRINT "Pitching to 80 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    //Each successive IF statement checks to see if our velocity
    //is within a 100m/s block and adjusts our heading down another
    //ten degrees if so
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 500 AND SHIP:VELOCITY:SURFACE:MAG < 700 {
        SET MYSTEER TO HEADING(AZI,70).
        PRINT "Pitching to 70 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 700 AND SHIP:VELOCITY:SURFACE:MAG < 800 {
        SET MYSTEER TO HEADING(AZI,60).
        PRINT "Pitching to 60 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 800 AND SHIP:VELOCITY:SURFACE:MAG < 900 {
        SET MYSTEER TO HEADING(AZI,50).
        PRINT "Pitching to 50 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 900 AND SHIP:VELOCITY:SURFACE:MAG < 1000 {
        SET MYSTEER TO HEADING(AZI,40).
        PRINT "Pitching to 40 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1000 AND SHIP:VELOCITY:SURFACE:MAG < 1100 {
        SET MYSTEER TO HEADING(AZI,30).
        PRINT "Pitching to 30 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1100 AND SHIP:VELOCITY:SURFACE:MAG < 1200 {
        SET MYSTEER TO HEADING(AZI,20).
        PRINT "Pitching to 20 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    //Beyond 800m/s, we can keep facing towards 10 degrees above the horizon and wait
    //for the main loop to recognize that our apoapsis is above 100km
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1200 {
        SET MYSTEER TO HEADING(AZI,10).
        PRINT "Pitching to 10 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,16).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,17).

    }.

}.

PRINT "100km apoapsis reached, reducing throttle".

UNTIL SHIP:PERIAPSIS > 70001 { // Get us in orbit!
    SET MYSTEER TO HEADING(AZI,0).
    LOCK THROTTLE TO 0.25.
}.

PRINT "We have achieved Orbit, lets get down".

SET SASMODE TO "RETROGRADE".

UNTIL SHIP:PERIAPSIS < 69500 {
    SET SASMODE TO "RETROGRADE".
    LOCK THROTTLE TO 0.1.
}

UNTIL SHIP:APOAPSIS < 69999 {
    IF SHIP:ALTITUDE > 70000 {
        LOCK THROTTLE TO 0.
    } ELSE {
        SET SASMODE TO "RETROGRADE".
        LOCK THROTTLE TO 0.1.
    }
}


SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.