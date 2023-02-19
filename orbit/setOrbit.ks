// orbit/setOrbit.ks
DECLARE PARAMETER MY_APOAPSIS IS SHIP:ORBIT:apoapsis, 
                    MY_PERIAPSIS IS SHIP:ORBIT:periapsis, 
                    INCLINATION IS SHIP:ORBIT:inclination, 
                    ASCENDING_NODE IS SHIP:ORBIT:LAN, 
                    ARGUMENT_PE IS SHIP:ORBIT:argumentofperiapsis.
//
// APOAPSIS: Desired Apoapsis, if lower than BODY:ATM:HEIGHT or safe orbit height of the orbiting body, this is ignored
// PERIAPSIS:  Desired Apoapsis, if lower than BODY:ATM:HEIGHT or safe orbit height of the orbiting body, this is ignored
// INCLINATION: Inclination of orbit in degrees, if False keep current inclination
// ASCENDING_NODE: Latitude of Ascending Node, if False ignore this
// ARGUMENT_PE: Argument of Periapsis, if False ignore this
//
// RUN "0:orbit/setOrbit" (500000, 400000).
clearScreen.

IF MY_APOAPSIS = 0 { SET MY_APOAPSIS TO SHIP:ORBIT:apoapsis. }
IF MY_PERIAPSIS = 0 { SET MY_PERIAPSIS TO SHIP:ORBIT:periapsis. }
IF MY_APOAPSIS < BODY:ATM:HEIGHT { SET MY_APOAPSIS TO BODY:RADIUS. }
IF MY_PERIAPSIS > MY_APOAPSIS { SET MY_PERIAPSIS TO MY_APOAPSIS. }

RUN ONCE "0:/lib/utils/std".

DECLARE FUNCTION getReady {
    IF INCLINATION {
        // Test if Inclination matches
        IF ABS(INCLINATION - SHIP:ORBIT:inclination) > 0.3 {
            RETURN False.
        }
    }
    IF ASCENDING_NODE { // Ignore this on circular orbit
        // Test if Ascending Node matches
        IF ABS(ASCENDING_NODE - SHIP:ORBIT:lan) > 0.3 {
            RETURN False.
        }
    }
    IF ARGUMENT_PE { // Ignore this on circular orbit
        // Test if Argument of Periapsis matches
        IF ABS(ARGUMENT_PE - SHIP:ORBIT:argumentofperiapsis) > 0.3 {
            RETURN False.
        }
    }
    // Apoapsis
    IF SHIP:ORBIT:apoapsis > (MY_APOAPSIS * 1.01) {
        RETURN False.
    }
    IF SHIP:ORBIT:apoapsis < (MY_APOAPSIS * 0.99) {
        RETURN False.
    }
    // Periapsis
    IF SHIP:ORBIT:periapsis > (MY_PERIAPSIS * 1.01) {
        RETURN False.
    }
    IF SHIP:ORBIT:periapsis < (MY_PERIAPSIS * 0.99) {
        RETURN False.
    }
    RETURN True.
}
DECLARE FUNCTION ariesSector {
    PARAMETER point.
    PARAMETER pointDev IS 15.
    IF point > 360 { SET point TO point - 360. }
    IF point > 360 { SET point TO point - 360. }
    IF point < 0 { SET point TO point + 360. }
    IF point > 360 OR point < 0 { RETURN False. } // Invalid point is always false.
    SET StartPoint TO point - pointDev.
    SET EndPoint TO point + pointDev.

    IF ( StartPoint < BODY:ROTATIONANGLE ) AND ( BODY:ROTATIONANGLE < EndPoint ) {
    //     345           360                                0                    15
        RETURN True.
    }
    IF ( StartPoint < 0 ) AND ((360 + StartPoint ) < BODY:ROTATIONANGLE ) {
        RETURN True.
    }
    IF (EndPoint > 360) AND ( BODY:ROTATIONANGLE < ( EndPoint - 360)) {
        RETURN True.
    }
    RETURN False.
}
DECLARE FUNCTION orbitSector {
    PARAMETER point.
    PARAMETER pointDev IS 15.
    IF point > 360 OR point < 0 { RETURN False. } // Invalid point is always false.
    SET StartPoint TO point - pointDev.
    SET EndPoint TO point + pointDev.

    IF ( StartPoint < SHIP:ORBIT:trueanomaly ) AND ( SHIP:ORBIT:trueanomaly < EndPoint ) {
    //     345           360                                0                    15
        RETURN True.
    }
    IF ( StartPoint < 0 ) AND ((360 + StartPoint ) < SHIP:ORBIT:trueanomaly ) {
        RETURN True.
    }
    IF (EndPoint > 360) AND ( SHIP:ORBIT:trueanomaly < ( EndPoint - 360)) {
        RETURN True.
    }
    RETURN False.
}

SET CurrentTask TO "IDLE".
    SET BURNFORCE TO 0.
    SET LINENUM TO 0.
    DECLARE FUNCTION Telemetry {
        SET LINENUM TO 0.
        PRINT "Setting Orbit araund " + SHIP:ORBIT:BODY:NAME + " for: " + SHIP:NAME + "         " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Adjusting Orbit: " + CurrentTask + "                             " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "APOAPSIS:                       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Current: " + ROUND(SHIP:ORBIT:APOAPSIS,1) + "m        ETA: " + printTime(ETA:apoapsis) + "         " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Target: " + ROUND(MY_APOAPSIS,1) +"m     diff: " + ROUND(ABS( MY_APOAPSIS - SHIP:ORBIT:apoapsis ),0) + "m "+ROUND( (ABS(MY_APOAPSIS - SHIP:ORBIT:apoapsis)/MY_APOAPSIS) * 100,1)+"%       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "PERIAPSIS:                       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Current: " + ROUND(SHIP:ORBIT:PERIAPSIS,1) + "m        ETA: " + printTime(ETA:periapsis) + "         " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Target: " + ROUND(MY_PERIAPSIS,1) +"m     diff: " + ROUND(ABS(MY_PERIAPSIS - SHIP:ORBIT:periapsis),0) + "m "+ROUND( (ABS(MY_PERIAPSIS - SHIP:ORBIT:periapsis)/MY_PERIAPSIS) * 100,2)+"%       " AT(0,LINENUM).
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
            PRINT "Ascending Node: ☊ " + ROUND(SHIP:ORBIT:LAN,1) + "°    -> " + ROUND(ASCENDING_NODE,1) + "°        " AT(0,LINENUM).
        } ELSE {
            PRINT "Ascending Node: ☊ " + ROUND(SHIP:ORBIT:LAN,1) + "°            " AT(0,LINENUM).
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
        PRINT "Position over " + SHIP:BODY:NAME + ": " + ROUND(SHIP:geoposition:lat,3)+"/"+ ROUND(SHIP:geoposition:lng,3) + "       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Rotation Angle: ♈︎ " + ROUND(BODY:ROTATIONANGLE,2) + "                "  AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "ECCENTRICITY: e " + ROUND(SHIP:ORBIT:eccentricity,6) + "            " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "True Anomaly: θ " + ROUND(SHIP:ORBIT:trueanomaly, 1) + "°          " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "Anomaly Speed: " + ROUND(SHIP:ORBIT:PERIOD / 360, 2) + "s/°      " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        PRINT "BURNFORCE:  "+ROUND(BURNFORCE,2)+"                       " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        PRINT "MyThrottle:  "+ROUND(MyThrottle,2)+"                      " AT(0,LINENUM).
        SET LINENUM TO LINENUM + 1.
        SET LINENUM TO LINENUM + 1.
        IF SHIP:BODY:NAME = "Kerbin" {
            SET KerbinSideralDay TO 21549.425.
            IF SHIP:ORBIT:PERIOD < (KerbinSideralDay * 0.99) {
                PRINT "TOO LOW ORBIT FOR KEOSTATIONARY, INCREASE ORBIT                                           " AT(0,LINENUM).
            } ELSE IF SHIP:ORBIT:PERIOD < KerbinSideralDay {
                PRINT "SEMI KEOSTATIONARY ORBIT, RISE WITH "+ROUND(ABS(SHIP:ORBIT:PERIOD - KerbinSideralDay),2)+"s                                                     " AT(0,LINENUM).
            } ELSE IF SHIP:ORBIT:PERIOD > (KerbinSideralDay * 1.01) {
                PRINT "TOO HIGH ORBIT FOR KEOSTATIONARY, DECREASE ORBIT                                          " AT(0,LINENUM).
            } ELSE IF SHIP:ORBIT:PERIOD > KerbinSideralDay {
                PRINT "SEMI KEOSTATIONARY ORBIT, LOWER WITH "+ROUND(ABS(SHIP:ORBIT:PERIOD - KerbinSideralDay),2)+"s                                                     " AT(0,LINENUM).
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
// SAS ON.

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
        setNormal().
    } ELSE IF SASMODE = "ANTINORMAL" {
        setAntiNormal().
    } ELSE IF SASMODE = "RADIALIN" {
        setRadialIn().
    } ELSE IF SASMODE = "RADIALOUT" {
        setRadialOut().
    } ELSE IF SASMODE = "TARGET" {
        setTarget().
    } ELSE IF SASMODE = "ANTITARGET" {
        setAntiTarget().
    } ELSE IF SASMODE = "MANEUVER" {
        setManeuver().
    } ELSE IF SASMODE = "STABILITY" {
        setStability().
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
        SET BURNFORCE TO 30 / getTWR().
    } ELSE {
        SET BURNFORCE TO 0.
    }
    // Longitude of ascending node: the longitude an orbit crosses the reference plane
    //
    // Adjust by burning Normal/Antinurmal anywhere than ascending node?
    // I suspect this maneuver can alter all parameters, so best to set first
    //
    IF ASCENDING_NODE AND ABS(ASCENDING_NODE - SHIP:ORBIT:LAN) > 0.1 AND ABS(SHIP:ORBIT:inclination) < 1 AND ariesSector(ASCENDING_NODE + 90, 15) { 
        // Semicircular orbit with low inclination
        IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        SET CurrentTask TO "Adjusting AN (i=0, after AN)                      ".
        IF INCLINATION {
            IF INCLINATION > 0 {
                setNormal().
            } ELSE {
                setAntiNormal().
            }
        } ELSE IF SHIP:ORBIT:INCLINATION > 0 { 
            setNormal().
        } ELSE {
            setAntiNormal().
        }
        IF ariesSector(ASCENDING_NODE + 90, 1) {
            // burn
            SET MyThrottle TO BURNFORCE * ABS(INCLINATION - SHIP:ORBIT:inclination).
        } ELSE {
            // No burn
            SET MyThrottle TO 0.
        }
    } ELSE IF ASCENDING_NODE AND ABS(ASCENDING_NODE - SHIP:ORBIT:LAN) > 0.1 AND ABS(SHIP:ORBIT:inclination) < 1 AND ariesSector(ASCENDING_NODE + 270, 15) { 
        // Semicircular orbit with low inclination
        IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        SET CurrentTask TO "Adjusting AN (i=0, before AN)                 ".
        IF INCLINATION {
            IF INCLINATION > 0 {
                setNormal().
            } ELSE {
                setAntiNormal().
            }
        } ELSE IF SHIP:ORBIT:INCLINATION > 0 { 
            setNormal().
        } ELSE {
            // setAntiNormal().
            setNormal().
        }
        IF ariesSector(ASCENDING_NODE + 270, 1) {
            // burn
            SET MyThrottle TO BURNFORCE * ABS(INCLINATION - SHIP:ORBIT:inclination).
        } ELSE {
            // No burn
            SET MyThrottle TO 0.
        }
        // That was the simple part, now the more complicated is to move AN

    // Argument of periapsis: the angle from the ascending node to its periapsis
    //
    // From near-circular orbit burn prograde at Argument of Periapsis or retrograde where Apoapsis should be
    // for eliptic orbits, burn radial-in/radial-out
    // If large changes is necessary, try circulating the orbit before attempting from near-circular orbit
    // Eccentricity of 0 is fully circular
    // Ecentricity of 1 is an escape orbit
    // For eliptical orbits, burn radial at AN/DN
    //
    // Inclination: the angle at Ascending node between orbit and reference plane.
    //
    // Set inclination by burning Normal/Antinormal at Ascending Node
    // User BODY:ROTATIONANGLE to find position of Ascending Node
    // } ELSE IF INCLINATION AND ABS(INCLINATION - SHIP:ORBIT:inclination) > 0.1 AND orbitSector(180, MAX(15, ((BURNTIME*2)/AngleSpeed))) { // At Apoapsis
    // } ELSE IF INCLINATION AND ABS(INCLINATION - SHIP:ORBIT:inclination) > 0.1 AND ariesSector(SHIP:ORBIT:lan, MAX(15, ((BURNTIME*2)/AngleSpeed))) { // At Ascending Node
    // USE SHIP:GEOPOSITION:lat and SHIP:GEOPOSITION:lng burn 
    // normal/anti-normal when crossing equator be careful with 
    // strong burns when close to target inclination
    } ELSE IF INCLINATION AND ABS(INCLINATION - SHIP:ORBIT:inclination) > 0.1 AND ariesSector(SHIP:ORBIT:lan + 90, 3) { // At Ascending Node + 90
        IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        SET CurrentTask TO "Adjusting Inclination (over AN) ".
        IF INCLINATION > SHIP:ORBIT:INCLINATION {
            // Increase
            SET CurrentTask TO CurrentTask + "Inc".
            setAntiNormal().
        } ELSE IF INCLINATION < SHIP:ORBIT:INCLINATION {
            // Lower
            SET CurrentTask TO CurrentTask + "Low".
            setNormal().
        }
       IF ariesSector(SHIP:ORBIT:LAN + 90, 1) { // Ascending Node
            // burn
            SET MyThrottle TO BURNFORCE * ABS(INCLINATION - SHIP:ORBIT:inclination).
        } ELSE {
            // No burn
            SET MyThrottle TO 0.
        }
    } ELSE IF INCLINATION AND ABS(INCLINATION - SHIP:ORBIT:inclination) > 0.1 AND ariesSector(SHIP:ORBIT:lan + 270, 3) { // At Ascending Node + 270
        IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        SET CurrentTask TO "Adjusting Inclination (under AN) ".
        IF INCLINATION > SHIP:ORBIT:INCLINATION {
            // Lower
            SET CurrentTask TO CurrentTask + "Low".
            setAntiNormal().
        } ELSE IF INCLINATION < SHIP:ORBIT:INCLINATION {
            // Increase
            SET CurrentTask TO CurrentTask + "Inc".
            setNormal().
            // setNormal().
        }
       IF ariesSector(SHIP:ORBIT:LAN + 270, 1) { // Ascending Node
            // burn
            SET MyThrottle TO BURNFORCE * ABS(INCLINATION - SHIP:ORBIT:inclination).
        } ELSE {
            // No burn
            SET MyThrottle TO 0.
        }
    // Last thing to do is to adjust orbit height, this is the last to be done since it will not alter
    } ELSE IF orbitSector(180, MAX(5, ((BURNTIME*2)/AngleSpeed))) {
    // Apoapsis Sector
        SET CurrentTask TO "Adjusting Periapsis             ".
        IF ETA:apoapsis < BURNTIME OR (LAPTIME - ETA:apoapsis) < BURNTIME {
            IF getTWR() > 0 {
                SET MyThrottle TO (BURNFORCE * (ABS(MY_PERIAPSIS - SHIP:ORBIT:periapsis)/MY_PERIAPSIS)  ).
            }
//            SET MyThrottle TO BURNFORCE.
        } ELSE {
            SET MyThrottle TO 0.
        }
        IF SHIP:periapsis < (MY_PERIAPSIS * 0.995) {
            // Lift Periapsis
            setPrograde().
            IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        } ELSE IF SHIP:periapsis > (MY_PERIAPSIS * 1.005) {
            // Lower Periapsis
            setRetrograde().
            IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        } ELSE { // Periapsis accepted
            SET MyThrottle TO 0.
        }
    } ELSE IF orbitSector(0, MAX(5, ((BURNTIME*2)/AngleSpeed))) {
    // Periapsis Sector
        SET CurrentTask TO "Adjusting Apoapsis                  ".
        IF ETA:periapsis < BURNTIME OR (LAPTIME - ETA:periapsis) < BURNTIME  {
            IF (SHIP:periapsis < (BODY:ATM:HEIGHT * 1.01)) AND SASMODE = "RETROGRADE" {
                IF getTWR() > 0 AND ETA:periapsis > (BURNTIME * 2) {
                    SET MyThrottle TO (BURNFORCE *  (ABS(MY_APOAPSIS - SHIP:ORBIT:apoapsis)/MY_APOAPSIS) ).
                }
            } ELSE IF SASMODE = "RETROGRADE" {
                IF getTWR() > 0 {
                    SET MyThrottle TO MAX(0.1, BURNFORCE *  (ABS(MY_APOAPSIS - SHIP:ORBIT:apoapsis)/MY_APOAPSIS) ).
                }
            } ELSE IF SASMODE = "PROGRADE" {
                IF getTWR() > 0 {
                    SET MyThrottle TO MAX(0.1, BURNFORCE *  (ABS(MY_APOAPSIS - SHIP:ORBIT:apoapsis)/MY_APOAPSIS) ).
                }
            } ELSE {
                SET MyThrottle TO 0.
            }
        } ELSE {
            SET MyThrottle TO 0.
        }

        IF SHIP:apoapsis < (MY_APOAPSIS * 0.995) {
            // Lift Apoapsis
            setPrograde().
            IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        } ELSE IF SHIP:apoapsis > (MY_APOAPSIS * 1.005) {
            // Lower Apoapsis
            setRetrograde().
            IF KUNIVERSE:timewarp:rate > 1 { KUNIVERSE:timewarp:cancelwarp(). }
        } ELSE { // Apoapsis accepted
            SET MyThrottle TO 0.
        }
    } ELSE {
        SET CurrentTask TO "IDLE                             ".
        setStability().
    }
    // End
    WAIT 0.1.
}
resetSteering().

PRINT "ORBIT ACCHIEVED:".
PRINT SHIP:NAME + " in stable Orbit around " + SHIP:BODY:NAME.
PRINT "Apoapsis: " + ROUND(SHIP:apoapsis, 1) + "m".
PRINT "Periapsis: " + ROUND(SHIP:periapsis, 1) + "m".
PRINT "".
PRINT "Inclination: i " + ROUND(SHIP:ORBIT:inclination, 1) + "°".
PRINT "Ascending Node: ☊ " + ROUND(SHIP:ORBIT:LAN, 1) + "°". // ☋ for Descending Node
PRINT "Argument of PE: ω " + ROUND(SHIP:ORBIT:argumentofperiapsis, 1) + "°".

