CLEARSCREEN.

SET MAXCHARGE TO MAX(ROUND(SHIP:ELECTRICCHARGE,0),0.001).
SET MAXLF TO MAX(ROUND(SHIP:LIQUIDFUEL,0),0.001).
SET MAXOX TO MAX(ROUND(SHIP:OXIDIZER,0),0.001).
SET MAXMP TO MAX(ROUND(SHIP:MONOPROPELLANT,0),0.001).
SET MAXSF TO MAX(ROUND(SHIP:SOLIDFUEL,0),0.001).

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
    // Behaviour
    SET LINENUM TO LINENUM + 1.
    PRINT "Yaw: " + ROUND(VectorAngle(SHIP:UP:TOPVECTOR,SHIP:FACING:TOPVECTOR), 1) + "* / Pitch: " + ROUND(VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR), 1) + "* / Roll: " + ROUND(VectorAngle(SHIP:UP:STARVECTOR,SHIP:FACING:STARVECTOR), 1) + "*                    " AT(0,LINENUM).
//    PRINT "Yaw: " + ROUND(SHIP:direction:yaw, 1) + " / Pitch: " + ROUND(SHIP:direction:pitch, 1) + " / Roll: " + ROUND(SHIP:direction:roll, 1) + "                    " AT(0,LINENUM).
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
    PRINT "Altitude: " + ROUND(SHIP:altitude,1) + "m           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Velocity: " + ROUND(SHIP:orbit:velocity:orbit:mag,1) + "m/s           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "Inclination: " + ROUND(SHIP:orbit:inclination, 2) + "*        " AT(0,LINENUM).
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
    PRINT "Electric Charge: " + ROUND(SHIP:ELECTRICCHARGE, 2) + " / " + ROUND((SHIP:ELECTRICCHARGE/MAXCHARGE)*100,1) + "%      " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    IF SHIP:MONOPROPELLANT > 0 {
        PRINT "Monopropellant: " + ROUND(SHIP:MONOPROPELLANT, 2) + " / " + ROUND((SHIP:MONOPROPELLANT/MAXMP)*100,1) + "%      " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    IF SHIP:LIQUIDFUEL > 0 {
        PRINT "Liquid Fuel: " + ROUND(SHIP:LIQUIDFUEL, 2) + " / " + ROUND((SHIP:LIQUIDFUEL/MAXLF)*100,1) + "%      " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    IF SHIP:OXIDIZER > 0 {
        PRINT "Oxidizer: " + ROUND(SHIP:OXIDIZER, 2) + " / " + ROUND((SHIP:OXIDIZER/MAXOX)*100,1) + "%      " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    IF SHIP:SOLIDFUEL > 0 {
        PRINT "Solid Fiel: " + ROUND(SHIP:SOLIDFUEL, 2) + " / " + ROUND((SHIP:SOLIDFUEL/MAXSF)*100,1) + "%      " AT(0,LINENUM).
    }
    WAIT 0.1.
}
