RUN ONCE "0:lib/utils/std".

DECLARE FUNCTION telemetryOrbit {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.


    IF SHIP:apoapsis < 0 {
        PRINT "Apoapsis: NaN                      " AT(0,LINENUM).
        PRINT "ETA: NaN      " AT(FLOOR(TERMINAL:WIDTH/2),LINENUM).
    } ELSE {
        PRINT "Apoapsis: " + ROUND(SHIP:apoapsis,1) + "m              " AT(0,LINENUM).
        PRINT "ETA: " + printTime(ETA:apoapsis) +"            " AT(FLOOR(TERMINAL:WIDTH/2),LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    IF SHIP:BODY:NAME = "Sun" {
        PRINT "Periapsis: " + ROUND(SHIP:periapsis,1) + "m              " AT(0,LINENUM).
        PRINT "ETA: " + printTime(ETA:periapsis) +"            " AT(FLOOR(TERMINAL:WIDTH/2),LINENUM).
    } ELSE IF SHIP:periapsis > SHIP:BODY:soiradius {
        PRINT "Periapsis: NaN                      " AT(0,LINENUM).
        PRINT "ETA: NaN      " AT(FLOOR(TERMINAL:WIRTH/2),LINENUM). 
    } ELSE {
        PRINT "Periapsis: " + ROUND(SHIP:periapsis,1) + "m              " AT(0,LINENUM).
        PRINT "ETA: " + printTime(ETA:periapsis) +"            " AT(FLOOR(TERMINAL:WIDTH/2),LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    PRINT "Altitude: " + ROUND(SHIP:altitude,1) + "m / " + ROUND(SHIP:verticalSpeed,1) + "m/s (vert)          " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF (BODY:ATM:HEIGHT > 5000 AND SHIP:ALTITUDE < BODY:ATM:HEIGHT) OR SHIP:ALTITUDE < (SAFE_ALTITUDES[SHIP:BODY:NAME] * 1.5) {
        PRINT "Height over ground: " + ROUND(SHIP:BOUNDS:BOTTOMALTRADAR,1) + "m                                    " AT(0,LINENUM).
    } ELSE {
        PRINT "Height over ground: NaN                                                   " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    PRINT "Velocity: " + ROUND(SHIP:orbit:velocity:orbit:mag,1) + "m/s (Orbit)           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    SET mach TO "".
    IF hasTermometer AND hasBarometer {
        IF SHIP:SENSORS:TEMP > 0 AND SHIP:SENSORS:PRES > 0 {
            SET airMolMass TO SHIP:SENSORS:PRES / ( universalGasConstant * SHIP:SENSORS:TEMP ). // kg/mol
            SET soundSpeed TO SQRT( ( adiabaticConstant * universalGasConstant ) / airMolMass ) * SQRT(SHIP:SENSORS:TEMP).
            SET mach TO "/ "+ ROUND(SHIP:airspeed / soundSpeed, 2) +"M".
        }
    }
    IF HASTARGET {
        // PRINT "Velocity: " + ROUND( (TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT) , 1) + "m/s (Target)                                        " AT(0,LINENUM).
    } ELSE IF SHIP:altitude < SAFE_ALTITUDES[SHIP:BODY:NAME] { // In athmosphere
        PRINT "Velocity: " + ROUND(SHIP:airspeed,1) + "m/s (Air) "+mach+"                                   " AT(0,LINENUM).
    } ELSE {
        PRINT "Velocity: NaN m/s                                            " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    PRINT "Inclination: i " + ROUND(SHIP:orbit:inclination, 2) + "°        " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Eccentricity: e " + ROUND(SHIP:ORBIT:eccentricity,5) + "       " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Ascending Node: ☊ " + ROUND(SHIP:ORBIT:LAN,1) + "°            " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Argument of PE: ω " + ROUND(SHIP:ORBIT:argumentofperiapsis,1) + "°            " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Rotation Angle: ♈︎ " + ROUND(BODY:ROTATIONANGLE,2) + "°                "  AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "True Anomaly: θ " + ROUND(SHIP:ORBIT:trueanomaly, 1) + "°          " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF SHIP:apoapsis > 0 {
        PRINT "Anomaly Speed: " + ROUND(SHIP:ORBIT:PERIOD / 360, 2) + "s/°      " AT(0,LINENUM).
    } ELSE {
        PRINT "Anomaly Speed: NaN s/°                                                                       " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    // Need to capture "Infinitys" for when orbit changes between bodies, or drifting between orbits.
    IF SHIP:apoapsis < 0 {
        SET LAPTIME TO "Infinity".
    } ELSE {
        SET LAPTIME TO printTime(SHIP:orbit:period).
    }
    PRINT "Orbital Period: " + LAPTIME + "       " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    SET NodeEta TO ROUND(ETA:NEXTNODE,1).
    IF SHIP:apoapsis < 0 { SET NodeEta TO "N/A". // Yikes!
    } ELSE IF NodeEta > SHIP:ORBIT:period { SET NodeEta TO "N/A". // If you cannot reach node this laps, than it is unreachable 
    } ELSE {
        SET NodeEta TO printTime(NodeEta).
    }
    PRINT "Next Maneuver Node in " + NodeEta + "                                                      " AT(0,LINENUM).
}
