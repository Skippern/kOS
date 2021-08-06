// orbit/setOrbit.ks
DECLARE PARAMETER APOAPSIS IS 0, PERIAPSIS IS 0, INCLINATION IS False, ASCENDING_NODE IS False, ARGUMENT_PE IS False.
//
// APOAPSIS: Desired Apoapsis, if lower than BODY:ATM:HEIGHT or safe orbit height of the orbiting body, this is ignored
// PERIAPSIS:  Desired Apoapsis, if lower than BODY:ATM:HEIGHT or safe orbit height of the orbiting body, this is ignored
// INCLINATION: Inclination of orbit in degrees, if False keep current inclination
// ASCENDING_NODE: Latitude of Ascending Node, if False ignore this
// ARGUMENT_PE: Argument of Periapsis, if False ignore this
clearScreen.
SET DEBUG TO False.

IF APOAPSIS = 0 { SET APOAPSIS TO SHIP:ORBIT:apoapsis. }
IF PERIAPSIS = 0 { SET PERIAPSIS TO SHIP:ORBIT:periapsis. }
IF APOAPSIS < BODY:ATM:HEIGHT { SET APOAPSIS TO BODY:RADIUS. }
IF PERIAPSIS > APOAPSIS { SET PERIAPSIS TO APOAPSIS. }

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

DECLARE FUNCTION getReady {
    IF INCLINATION {
        // Test if Inclination matches
    }
    IF ASCENDING_NODE {
        // Test if Ascending Node matches
    }
    IF ARGUMENT_PE {
        // Test if Argument of Periapsis matches
    }
    // Apoapsis
    IF SHIP:ORBIT:apoapsis > (APOAPSIS * 1.01) {
        RETURN False.
    }
    IF SHIP:ORBIT:apoapsis < (APOAPSIS * 0.99) {
        RETURN False.
    }
    // Periapsis
    IF SHIP:ORBIT:periapsis > (PERIAPSIS * 1.01) {
        RETURN False.
    }
    IF SHIP:ORBIT:periapsis < (PERIAPSIS * 0.99) {
        RETURN False.
    }
    RETURN True.
}
DECLARE FUNCTION orbitSector {
    PARAMETER point.
    PARAMETER pointDev IS 15.
//    IF point > 360 OR point < 0 { RETURN False. } // Invalid point is always false.
    IF NOT point { RETURN point. }

    SET StartPoint TO point - pointDev.
    SET EndPoint TO point + pointDev.

    IF StartPoint < 0 {
        SET StartPoint TO 360 + StartPoint. 
    }
    IF EndPoint > 360 {
        SET EndPoint TO EndPoint - 360.
    }
    // if point 180
    // StartPoint 165
    // EndPoint 195
    //      165        180                                  180                195
    IF ( StartPoint < SHIP:ORBIT:trueanomaly ) AND ( SHIP:ORBIT:trueanomaly < EndPoint ) {
    //     345           360                                0                    15
        RETURN True.
    }
    RETURN False.
}

DECLARE FUNCTION printTime {
    PARAMETER myTime.
    PARAMETER Precission IS 1.

    SET fract TO ROUND( ROUND(myTime,Precission) - FLOOR(myTime) , Precission).

    SET myTime TO TIMESTAMP(myTime).

    RETURN (myTime:year - 1) + "y " + (myTime:day - 1) + "d " + myTime:hour + "h " + myTime:minute + "m " + (myTime:second + fract) + "s". 
}

SET ApoStatus TO "(Ap status unknown)".
SET PeriStatus TO "(Pe status unknown)".

IF DEBUG {
    SET LINENUM TO 0.
    DECLARE FUNCTION Telemetry {
        SET LINENUM TO 0.
        PRINT "Setting Orbit araund " + SHIP:ORBIT:BODY:NAME + " for: " + SHIP:NAME + "         " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Adjusting Orbit: " + ApoStatus + " " + PeriStatus + "         " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "APOAPSIS:                       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Current: " + ROUND(SHIP:ORBIT:APOAPSIS,1) + "m        ETA: " + printTime(ETA:apoapsis) + "         " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Target: " + ROUND(APOAPSIS,1) +"m     diff: " + ROUND(ABS( APOAPSIS - SHIP:ORBIT:apoapsis ),0) + "m "+ROUND( (ABS(APOAPSIS - SHIP:ORBIT:apoapsis)/APOAPSIS) * 100,1)+"%       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "PERIAPSIS:                       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Current: " + ROUND(SHIP:ORBIT:PERIAPSIS,1) + "m        ETA: " + printTime(ETA:periapsis) + "         " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Target: " + ROUND(PERIAPSIS,1) +"m     diff: " + ROUND(ABS(PERIAPSIS - SHIP:ORBIT:periapsis),0) + "m "+ROUND( (ABS(PERIAPSIS - SHIP:ORBIT:periapsis)/PERIAPSIS) * 100,2)+"%       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "Setable Orbit Data:               " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        IF INCLINATION {
            PRINT "INCLINATION: " + ROUND(SHIP:ORBIT:inclination,2) + "°    -> " + ROUND(INCLINATION,2) + "°        " AT(0,LINENUM).
        } ELSE {
            PRINT "INCLINATION: " + ROUND(SHIP:ORBIT:inclination,2) + "°            " AT(0,LINENUM).
        }
        SET LINENUM TO LINENUM + 1.
        IF ASCENDING_NODE {
            PRINT "Ascending Node: Ω " + ROUND(SHIP:ORBIT:LAN,1) + "°    -> " + ROUND(ASCENDING_NODE,1) + "°        " AT(0,LINENUM).
        } ELSE {
            PRINT "Ascending Node: Ω " + ROUND(SHIP:ORBIT:LAN,1) + "°            " AT(0,LINENUM).
        }
        SET LINENUM TO LINENUM + 1.
        IF ARGUMENT_PE {
            PRINT "Argument of PE: ω " + ROUND(SHIP:ORBIT:argumentofperiapsis,1) + "°    -> " + ROUND(ARGUMENT_PE,1) + "°        " AT(0,LINENUM).
        } ELSE {
            PRINT "Argument of PE: ω " + ROUND(SHIP:ORBIT:argumentofperiapsis,1) + "°            " AT(0,LINENUM).
        }
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "Other Orbit Data:               " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "ECCENTRICITY: " + ROUND(SHIP:ORBIT:eccentricity,6) + "            " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "True Anomaly: " + ROUND(SHIP:ORBIT:trueanomaly, 1) + "°          " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Anomaly Speed: " + ROUND(SHIP:ORBIT:PERIOD / 360, 2) + "s/°      " AT(0,LINENUM).
    }
    IF DEBUG { Telemetry(). }
    SET i TO -2.
    UNTIL i = LINENUM {
        PRINT " ".
        SET i TO i + 1.
    } // Marker moved below telemetry now.
}
SET OrbitAchieved TO False.
SET NOBURN TO False.

UNTIL OrbitAchieved {
    IF DEBUG { Telemetry(). }
    setSteering().
    IF SASMODE = "STABILITYASSIST" {
        setFacing().
    } ELSE IF SASMODE = "RETROGRADE" {
        setRetrograde().
    } ELSE IF SASMODE = "RETROGRADE" {
        setPrograde().
    } ELSE IF SASMODE = "NORMAL" {
    } ELSE IF SASMODE = "ANTINORMAL" {
    } ELSE IF SASMODE = "RADIALIN" {
    } ELSE IF SASMODE = "RADIALOUT" {
    } ELSE IF SASMODE = "TARGET" {
    } ELSE IF SASMODE = "ANTITARGET" {
    } ELSE IF SASMODE = "MANEUVER" {
    } ELSE IF SASMODE = "STABILITY" {
    } ELSE {
    }
    IF getReady() {
        SET OrbitAchieved TO True.
        PRINT "IT IS DONE!!!!".
    }
    SET LAPTIME TO SHIP:ORBIT:PERIOD.
    SET AngleSpeed TO LAPTIME / 360.
    SET BURNTIME TO 60.
    SET BURNFORCE TO 0.001.

    IF orbitSector(180, MAX(15, ((BURNTIME*2)/AngleSpeed))) {
//    IF ETA:apoapsis < (LAPTIME / 4) OR ETA:periapsis > (LAPTIME / 4) {
    // Apoapsis Sector
//        SET BURNTIME TO 60.
//        SET BURNFORCE TO 0.001.
        IF ETA:apoapsis < BURNTIME OR (LAPTIME - ETA:apoapsis) < BURNTIME {
            SET MyThrottle TO BURNFORCE.
        } ELSE {
            SET MyThrottle TO 0.
        }
        IF SHIP:periapsis < (PERIAPSIS * 0.99) {
            // Lift Periapsis
            setPrograde().
            SET PeriStatus TO "(Rise Periapsis)".
        } ELSE IF SHIP:periapsis > (PERIAPSIS * 1.01) {
            // Lower Periapsis
            setRetrograde().
            SET PeriStatus TO "(Lower Periapsis)".
        } ELSE { // Periapsis accepted
            SET MyThrottle TO 0.
            SET PeriStatus TO "(Periapsis OK)".
        }
//    } ELSE {
    } ELSE { // IF orbitSector(0, 45) { // Doesn't wrok cross 0 it seems
    // Periapsis Sector
//        SET BURNTIME TO 60.
//        SET BURNFORCE TO 0.001.
        IF ETA:periapsis < BURNTIME OR (LAPTIME - ETA:periapsis) < BURNTIME  {
            IF (SHIP:periapsis > (BODY:ATM:HEIGHT * 1.01)) AND SASMODE = "RETROGRADE" {
                SET MyThrottle TO BURNFORCE.
            } ELSE IF SASMODE = "PROGRADE" {
                SET MyThrottle TO BURNFORCE.
            } ELSE {
                SET MyThrottle TO 0.
            }
        } ELSE {
            SET MyThrottle TO 0.
        }

        IF SHIP:apoapsis < (APOAPSIS * 0.99) {
            // Lift Apoapsis
            setPrograde().
            SET ApoStatus TO "(Rise Apoapsis)".
        } ELSE IF SHIP:apoapsis > (APOAPSIS * 1.01) {
            // Lower Apoapsis
            setRetrograde().
            SET ApoStatus TO "(Lower Apoapsis)".
        } ELSE { // Apoapsis accepted
            SET MyThrottle TO 0.
            SET ApoStatus TO "(Apoapsis OK)".
        }
    }
    // End
    WAIT 0.1.
}

