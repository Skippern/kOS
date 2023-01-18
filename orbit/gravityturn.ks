// orbit/gravityturn.ks
DECLARE PARAMETER AZIMUTH IS 90,
                    TILTED IS 80,
                    TARGET_APOAPSIS IS MAX(BODY:ATM:HEIGHT * 1.4, 50000).
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

SET PITCHUP TO 90.

RUN ONCE "0:lib/science/orbitals".
RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/comms".

// Verifying Apoapsis
IF SAFE_ALTITUDES:HASKEY(BODY:NAME) {
    IF TARGET_APOAPSIS < (SAFE_ALTITUDES[BODY:NAME] * 1.1) {
        SET TARGET_APOAPSIS TO SAFE_ALTITUDES[BODY:NAME] * 1.1. 
    } ELSE IF TARGET_APOAPSIS > (SAFE_ALTITUDES[BODY:NAME] * 10) {
        SET TARGET_APOAPSIS TO SAFE_ALTITUDES[BODY:NAME] * 10.
    }
} ELSE IF TARGET_APOAPSIS > SHIP:BODY:SOIRADIUS {
    SET TARGET_APOAPSIS TO SHIP:BODY:SOIRADIUS * 0.99.
} 

// Verifying Periapsis
IF BODY:ATM:HEIGHT > 500  {
    SET SAFE_PERIAPSIS TO BODY:ATM:HEIGHT * 1.01.
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
SET MyThrottle TO 0.
SET forceSAS TO False.
SET acelerometerIsGood TO hasAccelerometer.

WAIT 0.1.

WAIT 0.1.
PRINT "Gravity Turn Sequence is Initiated!".
PRINT "Departure Heading: " + AZIMUTH.
PRINT "Gravity Tilt:      " + TILTED.
PRINT "Target Apoapsis:   " + TARGET_APOAPSIS.
PRINT "Target Periapsis:  " + SAFE_PERIAPSIS.

// SET MaxQ TO 18000. // Figure out formula
IF getMaxQ:HASKEY(BODY:NAME) {
    SET MaxQ TO getMaxQ[BODY:NAME].
} ELSE {
    SET MaxQ TO 1.
}
SET Margin TO MaxQ/100. // Height margin of MaxQ

DECLARE FUNCTION getPitch {
    RETURN VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR).
}
DECLARE FUNCTION getAzi {
    SET val TO 0.
    RETURN val.
}
DECLARE FUNCTION CalcAzi {
    DECLARE parameter inp.

    SET val TO inp + 0.
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
DECLARE FUNCTION getMACH {
    IF getSoundSpeed() {
        RETURN (SHIP:airspeed / getSoundSpeed()).
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

//SAS OFF.
SET MyThrottle TO 1.0.
LOCK THROTTLE TO MyThrottle.
setFacing().
SET MySteer TO HEADING(CalcAzi(AZIMUTH),PITCHUP).
SET MyStatus TO "COUNTDOWN INITIATED!".
RUN "0:lib/countdown".
PRINT "Ignition!".
SET MyThrottle TO 1.0.
setSteering().
STAGE.

//PRINT "TWR on Ignition: " + ROUND(getTWR(),3).

UNTIL SHIP:verticalspeed > 0 {
    WAIT 0.01.
}
SET MyStatus TO "Lift Off".
PRINT "We have Lift off!".
SET MyThrottle TO 1.0.
setSteering().
UNTIL SHIP:verticalspeed > 100 {
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
WAIT 5. // The next step MUST be delayed
// Find angle between FACING:FOREVECTOR and PROGRADE
IF forceSAS {
    SAS ON.
}
UNTIL readyToPrograde() {
    testStage().
    setSteering().
    WAIT 0.1.
}
WAIT 0.1.
setPrograde().
setSteering().
WAIT 0.1.
WAIT 0.1.
setPrograde().
setSteering().
SET MyStatus TO "Prograde Burn".
PRINT "Changing to SAS PROGRADE Mode. (Ending Initial lift)".

// Adjust vessel thrust to 1G

//SET PITCHLOCK TO False.

UNTIL SHIP:apoapsis > (TARGET_APOAPSIS * 0.9) OR SHIP:altitude > BODY:ATM:HEIGHT {
    SET MyThrottle TO MAX(0.001, MIN(MyThrottle, 1)). // Keep minimum burn all the way
    setSteering().
    testStage().

    // Before maxQ
    //
    // Keep Throttle on acceleration of 1G 300 m/s
    // IF hasAccelerometer AND SHIP:altitude < (BODY:ATM:HEIGHT / 3) {
    IF hasAccelerometer AND SHIP:altitude < (MaxQ - Margin) {
        // Acellerate at just over 1G as long as speed is at least 300m/s
        IF SHIP:SENSORS:ACC:MAG / kerbinSurfaceG < 1 OR SHIP:airspeed < 300 { // IF acceleration less than 1G or Airspeed under 300
            SET MyThrottle TO MyThrottle + 0.001.
        } 
        IF SHIP:SENSORS:ACC:MAG / kerbinSurfaceG > 1 AND SHIP:airspeed > 300 { // IF acceleration over 1G and Airspeed over 300m/s
            SET MyThrottle TO MyThrottle - 0.001.
        }
    // } ELSE IF getMACH() AND SHIP:altitude < (BODY:ATM:HEIGHT / 3) {
    } ELSE IF getMACH() AND SHIP:altitude < (MaxQ - Margin) {
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
    // } ELSE IF SHIP:altitude < (BODY:ATM:HEIGHT / 3) {
    } ELSE IF SHIP:altitude < (MaxQ - Margin) {
        // Use calculated acceleration
        IF getCalculatedAccelleration():MAG / kerbinSurfaceG < 1 OR SHIP:airspeed < 300 { // IF acceleration less than 1G or Airspeed under 300
            SET MyThrottle TO MyThrottle + 0.001.
        } 
        IF getCalculatedAccelleration():MAG / kerbinSurfaceG > 1 AND SHIP:airspeed > 300 { // IF acceleration over 1G and Airspeed over 300m/s
            SET MyThrottle TO MyThrottle - 0.001.
        }
        // Avoid going too flat while still inside atmosphere
        IF getPitch() > 75 {
            setFacing().
        } ELSE {
           setPrograde().
        }
    } ELSE IF SHIP:ALTITUDE < BODY:ATM:HEIGHT {
    // After maxQ
        SET MyStatus TO "After MaxQ ("+SASMODE+")".
        // Throttle up to 2G

        // Change this codeblock to use measured acceleration or calculated accelleration
        // Also put in fail check on measured acceleration
        IF acelerometerIsGood AND (ABS(SHIP:SENSORS:ACC:MAG - getCalculatedAccelleration():MAG ) / kerbinSurfaceG > 2) {
            SET acelerometerIsGood TO False.
        }

        IF (acelerometerIsGood AND (SHIP:SENSORS:ACC:MAG / kerbinSurfaceG < 2)) OR ( getCalculatedAccelleration():MAG / kerbinSurfaceG < 2) {
            SET MyThrottle TO MyThrottle + 0.001.
        } 
        IF (acelerometerIsGood AND (SHIP:SENSORS:ACC:MAG / kerbinSurfaceG > 2)) OR ( getCalculatedAccelleration():MAG / kerbinSurfaceG > 2) {
            SET MyThrottle TO MyThrottle - 0.001.
        }

        IF ETA:apoapsis < 60 {
            setFacing().
        } ELSE {
            setPrograde().
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
    WAIT 0.1.
}
//UNTIL SHIP:apoapsis > (TARGET_APOAPSIS * 0.95) OR SHIP:periapsis > (SAFE_PERIAPSIS * 0.95) OR SHIP:apoapsis > BODY:radius {
UNTIL SHIP:apoapsis > (TARGET_APOAPSIS * 0.95) OR SHIP:periapsis > (SAFE_PERIAPSIS * 0.95) {
    SET MyStatus TO "Escaped Athmosphere, continue burn to reach target apoapsis".
    testStage().
    setPrograde().
    IF ETA:apoapsis > (SHIP:ORBIT:PERIOD / 2) {
        setFacing().
    }
    SET MyThrottle TO 1.
    setSteering().
    WAIT 0.1.
}
// We have achieved desired minimum AP and escaped athmosphere
SET MyThrottle TO 0.
setSteering().
//LOCK THROTTLE TO MyThrottle.
PRINT "Desired Apoapsis achieved, preparing final burn for orbit.".
WAIT 1.

PRINT "Lifting Periapsis over athmosphere".
SET MyStatus TO "Lifting Periapsis.".
SAS ON.
UNTIL SHIP:periapsis > SAFE_PERIAPSIS {
    setSteering().
    IF SHIP:periapsis < SAFE_PERIAPSIS {
        testStage().
        IF ETA:apoapsis < 60  - min((getTWR() * 3), 40) { SET MyThrottle TO MyThrottle + 0.1. }
        IF ETA:apoapsis > 60  - min((getTWR() / 2), 20) { SET MyThrottle TO MyThrottle - 0.01. }
        IF ETA:apoapsis > 70  + max((20 - (getTWR())), -5) { SET MyThrottle TO MyThrottle - 0.04. }
        IF ETA:apoapsis > 100 + max((20 - (getTWR() * 5)), -20) { SET MyThrottle TO 0. }
        IF ETA:apoapsis > (SHIP:ORBIT:PERIOD / 2) {
            setFacing().
            SET MyThrottle TO 1.
        } ELSE IF ETA:apoapsis < 5 {
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
resetSteering().

SET MyStatus TO "Gravity Turn Completed.".
PRINT "Gravity Turn completed. Orbit adjustments needed.".
PRINT SHIP:NAME + " is in Orbit around " + SHIP:BODY:NAME.
PRINT "Current Apoapsis: " + ROUND(SHIP:apoapsis,1).
PRINT "Current Periapsis: " + ROUND(SHIP:periapsis,1).
PRINT "".
PRINT "Inclination: i " + ROUND(SHIP:ORBIT:inclination, 1) + "°".
PRINT "Ascending Node: ☊ " + ROUND(SHIP:ORBIT:LAN, 1) + "°".
PRINT "Argument of PE: ω " + ROUND(SHIP:ORBIT:argumentofperiapsis, 1) + "°".
