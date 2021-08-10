// lib/utils/std.ks
//
// A collection of functions to make life easier


// Global variables

SET hasTermometer TO False.
SET hasBarometer TO False.
SET hasAccelerometer TO False.
SET hasGravometer TO FALSE.
LIST SENSORS IN SENSELIST.
FOR S IN SENSELIST {
    IF S:TYPE = "TEMP" {
        SET hasTermometer TO True.
    }
    IF S:TYPE = "PRES" {
        SET hasBarometer TO True.
    }
    IF S:TYPE = "ACC" {
        SET hasAccelerometer TO True.
    }
    IF S:TYPE = "GRAV" {
        SET hasGravometer TO True.
    }
}

// Physics
global MyACC IS V(0,0,0).
global myLastVel is SHIP:VELOCITY:ORBIT.
global myLastTime is TIME:SECONDS.
global kerbinSurfaceG IS 9.80718.

DECLARE FUNCTION getLocalG {
    RETURN SHIP:BODY:mu / SHIP:BODY:POSITION:MAG ^ 2.
}
DECLARE FUNCTION getTWR {
    IF SHIP:availablethrust = 0 { RETURN 0. }

    RETURN  SHIP:AVAILABLETHRUST / (SHIP:MASS * getLocalG() ).
}
DECLARE FUNCTION getCalculatedAccelleration {
    local dt IS TIME:SECONDS - myLastTime.
    if dt > 0 {
        SET MyACC TO (ship:velocity:orbit - myLastVel) / dt.
    }
    SET myLastVel TO SHIP:VELOCITY:ORBIT.
    SET myLastTime TO TIME:SECONDS.

    RETURN MyACC.
}
DECLARE FUNCTION getSoundSpeed { // Retrns the speed of sound c in current athmosphere assuming the gas behaves like air.
    IF NOT hasTermometer RETURN False.
    IF NOT hasBarometer RETURN False.
    SET universalGasConstant TO 8.314. //  J/mol K
    SET adiabaticConstant TO 1.4. // Constant
    SET airMolMass TO SHIP:SENSORS:PRES / ( universalGasConstant * SHIP:SENSORS:TEMP ). // kg/mol
    IF SHIP:SENSORS:TEMP > 0 AND SHIP:SENSORS:PRES > 0 {
        SET soundSpeed TO SQRT( ( adiabaticConstant * universalGasConstant ) / airMolMass ) * SQRT(SHIP:SENSORS:TEMP).
        RETURN soundSpeed.
    } ELSE RETURN False.
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