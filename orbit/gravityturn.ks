// orbit/gravityturn.ks
//
// Launch with a controlled gravity turn into orbit (100km Ap)
//
// At end of this, even though Periapsis might still be under horizon, 
// maneuvernodes.ks can activate from here, and controlled start planned maneuvers
CLEARSCREEN.

SET INC TO 0.
SET PITCHUP TO 90.
//SET TILTED TO 85.
SET TILTED TO 82.5.
//SET TILTED TO 80.

SET MyStatus TO "Preparing Lanuche Sequence".
SET MyAcceleration TO 0.
SET MyThrottle TO 0.

DECLARE FUNCTION Telemetry {
    PRINT MyStatus + "                             " AT(0,0).
    IF SAS { SET SASStatus TO " ON/". } ELSE { SET SASStatus TO "OFF/". }
    PRINT "SASMODE:      " + SASStatus + SASMODE + "            " AT(0,1).
    PRINT "Acceleration: " + MyAcceleration + "         " AT(0,2).
    PRINT "TWR:          " + ROUND(getTWR(),2) + "      " AT(0,3).
    PRINT "Throttle:     " + ROUND(MyThrottle * 100, 1) + "%                                " AT(0,4).
}
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".

WAIT 0.1.
Telemetry().

WAIT 0.1.
PRINT "Gravity Turn Sequence is Initiated!".
Telemetry().

//SET g TO body:mu / ship:body:position:mag^2.
//SET TWR TO (Ship:Mass * g) / Ship:possiblethrust.

SET MaxQ TO 18000. // Figure out formula
SET Margin TO 180. // Height margin of MaxQ

//PRINT "TWR = "+TWR.
PRINT "MaxQ = "+maxQ.

DECLARE FUNCTION getLocalG {
    RETURN SHIP:BODY:mu / SHIP:BODY:POSITION:MAG ^ 2.
}
DECLARE FUNCTION getTWR {
    // if SHIP:AVAILABLETHRUST is invalid, return 0.
    IF SHIP:availablethrust = 0 { RETURN 0. }
    RETURN SHIP:MASS * getLocalG() / Ship:AVAILABLETHRUST.
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

    SET val TO i + 90.
    IF val > 360 {
        RETURN val - 360.
    }
    RETURN val.
}.
DECLARE FUNCTION readyToPrograde {
    SET Deviation TO 0.1.
    SET ForceHeight TO MaxQ + (Margin * 2).
    IF STAGE:SOLIDFUEL > 10 { RETURN False. } // Force solid busters to go streight up

    IF SHIP:altitude > ForceHeight { 
        PRINT "ALTITUDE OVERRIDE FORCE PROGRADE!!!".
        RETURN True. } // Over MaxQ + double margin, always go Prograde.

    IF ABS(SHIP:FACING:PITCH - SHIP:PROGRADE:PITCH) > Deviation { RETURN False. }
    PRINT "READY TO PROGRADE".
    RETURN True.
}


SAS OFF.
SET MyThrottle TO 1.0.
LOCK THROTTLE TO MyThrottle.
SET MySteer TO HEADING(CalcAzi(INC),PITCHUP).

SET MyStatus TO "COUNTDOWN INITIATED!".
Telemetry().
RUN "0:lib/countdown".

PRINT "Ignition!".
SET MyThrottle TO 1.0.
LOCK THROTTLE TO MyThrottle.
STAGE.

//PRINT "TWR on Ignition: " + ROUND(getTWR(),3).
Telemetry().

UNTIL SHIP:verticalspeed > 0 {
    Telemetry().
    WAIT 0.01.
}
SET MyStatus TO "Lift Off".
PRINT "We have Lift off!".
//PRINT "TWR at Liftoff: " + ROUND(getTWR(),3).
LOCK STEERING TO MySteer.
SET MyThrottle TO 1.0.
LOCK THROTTLE TO MyThrottle.
UNTIL SHIP:verticalspeed > 100 {
    Telemetry().
    WAIT 0.01.
}
SET MyStatus TO "Craft Tilted to Initiate Turn".
PRINT "Starting Gravity Turn".
//PRINT "TWR at Start of Gravity Turn: " + ROUND(getTWR(),3).
SET MySteer TO HEADING(CalcAzi(INC),TILTED).
LOCK STEERING TO MySteer.
SET MyThrottle TO 1.0.
LOCK THROTTLE TO MyThrottle.
Telemetry().
WAIT 5. // The next step MUST be delayed
// Find angle between FACING:FOREVECTOR and PROGRADE
UNTIL readyToPrograde() {
    Telemetry().
    WAIT 0.1.
    LOCK STEERING TO MySteer.
}
//UNLOCK STEERING.
WAIT 0.1.
Telemetry().
//SAS ON.
WAIT 0.1.
Telemetry().
SET SASMODE TO "PROGRADE".
SET MySteer TO SHIP:PROGRADE.
LOCK STEERING TO MySteer.
SET MyStatus TO "Prograde Burn".
PRINT "Changing to SAS PROGRADE Mode. (Ending Initial lift)".
//PRINT "TWR at start of PROGRADE: " + ROUND(getTWR(),3).
//SET MyThrottle TO THROTTLE.
Telemetry().

// Adjust vessel thrust to 1G

SET EMPTY TO 0.03.

SET PITCHLOCK TO False.

//PRINT "Throttle currently set to "+ROUND(MyThrottle*100,1)+"%".
UNTIL SHIP:apoapsis > MAX(BODY:ATM:HEIGHT * 2, 50000) { // AP to minimum 2 athmosphere height, or 50.000m
    SET MyThrottle TO MAX(0.001, MIN(MyThrottle, 1)). // Keep minimum burn all the way
    LOCK THROTTLE TO MyThrottle.
    LOCK STEERING TO MySteer.
    Telemetry().

    IF STAGE:SOLIDFUEL < EMPTY AND STAGE:LIQUIDFUEL < EMPTY {
        LOCK THROTTLE TO 0.015. // Make sure a minimum of thrust when staging
        STAGE.
        WAIT 2.5.
        LOCK THROTTLE TO MyThrottle.
        IF getTWR = 0 { STAGE. 
            WAIT 2.5. }
    }

    // Before maxQ
    //
    // Keep Throttle on acceleration of 1G 300 m/s
    IF SHIP:altitude < MaxQ {
        IF SHIP:AIRSPEED > 300 AND ETA:apoapsis > 60 {
            SET MyThrottle TO MAX(MyThrottle - 0.015, 0.25).
            SET SASMODE TO "PROGRADE".
            SET MySteer TO SHIP:PROGRADE.
        }
        IF SHIP:AIRSPEED < 300 OR ETA:apoapsis < 58 {
            SET MyThrottle TO MyThrottle + 0.015.
            SET SASMODE TO "PROGRADE".
            SET MySteer TO SHIP:PROGRADE.
        }
//        IF getPitch > 20 {
//            SET SASMODE TO "STABILITYASSIST".
//            SET MySteer TO SHIP:FACING.
//        }
    } ELSE IF SHIP:altitude < MaxQ + Margin {
    // Approaching maxQ
    //
    // Reduce Throttle to TWR 1.01
        SET MyThrottle TO MIN(MyThrottle,0.3).
//        SET SASMODE TO "PROGRADE".
//        SET MySteer TO SHIP:PROGRADE.
        SET SASMODE TO "STABILITYASSIST".
        SET MySteer TO SHIP:FACING.
        SET MyStatus TO "In MaxQ ("+SASMODE+")".
    } ELSE IF SHIP:ALTITUDE < BODY:ATM:HEIGHT {
    // After maxQ
        SET MyStatus TO "After MaxQ ("+SASMODE+")".
        // Throttle up to 2G
        IF ETA:APOAPSIS < 45 {
            SET SASMODE TO "STABILITYASSIST".
            SET MySteer TO SHIP:FACING.
            SET MyThrottle TO MyThrottle + 0.015.
        }
        IF ETA:apoapsis < 60 {
            SET MyThrottle TO MyThrottle + 0.005.
        }
        IF ETA:APOAPSIS > 240 {
            IF NOT PITCHLOCK {
                SET SASMODE TO "PROGRADE".
                SET MySteer TO SHIP:PROGRADE.
            }
            SET PITCHLOCK TO False.
            SET MyThrottle TO MAX(MyThrottle - 0.001, 0.015).
        }
        IF ETA:apoapsis > 270 {
            SET MyThrottle TO MAX(MyThrottle - 0.01, 0.015).
        }
        IF SHIP:altitude < BODY:ATM:height / 3 AND getPitch() > 30 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MySteer TO SHIP:FACING.
        } ELSE IF SHIP:altitude < BODY:ATM:height / 2 AND getPitch() > 45 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MySteer TO SHIP:FACING.
        } ELSE IF SHIP:altitude < BODY:ATM:height / 1.5 AND getPitch() > 60 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MySteer TO SHIP:FACING.
        } ELSE IF SHIP:altitude < BODY:ATM:height AND getPitch() > 80 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MySteer TO SHIP:FACING.
        }
    // Adjust throttle to maintain Apoapsis between 35 and 31 seconds ahead until athmosphere is breached
    } ELSE {
        // Here we should already be flying quite flat, just make sure Apoapsis keep growing
        // ETA to Apoapsis will suddenly increase rapidly, so no point in forcing it to remain around
        // 30 seconds.
        SET MyStatus TO "Over Athmosphere, lets throttle up".
        SET SASMODE TO "PROGRADE".
        SET MySteer TO SHIP:PROGRADE.
        SET MyThrottle TO MyThrottle + 0.005.
    }
    WAIT 0.1.
}
// Keep minimum burn on engines until outside athmosphere
UNTIL SHIP:altitude > BODY:ATM:HEIGHT {
    SET MyStatus TO "In Athmosphere, continue minimum burn!".
    SET SASMODE TO "PROGRADE".
    SET MySteer TO SHIP:PROGRADE.
    LOCK THROTTLE TO 0.01.
    Telemetry().
    WAIT 0.1.
}
// We have achieved desired minimum AP and escaped athmosphere
SET MyThrottle TO 0.001.
LOCK THROTTLE TO MyThrottle.
PRINT "Desired Apoapsis achieved, preparing final burn for orbit.".
Telemetry().
WAIT 1.

// Final attitude burn
SET MyStatus TO "Final Attitude Burn".
IF ETA:apoapsis < 500 {
    UNTIL ETA:apoapsis < 75 { // seconds before Ap for final burn
        Telemetry().
        WAIT 0.1.
        SET SASMODE TO "PROGRADE".
        SET MySteer TO SHIP:PROGRADE.
    }
}
PRINT "Initiating final burn!".
SET MyStatus TO "Final Attitude Burn.".
SET MyThrottle TO 1.0.
SET SASMODE TO "PROGRADE".
SET MySteer TO SHIP:PROGRADE.
UNTIL SHIP:periapsis > MAX(BODY:ATM:HEIGHT * 1.1, 50000) {
    Telemetry().
    IF STAGE:SOLIDFUEL < EMPTY AND STAGE:LIQUIDFUEL < EMPTY {
        LOCK THROTTLE TO 0.015. // Make sure a minimum of thrust when staging
        STAGE.
        WAIT 5.
        LOCK THROTTLE TO MyThrottle.
        IF getTWR = 0 { STAGE. 
            WAIT 5. }
    }
    IF ETA:apoapsis < 30 { SET MyThrottle TO MyThrottle + 0.1. }
    IF ETA:apoapsis > 85 { SET MyThrottle TO MyThrottle - 0.01. }
    IF ETA:apoapsis > 90 { SET MyThrottle TO MyThrottle - 0.04. }
    IF ETA:apoapsis > 600 {
        SET SASMODE TO "STABILITYASSIST".
        SET MySteer TO SHIP:FACING.
        SET MyThrottle TO 1.
    } ELSE {
        SET SASMODE TO "PROGRADE".
        SET MySteer TO SHIP:PROGRADE.
    }
    SET MyThrottle TO MIN(MAX(MyThrottle, 0.015), 1).
    LOCK THROTTLE TO MyThrottle.
    LOCK STEERING TO MySteer.
    WAIT 0.1.
}

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
Telemetry().