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
global universalGasConstant TO 8.314. //  J/mol K
global adiabaticConstant TO 1.4. // Constant

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
DECLARE FUNCTION printMissionTime {
    RETURN printTime(missionTime).
}

// Maneuver
// For setSteering to work, variables MySteering with a vector, and MyThrottle with a scalar between 1 and 0 is needed.
DECLARE GLOBAL MyThrottle TO 0.
// DECLARE GLOBAL MySteer TO R(0,0,0).
DECLARE GLOBAL MySteer TO SHIP:FACING.
DECLARE FUNCTION setSteering {
    IF SAS {
        UNLOCK STEERING.
    } ELSE {
        LOCK STEERING TO MySteer.
    }
    LOCK THROTTLE TO MyThrottle.
}
DECLARE FUNCTION setFacing {
    IF SAS {
        SET SASMODE TO "STABILITYASSIST".
    } ELSE {
        SET MySteer TO SHIP:FACING.
    }
}
DECLARE FUNCTION setPrograde {
    IF SAS AND True { // Check if Prograde is available
        SET SASMODE TO "PROGRADE".
    } ELSE {
        SAS OFF.
    }
    SET MySteer TO SHIP:PROGRADE.
}
DECLARE FUNCTION setRetrograde {
    IF SAS AND True { // Check if Retrograde is available
        SET SASMODE TO "RETROGRADE".
    } ELSE {
        SAS OFF.
    }
    SET MySteer TO SHIP:RETROGRADE.
}
DECLARE FUNCTION setNormal {
    IF SAS AND True { // Check if Normal is available
        SET SASMODE TO "NORMAL".
    } ELSE {
        SAS OFF.
    }
    SET MySteer TO VCRS(SHIP:BODY:POSITION,SHIP:VELOCITY:ORBIT).
//    SET MySteer TO SHIP:NORMAL.
}
DECLARE FUNCTION setAntiNormal {
    IF SAS AND True { // Check if Antinormal is available
        SET SASMODE TO "Antinormal".
    } ELSE {
        SAS OFF.
    }
    SET MySteer TO VCRS(SHIP:BODY:POSITION,SHIP:VELOCITY:ORBIT):INVERSE.
//    SET MySteer TO SHIP:ANTINORMAL.
}
DECLARE FUNCTION setRadialIn {
    IF SAS AND True { // Check if Radial In is available
        SET SASMODE TO "RADIALIN".
    } ELSE {
        SAS OFF.
    }
    SET MySteer TO SHIP:DOWN.
//    SET MySteer TO SHIP:RADIALIN.
}
DECLARE FUNCTION setRadialOut {
    IF SAS AND True { // Check if Radial Out is available
        SET SASMODE TO "RADIALOUT".
    } ELSE {
        SAS OFF.
    }
    SET MySteer TO SHIP:UP.
//    SET MySteer TO SHIP:RADIALOUT.
}
DECLARE FUNCTION setTarget {
    IF True { // Check if Target is available
        SET SASMODE TO "TARGET".
    } ELSE {
        SAS OFF.
    }
//    SET MySteer TO SHIP:TARGET.
}
DECLARE FUNCTION setAntiTarget {
    IF True { // Check if AntiTarget is available
        SET SASMODE TO "ANTITARGET".
    } ELSE {
        SAS OFF.
    }
//    SET MySteer TO SHIP:ANTITARGET.
}
DECLARE FUNCTION setManeuver {
    IF SAS AND True { // Check if Maneuver is available
        SET SASMODE TO "MANEUVER".
    } ELSE {
        SAS OFF.
    }
    IF NEXTNODE {
        SET MySteer TO NEXTNODE:deltav.
    }
//    SET MySteer TO SHIP:MANEUVER.
}
DECLARE FUNCTION setStability {
    IF SAS {
        SET SASMODE TO "STABILITY".
    } ELSE {
        SET MySteer TO SHIP:FACING. // Same as STABILITYASSIST
    }
}
DECLARE FUNCTION resetSteering {
    SAS OFF.
    LOCK THROTTLE TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    UNLOCK STEERING.
    UNLOCK THROTTLE.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
}