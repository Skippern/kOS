CLEARSCREEN.

PRINT "Pitching not set" .
PRINT ROUND(SHIP:APOAPSIS,0) .
PRINT ROUND(SHIP:PERIAPSIS,0) .


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

    SET val TO i + 90.
    IF val > 360 {
        RETURN val - 360.
    }
    RETURN val.
}.


SET INC TO FLOOR(360*RANDOM()).
// SET INC TO 131. // Desired inclination
//SET APO to 56377040. // Desired Apopasis
//SET PERI to 39049260. // Desired Periapsis
SET AZI TO CalcAzi(INC). // Launch azimut, will impact the inclination of the orbit
SET UPSTEP TO 10.
SET DOWNSTEP TO 5.

PRINT "Inclination set to " + INC + " / Heading set to " + AZI.

SET PITCH TO 90.

SET MYSTEER TO HEADING(AZI,PITCH).
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:APOAPSIS > 100000 { //Remember, all altitudes will be in meters, not kilometers

    //For the initial ascent, we want our steering to be straight
    //up and rolled due east
    IF SHIP:VELOCITY:SURFACE:MAG < 100 {
        SET MYSTEER TO HEADING(AZI,PITCH).
    //Once we pass 100m/s, we want to pitch down ten degrees
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 AND SHIP:VELOCITY:SURFACE:MAG < 500 {
        SET PITCH TO 90 - UPSTEP.
        SET MYSTEER TO HEADING(AZI,PITCH).
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 500 AND SHIP:VELOCITY:SURFACE:MAG < 700 {
        SET PITCH TO 90 - (2 * UPSTEP).
        SET MYSTEER TO HEADING(AZI,PITCH).
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 700 AND SHIP:VELOCITY:SURFACE:MAG < 900 {
        SET PITCH TO 90 - (3 * UPSTEP).
        SET MYSTEER TO HEADING(AZI,PITCH).
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 900 AND SHIP:VELOCITY:SURFACE:MAG < 1100 {
        SET PITCH TO 90 - (4 * UPSTEP).
        SET MYSTEER TO HEADING(AZI,PITCH).
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1100 AND SHIP:VELOCITY:SURFACE:MAG < 1300 {
        SET PITCH TO 90 - (5 * UPSTEP).
        SET MYSTEER TO HEADING(AZI,PITCH).
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1300 AND SHIP:VELOCITY:SURFACE:MAG < 1500 {
        SET PITCH TO 90 - (6 * UPSTEP).
        SET MYSTEER TO HEADING(AZI,PITCH).
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1500 AND SHIP:VELOCITY:SURFACE:MAG < 1700 {
        SET PITCH TO 90 - (7 * UPSTEP).
        SET MYSTEER TO HEADING(AZI,PITCH).
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1700 {
        SET PITCH TO 90 - (8 * UPSTEP).
        SET MYSTEER TO HEADING(AZI,PITCH).
    }.
    PRINT "Pitching to "+PITCH+" degrees   " AT(0,0).
    PRINT "Ap:" + ROUND(SHIP:APOAPSIS,0) + "   " AT(0,1).
    PRINT "Pe:" + ROUND(SHIP:PERIAPSIS,0) + "   " AT(0,2).
    WAIT 0.1.
}.

PRINT "100km apoapsis reached, preparing to lift periapsis out of atmosphere.".

UNTIL SHIP:PERIAPSIS > 70001 { // Get us in orbit!
    IF SHIP:altitude < 70000 {
        SET PITCH TO 0.
        LOCK THROTTLE TO 1.
    } ELSE IF SHIP:altitude >= 70000 AND SHIP:altitude < 80000 {
        SET PITCH TO 0 - DOWNSTEP.
        LOCK THROTTLE TO 0.9.
    } ELSE IF SHIP:altitude >= 80000 AND SHIP:altitude < 90000 {
        SET PITCH TO 0 - (2 * DOWNSTEP).
        LOCK THROTTLE TO 0.8.
    } ELSE IF SHIP:altitude >= 90000 AND SHIP:altitude < 100000 {
        SET PITCH TO 0 - (3 * DOWNSTEP).
        LOCK THROTTLE TO 0.7.
    } ELSE IF SHIP:altitude >= 100000 AND SHIP:altitude < 110000 {
        SET PITCH TO 0 - (4 * DOWNSTEP).
        LOCK THROTTLE TO 0.6.
    } ELSE IF SHIP:altitude >= 110000 AND SHIP:altitude < 120000 {
        SET PITCH TO 0 - (5 * DOWNSTEP).
        LOCK THROTTLE TO 0.5.
    } ELSE IF SHIP:altitude >= 120000 AND SHIP:altitude < 130000 {
        SET PITCH TO 0 - (6 * DOWNSTEP).
        LOCK THROTTLE TO 0.4.
    } ELSE IF SHIP:altitude >= 130000 AND SHIP:altitude < 140000 {
        SET PITCH TO 0 - (7 * DOWNSTEP).
        LOCK THROTTLE TO 0.3.
    } ELSE IF SHIP:altitude >= 140000 AND SHIP:altitude < 150000 {
        SET PITCH TO 0 - (8 * DOWNSTEP).
        LOCK THROTTLE TO 0.2.
    } ELSE IF SHIP:altitude >= 150000 AND SHIP:altitude < 160000 {
        SET PITCH TO 0.
        LOCK THROTTLE TO 0.1.
    }.
    SET MYSTEER TO HEADING(AZI,PITCH).
    PRINT "Pitching to "+PITCH+" degrees   " AT(0,0).
    PRINT "Ap:" + ROUND(SHIP:APOAPSIS,0) + "   " AT(0,1).
    PRINT "Pe:" + ROUND(SHIP:PERIAPSIS,0) + "   " AT(0,2).
    WAIT 0.1.
}.
PRINT "We have achieved Orbit, lets get down".

UNLOCK STEERING.
SAS ON.
WAIT 1.

LOCK THROTTLE TO 0.
SET SASMODE TO "RETROGRADE".

WAIT 30. // Give us time to turn before retrograde burns

UNTIL SHIP:PERIAPSIS < 69500 {
    SET SASMODE TO "RETROGRADE".
    LOCK THROTTLE TO 0.1.
    WAIT 0.1.
}
PRINT "Decaying orbit, lets get apopapsis down".

UNTIL SHIP:APOAPSIS < 69999 {
    IF SHIP:altitude > 80000 {
        WAIT 10.
    }
    IF SHIP:ALTITUDE > 70000 {
        LOCK THROTTLE TO 0.
        WAIT 1.
    } ELSE  IF ETA:periapsis < 3 {
        SET SASMODE TO "RETROGRADE".
        LOCK THROTTLE TO 1.
    } ELSE {
        SET SASMODE TO "RETROGRADE".
        LOCK THROTTLE TO 0.1.
    }
    WAIT 0.1.
}
PRINT "We have decaying orbit inside atmosphere.".

// Stage all decouplers on safe altitude

// deploy droge chutes on safe speed

// deploy all chutes on remaining altitude for safe landing speed


SAS OFF.
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.