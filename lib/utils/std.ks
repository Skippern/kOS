// lib/utils/std.ks
//
// A collection of functions to make life easier

// Physics
DECLARE FUNCTION getLocalG {
    RETURN SHIP:BODY:mu / SHIP:BODY:POSITION:MAG ^ 2.
}
DECLARE FUNCTION getTWR {
    IF SHIP:availablethrust = 0 { RETURN 0. }

    RETURN  SHIP:AVAILABLETHRUST / (SHIP:MASS * getLocalG() ).
}

// Layout
DECLARE FUNCTION printTime {
    PARAMETER myTime.
    PARAMETER Precission IS 1.

    SET fract TO ROUND( ROUND(myTime,Precission) - FLOOR(myTime) , Precission).
    SET myTime TO TIMESTAMP(myTime).

    RETURN (myTime:year - 1) + "y " + (myTime:day - 1) + "d " + myTime:hour + "h " + myTime:minute + "m " + (myTime:second + fract) + "s". 
}

// Maneuver
// For setSteering to work, variables MySteering with a vector, and MyThrottle with a scalar between 1 and 0 is needed.
DECLARE GLOBAL MyThrottle TO 0.
DECLARE GLOBAL MySteer TO R(0,0,0).
DECLARE FUNCTION setSteering {
    IF SAS {
        UNLOCK STEERING.
    } ELSE {
        LOCK STEERING TO MySteer.
    }
    LOCK THROTTLE TO MyThrottle.
}
DECLARE FUNCTION setFacing {
    SET SASMODE TO "STABILITYASSIST".
    SET MySteer TO SHIP:FACING.
}
DECLARE FUNCTION setPrograde {
    SET SASMODE TO "PROGRADE".
    SET MySteer TO SHIP:PROGRADE.
}
DECLARE FUNCTION setRetrograde {
    SET SASMODE TO "RETROGRADE".
    SET MySteer TO SHIP:RETROGRADE.
}
    // } ELSE IF SASMODE = "NORMAL" {
    // } ELSE IF SASMODE = "ANTINORMAL" {
    // } ELSE IF SASMODE = "RADIALIN" {
    // } ELSE IF SASMODE = "RADIALOUT" {
    // } ELSE IF SASMODE = "TARGET" {
    // } ELSE IF SASMODE = "ANTITARGET" {
    // } ELSE IF SASMODE = "MANEUVER" {
    // } ELSE IF SASMODE = "STABILITY" {
DECLARE FUNCTION setNormal {
    SET SASMODE TO "NORMAL".
//    SET MySteer TO SHIP:NORMAL.
}
DECLARE FUNCTION setAntiNormal {
    SET SASMODE TO "ANTINORMAL".
//    SET MySteer TO SHIP:ANTINORMAL.
}
DECLARE FUNCTION setRadialIn {
    SET SASMODE TO "RADOAØOM".
//    SET MySteer TO SHIP:RADIALIN.
}
DECLARE FUNCTION setRadialOut {
    SET SASMODE TO "RADIALOUT".
//    SET MySteer TO SHIP:RADIALOUT.
}
DECLARE FUNCTION setTarget {
    SET SASMODE TO "TARGET".
//    SET MySteer TO SHIP:TARGET.
}
DECLARE FUNCTION setAntiTarget {
    SET SASMODE TO "ANTITARGET".
//    SET MySteer TO SHIP:ANTITARGET.
}
DECLARE FUNCTION setManeuver {
    SET SASMODE TO "MANEUVER".
//    SET MySteer TO SHIP:MANEUVER.
}
DECLARE FUNCTION setStability {
    SET SASMODE TO "STABILITY".
//    SET MySteer TO SHIP:FACING. // ?
}
DECLARE FUNCTION resetSteering {
    SAS OFF.
    LOCK THROTTLE TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    UNLOCK STEERING.
    UNLOCK THROTTLE.
}