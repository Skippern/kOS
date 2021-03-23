// orbit/gravityturn.ks
//
// Launch with a controlled gravity turn into orbit (100km Ap)
//
// At end of this, even though Periapsis might still be under horizon, 
// maneuvernodes.ks can activate from here, and controlled start planned maneuvers
CLEARSCREEN.

SET INC TO 0.
SET PITCHUP TO 90.
SET TILTED TO 80.

SET MyStatus TO "Preparing Lanuche Sequence".
SET MyAcceleration TO 0.
SET MyThrottle TO 0.

DECLARE FUNCTION Telemetry {
    PRINT MyStatus + "                             " AT(0,0).
    PRINT "Acceleration: " + MyAcceleration + "         " AT(0,1).
    PRINT "TWR:          " + ROUND(getTWR(),2) + "      " AT(0,2).
    PRINT "Throttle:     " + ROUND(MyThrottle * 100, 1) + "%     " AT(0,3).
}
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".
PRINT "Telemetry RX".


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
    // code to compare SHIP:FACING:FOREVECTOR with Orbit Prograde direction
    // SHIP:FACING is a Direction
    // SHIP:PROGRADE is a Direction
//    PRINT SHIP:FACING.
//    PRINT SHIP:PROGRADE.
//    IF ABS( (SHIP:FACING:PITCH + SHIP:FACING:YAW) - (SHIP:PROGRADE:PITCH + SHIP:PROGRADE:YAW) ) > Deviation { RETURN False. }
    IF ABS(SHIP:FACING:PITCH - SHIP:PROGRADE:PITCH) > Deviation { RETURN False. }
//    IF ABS(SHIP:FACING:YAW - SHIP:PROGRADE:YAW) > Deviation { RETURN False. }
//    IF ABS(SHIP:FACING:ROLL - SHIP:PROGRADE:ROLL) > Deviation { RETURN False. }
    RETURN True.
}


SAS OFF.
SET MyThrottle TO 1.0.
SET THROTTLE TO MyThrottle.
SET MySteer TO HEADING(CalcAzi(INC),PITCHUP).

SET MyStatus TO "COUNTDOWN INITIATED!".
Telemetry().
RUN "0:lib/countdown".

PRINT "Ignition!".
SET MyThrottle TO 1.0.
SET THROTTLE TO MyThrottle.
STAGE.

//PRINT "TWR on Ignition: " + ROUND(getTWR(),3).
Telemetry().

UNTIL SHIP:verticalspeed > 0 {
    WAIT 0.01.
}
SET MyStatus TO "Lift Off".
PRINT "We have Lift off!".
//PRINT "TWR at Liftoff: " + ROUND(getTWR(),3).
SET STEERING TO MySteer.
SET MyThrottle TO 1.0.
SET THROTTLE TO MyThrottle.
UNTIL SHIP:verticalspeed > 70 {
    WAIT 0.01.
    Telemetry().
}
SET MyStatus TO "Craft Tilted to Initiate Turn".
PRINT "Starting Gravity Turn".
//PRINT "TWR at Start of Gravity Turn: " + ROUND(getTWR(),3).
SET MySteer TO HEADING(CalcAzi(INC),TILTED).
SET STEERING TO MySteer.
SET MyThrottle TO 1.0.
SET THROTTLE TO MyThrottle.
Telemetry().
WAIT 5. // The next step MUST be delayed
// Find angle between FACING:FOREVECTOR and PROGRADE
UNTIL readyToPrograde() {
    WAIT 0.1.
    SET STEERING TO MySteer.
    Telemetry().
}
UNLOCK STEERING.
WAIT 0.1.
Telemetry().
SAS ON.
WAIT 0.1.
Telemetry().
SET SASMODE TO "PROGRADE".
SET MYSTEER TO SHIP:PROGRADE.
SET STEERING TO MySteer.
SET MyStatus TO "SASMODE PROGRADE".
PRINT "Changing to SAS PROGRADE Mode. (Ending Initial lift)".
//PRINT "TWR at start of PROGRADE: " + ROUND(getTWR(),3).
//SET MyThrottle TO THROTTLE.
Telemetry().

// Adjust vessel thrust to 1G

SET EMPTY TO 0.03.

SET PITCHLOCK TO False.

//PRINT "Throttle currently set to "+ROUND(MyThrottle*100,1)+"%".
UNTIL SHIP:apoapsis > 100000 {
    SET MyThrottle TO MAX(0, MIN(MyThrottle, 1)).
    SET THROTTLE TO MyThrottle.
    SET STEERING TO MySteer.
    Telemetry().

    IF STAGE:SOLIDFUEL < EMPTY AND STAGE:LIQUIDFUEL < EMPTY {
        SET THROTTLE TO 0.
        STAGE.
        WAIT 1.
        SET THROTTLE TO MyThrottle.
        IF getTWR = 0 { STAGE. }
    }

    // Before maxQ
    //
    // Keep Throttle on acceleration of 1G 300 m/s
    IF SHIP:altitude < MaxQ {
        IF SHIP:AIRSPEED > 300 AND ETA:apoapsis > 30 {
            SET MyThrottle TO MAX(MyThrottle - 0.015, 0.25).
            SET SASMODE TO "PROGRADE".
            SET MYSTEER TO SHIP:PROGRADE.
        }
        IF SHIP:AIRSPEED < 300 OR ETA:apoapsis < 28 {
            SET MyThrottle TO MyThrottle + 0.015.
            SET SASMODE TO "PROGRADE".
            SET MYSTEER TO SHIP:PROGRADE.
        }
        IF getPitch > 20 {
            SET SASMODE TO "STABILITYASSIST".
            SET MYSTEER TO SHIP:FACING.
        }
    } ELSE IF SHIP:altitude < MaxQ + Margin {
    // Approaching maxQ
    //
    // Reduce Throttle to TWR 1.01
        SET MyThrottle TO MIN(MyThrottle,0.3).
//        SET SASMODE TO "PROGRADE".
//        SET MYSTEER TO SHIP:PROGRADE.
        SET SASMODE TO "STABILITYASSIST".
        SET MYSTEER TO SHIP:FACING.
        SET MyStatus TO "In MaxQ ("+SASMODE+")".
    } ELSE IF SHIP:ALTITUDE < BODY:ATM:HEIGHT {
    // After maxQ
        SET MyStatus TO "After MaxQ ("+SASMODE+")".
        // Throttle up to 2G
        IF ETA:APOAPSIS < 30 {
            SET SASMODE TO "STABILITYASSIST".
            SET MYSTEER TO SHIP:FACING.
            SET MyThrottle TO MyThrottle + 0.015.
        }
        IF ETA:apoapsis < 35 {
            SET MyThrottle TO MyThrottle + 0.001.
        }
        IF ETA:APOAPSIS > 35 {
            IF NOT PITCHLOCK {
                SET SASMODE TO "PROGRADE".
                SET MYSTEER TO SHIP:PROGRADE.
            }
            SET PITCHLOCK TO False.
            SET MyThrottle TO MAX(MyThrottle - 0.001, 0.015).
        }
        IF ETA:apoapsis > 60 {
            SET MyThrottle TO MAX(MyThrottle - 0.01, 0.015).
        }
        IF SHIP:altitude < BODY:ATM:height / 3 AND getPitch() > 30 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MYSTEER TO SHIP:FACING.
        } ELSE IF SHIP:altitude < BODY:ATM:height / 2 AND getPitch() > 45 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MYSTEER TO SHIP:FACING.
        } ELSE IF SHIP:altitude < BODY:ATM:height / 1.5 AND getPitch() > 60 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MYSTEER TO SHIP:FACING.
        } ELSE IF SHIP:altitude < BODY:ATM:height AND getPitch() > 80 {
            SET PITCHLOCK TO True.
            SET SASMODE TO "STABILITYASSIST".
            SET MYSTEER TO SHIP:FACING.
        }
    // Adjust throttle to maintain Apoapsis between 35 and 31 seconds ahead until athmosphere is breached
    } ELSE {
        // Here we should already be flying quite flat, just make sure Apoapsis keep growing
        // ETA to Apoapsis will suddenly increase rapidly, so no point in forcing it to remain around
        // 30 seconds.
        SET MyStatus TO "Over Athmosphere, lets throttle up".
        SET SASMODE TO "PROGRADE".
        SET MYSTEER TO SHIP:PROGRADE.
        SET MyThrottle TO MyThrottle + 0.001.
    }
    WAIT 0.1.
}
UNTIL SHIP:altitude > BODY:ATM:HEIGHT {
    SET SASMODE TO "PROGRADE".
    SET MYSTEER TO SHIP:PROGRADE.
    SET THROTTLE TO 0.01.
}
SET THROTTLE TO 0.
PRINT "Desired Apoapsis achieved, preparing final burn for orbit.".
WAIT 1.

UNTIL ETA:apoapsis < 15 { // seconds before Ap for final burn
    WAIT 0.1.
    SET MYSTEER TO SHIP:PROGRADE.
}
PRINT "Initiating final burn!".
UNTIL SHIP:periapsis > MAX(BODY:ATM:HEIGHT * 1.1, 50000) {
    SET THROTTLE TO 1.0.
    SET MYSTEER TO SHIP:PROGRADE.
    WAIT 0.1.
}

SAS OFF.
SET THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.

PRINT "Gravity Turn completed. Orbit adjustments needed.".
PRINT "Current Apoapsis: " + ROUND(SHIP:apoapsis,1).
PRINT "Current Periapsis: " + ROUND(SHIP:periapsis,1).
