CLEARSCREEN.

PRINT "Pitching not set" AT(0,0). 
PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).


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


// SET INC TO 131. // Desired inclination
SET INC TO FLOOR(360*RANDOM()).
SET APO to 56377040. // Desired Apopasis
SET PERI to 39049260. // Desired Periapsis
SET AZI TO CalcAzi(INC). // Launch azimut, will impact the inclination of the orbit

PRINT "Inclination set to " + INC.

SET PITCH TO 90.

SET MYSTEER TO HEADING(AZI,90).
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:APOAPSIS > 100000 { //Remember, all altitudes will be in meters, not kilometers

    //For the initial ascent, we want our steering to be straight
    //up and rolled due east
    IF SHIP:VELOCITY:SURFACE:MAG < 100 {
        //This sets our steering 90 degrees up and yawed to the compass
        //heading of 90 degrees (east)
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    //Once we pass 100m/s, we want to pitch down ten degrees
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 AND SHIP:VELOCITY:SURFACE:MAG < 500 {
        SET PITCH TO 80.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 500 AND SHIP:VELOCITY:SURFACE:MAG < 700 {
        SET PITCH TO 70.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 700 AND SHIP:VELOCITY:SURFACE:MAG < 900 {
        SET PITCH TO 60.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 900 AND SHIP:VELOCITY:SURFACE:MAG < 1100 {
        SET PITCH TO 50.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1100 AND SHIP:VELOCITY:SURFACE:MAG < 1300 {
        SET PITCH TO 40.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1300 AND SHIP:VELOCITY:SURFACE:MAG < 1500 {
        SET PITCH TO 30.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1500 AND SHIP:VELOCITY:SURFACE:MAG < 1700 {
        SET PITCH TO 20.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1700 {
        SET PITCH TO 10.
        SET MYSTEER TO HEADING(AZI,PITCH).
        PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
        PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
        PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).

    }.

}.

PRINT "100km apoapsis reached, reducing throttle".

//UNLOCK STEERING.
//SAS ON.
//WAIT 1.
//SET SASMODE TO "PROGRADE".


UNTIL SHIP:PERIAPSIS > 70001 { // Get us in orbit!
    IF SHIP:altitude < 70000 {
        SET PITCH TO 0.
        LOCK THROTTLE TO 1.
    } ELSE IF SHIP:altitude >= 70000 AND SHIP:altitude < 80000 {
        SET PITCH TO -3.
        LOCK THROTTLE TO 0.9.
    } ELSE IF SHIP:altitude >= 80000 AND SHIP:altitude < 90000 {
        SET PITCH TO -6.
        LOCK THROTTLE TO 0.8.
    } ELSE IF SHIP:altitude >= 90000 AND SHIP:altitude < 100000 {
        SET PITCH TO -9.
        LOCK THROTTLE TO 0.7.
    } ELSE IF SHIP:altitude >= 100000 AND SHIP:altitude < 110000 {
        SET PITCH TO -12.
        LOCK THROTTLE TO 0.6.
    } ELSE IF SHIP:altitude >= 110000 AND SHIP:altitude < 120000 {
        SET PITCH TO -15.
        LOCK THROTTLE TO 0.5.
    } ELSE IF SHIP:altitude >= 120000 AND SHIP:altitude < 130000 {
        SET PITCH TO -18.
        LOCK THROTTLE TO 0.4.
    } ELSE IF SHIP:altitude >= 130000 AND SHIP:altitude < 140000 {
        SET PITCH TO -21.
        LOCK THROTTLE TO 0.3.
    } ELSE IF SHIP:altitude >= 140000 AND SHIP:altitude < 150000 {
        SET PITCH TO -24.
        LOCK THROTTLE TO 0.2.
    } ELSE IF SHIP:altitude >= 150000 AND SHIP:altitude < 160000 {
        SET PITCH TO 0.
        LOCK THROTTLE TO 0.1.
    }.
    SET MYSTEER TO HEADING(AZI,PITCH).
    PRINT "Pitching to "+PITCH+" degrees" AT(0,0).
    PRINT ROUND(SHIP:APOAPSIS,0) AT(0,1).
    PRINT ROUND(SHIP:PERIAPSIS,0) AT(0,2).
    WAIT 0.1.
}.


UNLOCK STEERING.
SAS ON.
WAIT 1.

LOCK THROTTLE TO 0.
SET SASMODE TO "RETROGRADE".

PRINT "We have achieved Orbit, lets get down".

WAIT 30.

UNTIL SHIP:PERIAPSIS < 69500 {
    SET SASMODE TO "RETROGRADE".
    LOCK THROTTLE TO 0.1.
    WAIT 0.1.
}

UNTIL SHIP:APOAPSIS < 69999 {
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


SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.