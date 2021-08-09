// orbit/setOrbit.ks
DECLARE PARAMETER APOAPSIS IS 0, PERIAPSIS IS 0, INCLINATION IS False, ASCENDING_NODE IS False, ARGUMENT_PE IS False.
//
// APOAPSIS: Desired Apoapsis, if lower than BODY:ATM:HEIGHT or safe orbit height of the orbiting body, this is ignored
// PERIAPSIS:  Desired Apoapsis, if lower than BODY:ATM:HEIGHT or safe orbit height of the orbiting body, this is ignored
// INCLINATION: Inclination of orbit in degrees, if False keep current inclination
// ASCENDING_NODE: Latitude of Ascending Node, if False ignore this
// ARGUMENT_PE: Argument of Periapsis, if False ignore this
clearScreen.

IF APOAPSIS = 0 { SET APOAPSIS TO SHIP:ORBIT:apoapsis. }
IF PERIAPSIS = 0 { SET PERIAPSIS TO SHIP:ORBIT:periapsis. }
IF APOAPSIS < BODY:ATM:HEIGHT { SET APOAPSIS TO BODY:RADIUS. }
IF PERIAPSIS > APOAPSIS { SET PERIAPSIS TO APOAPSIS. }

RUN ONCE "0:/lib/utils/std".

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
    IF point > 360 OR point < 0 { RETURN False. } // Invalid point is always false.
//    IF NOT point { RETURN point. }

    SET StartPoint TO point - pointDev.
    SET EndPoint TO point + pointDev.

//    IF StartPoint < 0 {
//        SET StartPoint TO 360 + StartPoint. 
//    }
//    IF EndPoint > 360 {
//        SET EndPoint TO EndPoint - 360.
//    }
    // if point 180
    // StartPoint 165
    // EndPoint 195
    //      165        180                                  180                195
    IF ( StartPoint < SHIP:ORBIT:trueanomaly ) AND ( SHIP:ORBIT:trueanomaly < EndPoint ) {
    //     345           360                                0                    15
        RETURN True.
    }
    IF ( StartPoint < 0 ) AND ((360 + StartPoint ) < SHIP:ORBIT:trueanomaly ) {
        RETURN True.
    }
    IF (EndPoint > 360) AND ( SHIP:ORBIT:trueanomaly < ( EndPoint - 360))
    IF 
    RETURN False.
}

SET ApoStatus TO "(Ap status unknown)".
SET PeriStatus TO "(Pe status unknown)".
    SET BURNFORCE TO 0.
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
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "BURNFORCE:  "+BURNFORCE+"                       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "MyThrottle:  "+MyThrottle+"                      " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        IF SHIP:BODY:NAME = "Kerbin" {
            SET KerbinSideralDay TO 21549.425.
            IF SHIP:ORBIT:PERIOD < (KerbinSideralDay * 0.99) {
                PRINT "TOO LOW ORBIT FOR KEOSTATIONARY, INCREASE ORBIT                                           " AT(0,LINENUM).
            } ELSE IF SHIP:ORBIT:PERIOD < KerbinSideralDay {
                PRINT "SEMI KEOSTATIONARY ORBIT, RISE WITH "+ABS(SHIP:ORBIT:PERIOD - KerbinSideralDay)+"s                                                     " AT(0,LINENUM).
            } ELSE IF SHIP:ORBIT:PERIOD > (KerbinSideralDay * 1.01) {
                PRINT "TOO HIGH ORBIT FOR KEOSTATIONARY, DECREASE ORBIT                                          " AT(0,LINENUM).
            } ELSE IF SHIP:ORBIT:PERIOD > KerbinSideralDay {
                PRINT "SEMI KEOSTATIONARY ORBIT, LOWER WITH "+ABS(SHIP:ORBIT:PERIOD - KerbinSideralDay)+"s                                                     " AT(0,LINENUM).
            } ELSE IF SHIP:ORBIT:PERIOD = KerbinSideralDay {
                PRINT "IN TRUE KEOSTATIONARY ORBIT, ONLY VARIATION IS DUE TO INCLINATION AND AP/PE DIFF          " AT(0,LINENUM).
            } ELSE {
                PRINT "KEOSTATIONARY ORBIT TIME: 0y 0d 5h 59m 9.425s  (21549.425s)                               " AT(0,LINENUM).
            }
        } ELSE { PRINT "                                                                         " AT(0,LINENUM). }
    }
    Telemetry().
    SET i TO -2.
    UNTIL i = LINENUM {
        PRINT " ".
        SET i TO i + 1.
    } // Marker moved below telemetry now.

PRINT "Setting Orbit araund " + SHIP:ORBIT:BODY:NAME + " for: " + SHIP:NAME + "         ".

SET OrbitAchieved TO False.
SET NOBURN TO False.

UNTIL OrbitAchieved {
   IF (MyThrottle > 0) {
       SET MyThrottle TO MIN(MyThrottle, 1).
       SET MyThrottle TO MAX(MyThrottle, 0.001).
   }
    Telemetry(). // DEBUG
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
//    SET BURNFORCE TO MAX(1 / getTWR(), 0.1).
    IF getTWR() > 0 {
        SET BURNFORCE TO 100 / getTWR().
    } ELSE {
        SET BURNFORCE TO 0.
    }
    IF orbitSector(180, MAX(15, ((BURNTIME*2)/AngleSpeed))) {
    // Apoapsis Sector
        IF ETA:apoapsis < BURNTIME OR (LAPTIME - ETA:apoapsis) < BURNTIME {
            IF getTWR() > 0 {
                SET MyThrottle TO (100 / (getTWR() ) * (ABS(PERIAPSIS - SHIP:ORBIT:periapsis)/PERIAPSIS)  ).
            }
//            SET MyThrottle TO BURNFORCE.
        } ELSE {
            SET MyThrottle TO 0.
        }
        IF SHIP:periapsis < (PERIAPSIS * 0.995) {
            // Lift Periapsis
            setPrograde().
            SET PeriStatus TO "(Rise Periapsis)".
        } ELSE IF SHIP:periapsis > (PERIAPSIS * 1.005) {
            // Lower Periapsis
            setRetrograde().
            SET PeriStatus TO "(Lower Periapsis)".
        } ELSE { // Periapsis accepted
            SET MyThrottle TO 0.
            SET PeriStatus TO "(Periapsis OK)".
        }
    } ELSE IF orbitSector(0, 45) {
    // Periapsis Sector
        IF ETA:periapsis < BURNTIME OR (LAPTIME - ETA:periapsis) < BURNTIME  {
            IF (SHIP:periapsis > (BODY:ATM:HEIGHT * 1.01)) AND SASMODE = "RETROGRADE" {
                IF getTWR() > 0 {
                    SET MyThrottle TO (BURNFORCE *  (ABS(APOAPSIS - SHIP:ORBIT:apoapsis)/APOAPSIS) ).
                }
//                SET MyThrottle TO BURNFORCE.
            } ELSE IF SASMODE = "PROGRADE" {
                IF getTWR() > 0 {
                    SET MyThrottle TO (BURNFORCE *  (ABS(APOAPSIS - SHIP:ORBIT:apoapsis)/APOAPSIS) ).
                }
//                SET MyThrottle TO BURNFORCE.
            } ELSE {
                SET MyThrottle TO 0.
            }
        } ELSE {
            SET MyThrottle TO 0.
        }

        IF SHIP:apoapsis < (APOAPSIS * 0.995) {
            // Lift Apoapsis
            setPrograde().
            SET ApoStatus TO "(Rise Apoapsis)".
        } ELSE IF SHIP:apoapsis > (APOAPSIS * 1.005) {
            // Lower Apoapsis
            setRetrograde().
            SET ApoStatus TO "(Lower Apoapsis)".
        } ELSE { // Apoapsis accepted
            SET MyThrottle TO 0.
            SET ApoStatus TO "(Apoapsis OK)".
        }
    } ELSE {
        SET MyThrottle TO 0.
    }
    // End
    WAIT 0.1.
}

PRINT "ORBIT ACCHIEVED:".
PRINT SHIP:NAME + " in stable Orbit around " + SHIP:BODY:NAME.
PRINT "Apoapsis: " + ROUND(SHIP:apoapsis, 1) + "m".
PRINT "Periapsis: " + ROUND(SHIP:periapsis, 1) + "m".
PRINT "".
PRINT "Inclination: " + ROUND(SHIP:ORBIT:inclination, 1) + "°".
PRINT "Ascending Node: Ω " + ROUND(SHIP:ORBIT:LAN, 1) + "°".
PRINT "Argument of PE: ω " + ROUND(SHIP:ORBIT:argumentofperiapsis, 1) + "°".

