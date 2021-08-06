// orbit/gravityturn.ks
DECLARE PARAMETER AZIMUTH IS 90,
                    TILTED IS 80,
                    TARGET_APOAPSIS IS MAX(BODY:ATM:HEIGHT * 2, 50000),
                    CIRCULATE IS False,
                    TARGET_PERIAPSIS IS 0,
                    TOURIST IS False.
//
// Launch with a controlled gravity turn into orbit
//
// RUN "0:orbit/gravityturn" (90, 80, 140000, False, 77000)
// Where 90 is Azimuth from launchpad
// 80 is tilt to start gravitytyrb (90 is streight up)
// 140000 si desired Apoapsis in meters
// False for not circulating, True for circulating (this value will override Periapsis)
// 77000 is desired Periapsis in meters
// If last option TOURIST is set to True, script will abort as soon as orbit is achieved.
CLEARSCREEN.

SET DEBUG TO False.
SET PITCHUP TO 90.

SET SAFE_ALTITUDES TO lexicon(
    "Sun", SUN:ATM:HEIGHT, // Don't think we can survive to do a gravityturn from the Sun
        "Moho", 7500,
        "Eve", EVE:ATM:HEIGHT,
            "Gilly", 7500,
        "Kerbin", KERBIN:ATM:HEIGHT,
            "Mun", 7200,
            "Minmus", 6250,
        "Duna", DUNA:ATM:HEIGHT,
            "Ike", 13500,
        "Dres", 6500,
        "Jool", JOOL:ATM:HEIGHT,
            "Laythe", LAYTHE:ATM:HEIGHT,
            "Vall", 9000,
            "Tylo", 13500,
            "Bop", 23000,
            "Pol", 6000,
        "Eeloo", 4500
).
IF SAFE_ALTITUDES:HASKEY(BODY:NAME) {
    IF TARGET_APOAPSIS < (SAFE_ALTITUDES[BODY:NAME] * 1.1) {
        SET TARGET_APOAPSIS TO SAFE_ALTITUDES[BODY:NAME] * 1.1. 
    }
}
IF TARGET_APOAPSIS > SHIP:BODY:SOIRADIUS {
    SET TARGET_APOAPSIS TO SHIP:BODY:SOIRADIUS * 0.99.
}

IF CIRCULATE {
    SET SAFE_PERIAPSIS TO TARGET_APOAPSIS.
} ELSE IF TARGET_PERIAPSIS > 500 {
    SET SAFE_PERIAPSIS TO TARGET_PERIAPSIS.
} ELSE IF BODY:ATM:HEIGHT > 500 {
    SET SAFE_PERIAPSIS TO BODY:ATM:HEIGHT * 1.1.
} ELSE { // The following step only for bodies without atmosphere
    IF SAFE_ALTITUDES:HASKEY(BODY:NAME) {
        SET SAFE_PERIAPSIS TO SAFE_ALTITUDES[BODY:NAME].
    } ELSE {
        SET SAFE_PERIAPSIS TO 50000.
    }
    // Identify different bodies and determine safe altitude based on topography.
}
IF SAFE_PERIAPSIS < (BODY:ATM:HEIGHT * 1.01) { //Periapsis must be set 1% over atmosphere, if lower default to 10% over
    SET SAFE_PERIAPSIS TO BODY:ATM:HEIGHT * 1.1.
}
IF TARGET_APOAPSIS < SAFE_PERIAPSIS { SET TARGET_APOAPSIS TO SAFE_PERIAPSIS. }

// Hardcoded minimum tank level (in units) to be considered empty.
SET EMPTY TO 0.03.

SET MyStatus TO "Preparing Lanuche Sequence".
SET MyAcceleration TO 0.
SET MyThrottle TO 0.
SET forceSAS TO False.

IF DEBUG {
    DECLARE FUNCTION Telemetry {
        PRINT MyStatus + "                             " AT(0,0).
        IF SAS { SET SASStatus TO " ON/". } ELSE { SET SASStatus TO "OFF/". }
        PRINT "SASMODE:      " + SASStatus + SASMODE + "            " AT(0,1).
        PRINT "Acceleration: " + MyAcceleration + "         " AT(0,2).
        PRINT "TWR:          " + ROUND(getTWR(),2) + "      " AT(0,3).
        PRINT "Throttle:     " + ROUND(THROTTLE * 100, 1) + "%                                " AT(0,4).
    }
}


WAIT 0.1.
IF DEBUG { Telemetry(). }

WAIT 0.1.
PRINT "Gravity Turn Sequence is Initiated!".
PRINT "Departure Heading: " + AZIMUTH.
PRINT "Gravity Tilt:      " + TILTED.
PRINT "Target Apoapsis:   " + TARGET_APOAPSIS.
IF NOT CIRCULATE {
    PRINT "Target Periapsis:    " + SAFE_PERIAPSIS.
}
IF DEBUG { Telemetry(). }

SET MaxQ TO 18000. // Figure out formula
SET Margin TO 180. // Height margin of MaxQ

DECLARE FUNCTION getLocalG {
    RETURN SHIP:BODY:mu / SHIP:BODY:POSITION:MAG ^ 2.
}
DECLARE FUNCTION getTWR {
    // if SHIP:AVAILABLETHRUST is invalid, return 0.
    IF SHIP:availablethrust = 0 { RETURN 0. }
//    RETURN SHIP:MASS * getLocalG() / Ship:AVAILABLETHRUST.
    RETURN  Ship:AVAILABLETHRUST / ( SHIP:MASS * getLocalG() ).
}
DECLARE FUNCTION getPitch {
    RETURN VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR).
}
DECLARE FUNCTION getAzi {
    SET val TO 0.
    RETURN val.
}
DECLARE FUNCTION CalcAzi {
    DECLARE parameter i.

    SET val TO i + 0.
    IF val > 360 {
        RETURN val - 360.
    }
    RETURN val.
}.
DECLARE FUNCTION readyToPrograde {
    SET Deviation TO 0.1.
    SET ForceHeight TO MaxQ * 1.2.
    IF STAGE:SOLIDFUEL > EMPTY { RETURN False. } // Force solid busters to go streight up

    IF SHIP:altitude > ForceHeight { 
        PRINT "ALTITUDE OVERRIDE FORCE PROGRADE!!!".
        RETURN True. } // Over MaxQ + double margin, always go Prograde.

    IF ABS(SHIP:FACING:PITCH - SHIP:PROGRADE:PITCH) > Deviation { RETURN False. }
    PRINT "READY TO PROGRADE".
    RETURN True.
}
SET hasTermometer TO False.
SET hasBarometer TO False.
LIST SENSORS IN SENSELIST.
FOR S IN SENSELIST {
    IF S:TYPE = "TEMP" {
        SET hasTermometer TO True.
    }
    IF S:TYPE = "PRES" {
        SET hasBarometer TO True.
    }
}
DECLARE FUNCTION getMACH {
    IF NOT hasTermometer RETURN False.
    IF NOT hasBarometer RETURN False.
    IF SHIP:SENSORS:TEMP > 0 AND SHIP:SENSORS:PRES > 0 {
        SET universalGasConstant TO 8.314. //  J/mol K
        SET adiabaticConstant TO 1.4. // Constant
        SET airMolMass TO SHIP:SENSORS:PRES / ( universalGasConstant * SHIP:SENSORS:TEMP ). // kg/mol
        SET soundSpeed TO SQRT( ( adiabaticConstant * universalGasConstant ) / airMolMass ) * SQRT(SHIP:SENSORS:TEMP).
        RETURN (SHIP:airspeed / soundSpeed).
    } ELSE RETURN False.
}
DECLARE FUNCTION testStage {
    IF STAGE:SOLIDFUEL < EMPTY AND STAGE:LIQUIDFUEL < EMPTY {
        LOCK THROTTLE TO 0.015. // Make sure a minimum of thrust when staging
        WAIT 0.5.
        STAGE.
        WAIT 2.
        LOCK THROTTLE TO MyThrottle.
    }
}
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


//SAS OFF.
SET MyThrottle TO 1.0.
LOCK THROTTLE TO MyThrottle.
setFacing().
SET MySteer TO HEADING(CalcAzi(AZIMUTH),PITCHUP).
SET MyStatus TO "COUNTDOWN INITIATED!".
IF DEBUG { Telemetry(). }
RUN "0:lib/countdown".
PRINT "Ignition!".
SET MyThrottle TO 1.0.
setSteering().
STAGE.

//PRINT "TWR on Ignition: " + ROUND(getTWR(),3).
IF DEBUG { Telemetry(). }

UNTIL SHIP:verticalspeed > 0 {
    IF DEBUG { Telemetry(). }
    WAIT 0.01.
}
SET MyStatus TO "Lift Off".
PRINT "We have Lift off!".
SET MyThrottle TO 1.0.
setSteering().
UNTIL SHIP:verticalspeed > 100 {
    IF DEBUG { Telemetry(). }
    WAIT 0.01.
}
SET MyStatus TO "Craft Tilted to Initiate Turn".
PRINT "Starting Gravity Turn".
IF SAS {
    SET forceSAS TO True.
    SAS OFF.
}
SET MySteer TO HEADING(CalcAzi(AZIMUTH),TILTED).
setSteering().
IF DEBUG { Telemetry(). }
WAIT 5. // The next step MUST be delayed
// Find angle between FACING:FOREVECTOR and PROGRADE
IF forceSAS {
    SAS ON.
}
UNTIL readyToPrograde() {
    IF DEBUG { Telemetry(). }
    testStage().
    setSteering().
    WAIT 0.1.
}
WAIT 0.1.
IF DEBUG { Telemetry(). }
setPrograde().
setSteering().
WAIT 0.1.
IF DEBUG { Telemetry(). }
WAIT 0.1.
IF DEBUG { Telemetry(). }
setPrograde().
setSteering().
SET MyStatus TO "Prograde Burn".
PRINT "Changing to SAS PROGRADE Mode. (Ending Initial lift)".
IF DEBUG { Telemetry(). }

// Adjust vessel thrust to 1G

SET PITCHLOCK TO False.

UNTIL SHIP:apoapsis > (TARGET_APOAPSIS * 0.9) OR SHIP:altitude > BODY:ATM:HEIGHT {
    SET MyThrottle TO MAX(0.001, MIN(MyThrottle, 1)). // Keep minimum burn all the way
    setSteering().
    IF DEBUG { Telemetry(). }
    testStage().

    // Before maxQ
    //
    // Keep Throttle on acceleration of 1G 300 m/s
    IF getMACH() AND SHIP:altitude < (BODY:ATM:HEIGHT / 1.5) {
//    IF getMACH() AND SHIP:altitude < (BODY:ATM:HEIGHT / 3.18) {
        SET MyStatus TO "Preparing for MaxQ".
        setPrograde().
        // We can use MACH to avoid overburning at MaxQ
        // keep MACH at 0.75 for ideal, never pass 0.8
        // boost thrusters if under 0.7
        IF getMACH() < 0.7 {
            SET MyThrottle TO MyThrottle + 0.05.
        } ELSE IF getMACH() > 0.8 {
            SET MyThrottle TO MyThrottle - 0.1.
        } ELSE IF getMACH() > 0.75 {
            SET MyThrottle TO MyThrottle - 0.001.
        }
    } ELSE IF SHIP:ALTITUDE < MaxQ + Margin {
        IF SHIP:altitude < MaxQ {
            SET MyStatus TO "Before MaxQ".
            IF SHIP:AIRSPEED > 300 AND ETA:apoapsis > 60 {
                SET MyThrottle TO MAX(MyThrottle - 0.015, 0.25).
                setPrograde().
            }
            IF SHIP:AIRSPEED < 300 OR ETA:apoapsis < 58 {
                SET MyThrottle TO MyThrottle + 0.015.
                setPrograde().
            }
//        IF getPitch > 20 {
//            setFacing().
//        }
        } ELSE IF SHIP:altitude < MaxQ + Margin {
    // Approaching maxQ
    //
    // Reduce Throttle to TWR 1.01
            SET MyThrottle TO MIN(MyThrottle,0.3).
            setFacing().
            SET MyStatus TO "In MaxQ ("+SASMODE+")".
        }
    } ELSE IF SHIP:ALTITUDE < BODY:ATM:HEIGHT {
    // After maxQ
        SET MyStatus TO "After MaxQ ("+SASMODE+")".
        // Throttle up to 2G
        IF ETA:APOAPSIS < 45 {
            setFacing().
            SET MyThrottle TO MyThrottle + 0.015.
        }
        IF ETA:apoapsis < 60 {
            SET MyThrottle TO MyThrottle + 0.005.
        }
        IF ETA:APOAPSIS > 240 {
            setPrograde().
            SET PITCHLOCK TO False.
            SET MyThrottle TO MAX(MyThrottle - 0.001, 0.015).
        }
        IF ETA:apoapsis > 270 {
            SET MyThrottle TO MAX(MyThrottle - 0.01, 0.015).
        }
        IF SHIP:altitude < BODY:ATM:height / 3 AND getPitch() > 30 {
            SET PITCHLOCK TO True.
            setFacing().
        } ELSE IF SHIP:altitude < BODY:ATM:height / 2 AND getPitch() > 45 {
            SET PITCHLOCK TO True.
            setFacing().
        } ELSE IF SHIP:altitude < BODY:ATM:height / 1.5 AND getPitch() > 60 {
            SET PITCHLOCK TO True.
            setFacing().
        } ELSE IF SHIP:altitude < BODY:ATM:height AND getPitch() > 80 {
            SET PITCHLOCK TO True.
            setFacing().
        }
    // Adjust throttle to maintain Apoapsis between 35 and 31 seconds ahead until athmosphere is breached
    } ELSE {
        // Here we should already be flying quite flat, just make sure Apoapsis keep growing
        // ETA to Apoapsis will suddenly increase rapidly, so no point in forcing it to remain around
        // 30 seconds.
        SET MyStatus TO "Over Athmosphere, lets throttle up".
        setPrograde().
        SET MyThrottle TO MyThrottle + 0.005.
    }
    WAIT 0.1.
}


// Keep minimum burn on engines until outside athmosphere
UNTIL SHIP:altitude > BODY:ATM:HEIGHT {
    SET MyStatus TO "In Athmosphere, continue minimum burn!".
    testStage().
    setPrograde().
    SET MyThrottle TO 0.001.
    setSteering().
    IF DEBUG { Telemetry(). }
    WAIT 0.1.
}
UNTIL SHIP:apoapsis > (TARGET_APOAPSIS * 0.95) OR SHIP:periapsis > (TARGET_PERIAPSIS * 0.95) OR SHIP:apoapsis > BODY:radius {
    SET MyStatus TO "Escaped Athmosphere, continue burn to reach target apoapsis".
    testStage().
    setPrograde().
    IF ETA:apoapsis > (SHIP:ORBIT:PERIOD / 2) {
        setFacing().
    }
    SET MyThrottle TO 1.
    setSteering().
    IF DEBUG { Telemetry(). }
    WAIT 0.1.
}
// We have achieved desired minimum AP and escaped athmosphere
SET MyThrottle TO 0.
setSteering().
//LOCK THROTTLE TO MyThrottle.
PRINT "Desired Apoapsis achieved, preparing final burn for orbit.".
IF DEBUG { Telemetry(). }
WAIT 1.

PRINT "Lifting Periapsis over athmosphere".
SET MyStatus TO "Lifting Periapsis.".
SAS ON.
UNTIL SHIP:periapsis > BODY:ATM:HEIGHT {
    IF DEBUG { Telemetry(). }
    setSteering().
    IF SHIP:periapsis < SAFE_PERIAPSIS {
        testStage().
        IF ETA:apoapsis < 58 { SET MyThrottle TO MyThrottle + 0.1. }
        IF ETA:apoapsis > 60 { SET MyThrottle TO MyThrottle - 0.01. }
        IF ETA:apoapsis > 70 { SET MyThrottle TO MyThrottle - 0.04. }
        IF ETA:apoapsis > 99 { SET MyThrottle TO 0. }
        IF ETA:apoapsis > (SHIP:ORBIT:PERIOD / 2) {
            setFacing().
            SET MyThrottle TO 1.
        } ELSE {
            setPrograde().
        }
//        IF ETA:apoapsis < 3 { setFacing(). }
        SET MyThrottle TO MIN(MAX(MyThrottle, 0), 1).
    } ELSE {
        SET MyThrottle TO 0.
    }
    WAIT 0.1.
}
WAIT 1.
SET NOBURN TO False.
IF DEBUG { Telemetry(). }
IF TOURIST {
    PRINT "ORBIT ACHIEVED, RETURNING TO SURFACE.".
    IF DEBUG { Telemetry(). }
    SAS OFF.
    LOCK THROTTLE TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    UNLOCK STEERING.
    UNLOCK THROTTLE.
} ELSE {
    PRINT "Initiating final adjustments!".
    SET MyStatus TO "Setting Final Orbit.".
    WAIT 0.1.
    RUN "0:orbit/setOrbit" (TARGET_APOAPSIS, TARGET_PERIAPSIS).
}
WAIT 1.
IF DEBUG { Telemetry(). }
SAS OFF.
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
UNLOCK STEERING.
UNLOCK THROTTLE.

SET MyStatus TO "Gravity Turn Completed.".
PRINT "Gravity Turn completed. Orbit adjustments needed.".
PRINT "Current Apoapsis: " + ROUND(SHIP:apoapsis,1).
PRINT "Current Periapsis: " + ROUND(SHIP:periapsis,1).
IF DEBUG { Telemetry(). }
