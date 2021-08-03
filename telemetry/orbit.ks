CLEARSCREEN.

SET MAXCHARGE TO MAX(ROUND(SHIP:ELECTRICCHARGE,0),0.001).
SET MAXLF TO MAX(ROUND(SHIP:LIQUIDFUEL,0),0.001).
SET MAXOX TO MAX(ROUND(SHIP:OXIDIZER,0),0.001).
SET MAXMP TO MAX(ROUND(SHIP:MONOPROPELLANT,0),0.001).
SET MAXSF TO MAX(ROUND(SHIP:SOLIDFUEL,0),0.001).
SET MAXABLA TO MAX(ROUND(SHIP:ABLATOR,0),0.001).
SET XENOMAX TO MAX(ROUND(SHIP:XENONGAS,0),0.001).
SET AIRMAX TO MAX(ROUND(SHIP:INTAKEAIR,0),0.001).
SET MAXORE TO MAX(ROUND(SHIP:ORE,0),0.001).

DECLARE FUNCTION getLocalG {
    RETURN SHIP:BODY:mu / SHIP:BODY:POSITION:MAG ^ 2.
}
DECLARE FUNCTION getTWR {
    // if SHIP:AVAILABLETHRUST is invalid, return 0.
    IF SHIP:availablethrust = 0 { RETURN 0. }
//    RETURN (SHIP:MASS * getLocalG() ) / Ship:AVAILABLETHRUST.
    RETURN  SHIP:AVAILABLETHRUST / (SHIP:MASS * getLocalG() ).
}

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
}


global MyACC IS V(0,0,0).
global myLastVel is SHIP:VELOCITY:ORBIT.
global myLastTime is TIME:SECONDS.


UNTIL false {
    SET LINENUM TO 0.
    // Status
    PRINT SHIP:TYPE + ": " + SHIPNAME + "                           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF SHIP:STATUS = "ORBITING" {
        PRINT "In Orbit around " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "LANDED" {
        PRINT "Landed on " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "SPLASHED" {
        PRINT "Splashed in " + SHIP:BODY:NAME + "'s Oceans                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "PRELAUNCH" {
        PRINT "Pre-Launche preparations at " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "FLYING" {
        PRINT "Flying over " + SHIP:BODY:NAME + "                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "SUB_ORBITAL" {
        PRINT "In Sub-Orbital flight over " + SHIP:BODY:NAME  + "                   "AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "ESCAPING" {
        PRINT "Escaping " + SHIP:BODY:NAME + "'s SOI                   " AT(0,LINENUM).
    } ELSE IF SHIP:STATUS = "DOCKED" {
        PRINT "Docked in orbit over " + SHIP:BODY:NAME + "                   " AT(0,LINENUM). // Get target name for dock.
    }
    // Here we should identify radio link to KSC, how many hops, and total signal strength
//PRINT    SHIP:CONNECTION:destination.
    SET LINENUM TO LINENUM + 1.
    IF (HOMECONNECTION:ISCONNECTED) {
        PRINT "Connected to " + HOMECONNECTION:DESTINATION + " with signal delay of " + ROUND(HOMECONNECTION:delay,2) + "s                     " AT(0,LINENUM).
    } ELSE {
        PRINT "NO RADIO CONNECTION!!!                                                                          " AT(0,LINENUM).
    }
// Stats such as Signal Strength, and connected station is desired here

    // Behaviour
    SET LINENUM TO LINENUM + 1.
    SET LINENUM TO LINENUM + 1.
    PRINT "Yaw: " + ROUND(VectorAngle(SHIP:UP:TOPVECTOR,SHIP:FACING:TOPVECTOR), 1) + "° / Pitch: " + ROUND(VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR), 1) + "° / Roll: " + ROUND(VectorAngle(SHIP:UP:STARVECTOR,SHIP:FACING:STARVECTOR), 1) + "°                    " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF (RCS) { SET tmp TO "ON / ". } ELSE { SET tmp TO "OFF/ ". }
    PRINT "RCS: " + tmp + "                      " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF (SAS) { SET tmp TO "ON / ". } ELSE { SET tmp TO "OFF/ ". }
    PRINT "SAS: " + tmp + SASMODE + "           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Throttle: " + ROUND(THROTTLE * 100, 1) + "%            " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Local G: " + ROUND(getLocalG(), 4) + "m/s²                 " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Available Thrust: " + ROUND(SHIP:availablethrust,1) + "kN             " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Ship Mass: " + ROUND(SHIP:MASS, 2) + "Te                 " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "TWR: " + ROUND(getTWR(),2) + "               " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "deltaV: " + ROUND(SHIP:DELTAV:CURRENT,1) + "m/s               " AT(0,LINENUM).
// Add Throttle position, TWR, acceleration, G, and maneuver mode here

    //Sensors
    SET LINENUM TO LINENUM + 1.
    SET LINENUM TO LINENUM + 1.
    PRINT "Light Exposure: " + ROUND(SHIP:SENSORS:LIGHT,1) + "Lux?           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF hasTermometer {
        PRINT "Temp: " + ROUND(SHIP:SENSORS:TEMP,1) + "K / "+ROUND(SHIP:SENSORS:TEMP - 273.15, 1) +"C             " AT(0,LINENUM).
    } ELSE {
        PRINT "Temp: NaN                                                 " AT(0,LINENUM). 
    }
    SET LINENUM TO LINENUM + 1.
    IF hasBarometer {
        IF SHIP:SENSORS:PRES > 0 {
            SET tmp TO ROUND(SHIP:SENSORS:PRES,4) + "kPa".
        } ELSE {
            SET tmp TO "IN VACUUM!".
        }
    } ELSE { SET tmp TO "NaN". }
    PRINT "Pressure: " + tmp + "                        " AT(0,LINENUM).
    // The following sensors need some code to verify that sensor is present, and to gather the correct value from them.
    SET LINENUM TO LINENUM + 1.
    IF hasAccelerometer {
        PRINT "Acceleration: " + ROUND(SHIP:SENSORS:ACC:MAG,2) + "m/s²                  " AT(0,LINENUM).
    } ELSE {
        local dt IS TIME:SECONDS - myLastTime.
        if dt > 0 {
            SET MyACC TO (ship:velocity:orbit - myLastVel) / dt.
        }
        SET myLastVel TO SHIP:VELOCITY:ORBIT.
        SET myLastTime TO TIME:SECONDS.
        PRINT "Acceleration: "+ROUND(MyACC:MAG,2)+"m/s² (calculated)            " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    IF hasGravometer {
        PRINT "Gravity: "+ SHIP:SENSORS:GRAV:MAG +"m/s²                        " AT(0,LINENUM).
    } ELSE {
        PRINT "Gravity: NaN                  " AT(0,LINENUM).
    }

    SET LINENUM TO LINENUM + 1.
    SET LINENUM TO LINENUM + 1.
    IF ETA:apoapsis < 60 {
        SET APO_ETA TO ROUND(ETA:apoapsis,1).
    } ELSE {
        SET tmp to ROUND(ETA:apoapsis,0).
        SET hr to FLOOR(tmp / 3600).
        SET tmp to tmp - (hr * 3600). // removing hours
        SET min to FLOOR(tmp / 60).
        SET tmp to tmp - (min * 60). // removing minutes
        SET APO_ETA TO hr+"h "+min+"m "+tmp.
    }
    PRINT "Apoapsis: " + ROUND(SHIP:apoapsis,1) + "m     ETA: " + APO_ETA +"s      " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF ETA:periapsis < 60 {
        SET PERI_ETA TO ROUND(ETA:periapsis,1).
    } ELSE {
        SET tmp to ROUND(ETA:periapsis,0).
        SET hr to FLOOR(tmp / 3600).
        SET tmp to tmp - (hr * 3600). // removing hours
        SET min to FLOOR(tmp / 60).
        SET tmp to tmp - (min * 60). // removing minutes
        SET PERI_ETA TO hr+"h "+min+"m "+tmp.
    }
    PRINT "Periapsis: " + ROUND(SHIP:periapsis,1) + "m     ETA: " + PERI_ETA +"s      " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Altitude: " + ROUND(SHIP:altitude,1) + "m / " + ROUND(SHIP:verticalSpeed,1) + "m/s (vert)          " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF SHIP:ALTITUDE < BODY:ATM:HEIGHT OR SHIP:ALTITUDE < 25000 {
        PRINT "Height over ground: " + ROUND(SHIP:BOUNDS:BOTTOMALTRADAR,1) + "m                                    " AT(0,LINENUM).
    } ELSE {
        PRINT "Height over ground: NaN                                                   " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    PRINT "Velocity: " + ROUND(SHIP:orbit:velocity:orbit:mag,1) + "m/s (Orbit)           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    SET mach TO "".
    IF SHIP:SENSORS:TEMP > 0 AND SHIP:SENSORS:PRES > 0 {
        SET universalGasConstant TO 8.314. //  J/mol K
        SET adiabaticConstant TO 1.4. // Constant
        SET airMolMass TO SHIP:SENSORS:PRES / ( universalGasConstant * SHIP:SENSORS:TEMP ). // kg/mol
        SET soundSpeed TO SQRT( ( adiabaticConstant * universalGasConstant ) / airMolMass ) * SQRT(SHIP:SENSORS:TEMP).
        SET mach TO "/ "+ ROUND(SHIP:airspeed / soundSpeed,2) +"M c=("+ROUND(soundSpeed,1)+"m/s)".
    }
    PRINT "Velocity: " + ROUND(SHIP:airspeed,1) + "m/s (Air) "+mach+"                                   " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Inclination: " + ROUND(SHIP:orbit:inclination, 2) + "°        " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Eccentricity: " + ROUND(SHIP:ORBIT:eccentricity,5) + "       " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.

    // Need to capture "Infinitys" for when orbit changes between bodies, or drifting between orbits.
    IF SHIP:apoapsis < 0 {
        SET LAPTIME TO "Infinity".
    } ELSE {
        SET tmp to ROUND(SHIP:ORBIT:PERIOD,1).
        SET hr to FLOOR(tmp / 3600).
        SET tmp to tmp - (hr * 3600). // removing hours
        SET min to FLOOR(tmp / 60).
        SET tmp to tmp - (min * 60). // removing minutes
        SET LAPTIME TO hr+"h "+min+"m "+ROUND(tmp,1).
    }
    PRINT "Orbital Period: " + LAPTIME + "s       " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    SET NodeEta TO ROUND(ETA:NEXTNODE,1).
    IF SHIP:apoapsis < 0 { SET NodeEta TO "N/A". // Yikes!
    } ELSE IF NodeEta > SHIP:ORBIT:period * 10 { SET NodeEta TO "N/A". // If you cannot reach node in 10 laps, than it is unreachable 
    } ELSE IF NodeEta < 60 { SET NodeEta TO NodeEta + "s". 
    } ELSE {
        SET tmp to NodeEta.
        SET hr to FLOOR(tmp / 3600).
        SET tmp to tmp - (hr * 3600). // removing hours
        SET min to FLOOR(tmp / 60).
        SET tmp to tmp - (min * 60). // removing minutes
        SET NodeEta TO hr+"h "+min+"m "+ROUND(tmp,0)+"s".
    }
    PRINT "Next Maneuver Node in " + NodeEta + "       " AT(0,LINENUM).

    //Resources
    SET LINENUM TO LINENUM + 1.
    IF SHIP:ELECTRICCHARGE > MAXCHARGE {
        SET MAXCHARGE TO SHIP:ELECTRICCHARGE.
    }
    SET LINENUM TO LINENUM + 1.  // Units ? density 0
    PRINT "Electric Charge: " + ROUND(SHIP:ELECTRICCHARGE, 2) + " / " + ROUND((SHIP:ELECTRICCHARGE/MAXCHARGE)*100,1) + "%      " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF SHIP:MONOPROPELLANT > 0 { // Units l? density 4kg/l
        PRINT "Monopropellant: " + ROUND(SHIP:MONOPROPELLANT, 2) + " / " + ROUND((SHIP:MONOPROPELLANT/MAXMP)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Monopropellant: N/A                                                                    " AT(0,LINENUM).}
    SET LINENUM TO LINENUM + 1.
    IF SHIP:LIQUIDFUEL > 0 { // units l? density 5kg/l
        PRINT "Liquid Fuel: " + ROUND(SHIP:LIQUIDFUEL, 2) + " / " + ROUND((SHIP:LIQUIDFUEL/MAXLF)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Liquid Fuel: N/A                                                                       " AT(0,LINENUM).}
    SET LINENUM TO LINENUM + 1.
    IF SHIP:OXIDIZER > 0 { // units l? density 5kg/l
        PRINT "Oxidizer: " + ROUND(SHIP:OXIDIZER, 2) + " / " + ROUND((SHIP:OXIDIZER/MAXOX)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Oxidizer: N/A                                                                          " AT(0,LINENUM).}
    SET LINENUM TO LINENUM + 1.
    IF SHIP:SOLIDFUEL > 0 { // units l? density 7.5kg/l 
        PRINT "Solid Fuel: " + ROUND(SHIP:SOLIDFUEL, 2) + " / " + ROUND((SHIP:SOLIDFUEL/MAXSF)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Solid Fuel: N/A                                                                        " AT(0,LINENUM).}
    SET LINENUM TO LINENUM + 1.
    IF SHIP:ABLATOR > 0 { // Ablator units l? density 0.5kg/l 
        PRINT "Ablator: " + ROUND(SHIP:ABLATOR, 2) + " / " + ROUND((SHIP:ABLATOR/MAXABLA)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Ablator: N/A                                                                           " AT(0,LINENUM).}
    SET LINENUM TO LINENUM + 1.
    IF SHIP:XENONGAS > 0 {  // Xenon Gas units l? density 0.1kg 
        PRINT "Xenon Gas: " + ROUND(SHIP:XENONGAS, 2) + " / " + ROUND((SHIP:XENONGAS/XENOMAX)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Xenon Gas: N/A                                                                         " AT(0,LINENUM).}
    SET LINENUM TO LINENUM + 1.
    IF SHIP:ORE > 0 {  // Ore units l? density 19 
        PRINT "Ore: " + ROUND(SHIP:ORE, 2) + " / " + ROUND((SHIP:ORE/MAXORE)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Ore: N/A                                                                         " AT(0,LINENUM).}
    SET LINENUM TO LINENUM + 1.
    IF SHIP:INTAKEAIR > 0 {  // Intake Air units l? density 5kg/l 
        PRINT "Intake Air: " + ROUND(SHIP:INTAKEAIR, 2) + " / " + ROUND((SHIP:INTAKEAIR/AIRMAX)*100,1) + "%      " AT(0,LINENUM).
    } ELSE { PRINT "Intake Air: N/A                                                                         " AT(0,LINENUM).}
    // EVA Propellant units l? density 0kg/l
    SET LINENUM TO LINENUM + 1.
    PRINT "" AT(0,LINENUM).
    WAIT 0.1.
}
