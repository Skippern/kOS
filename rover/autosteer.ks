clearScreen.

//SET WP TO LATLNG(-0.2, -76).

SET WP_LIST TO list(
    LATLNG(-2.5049,-80.8374),
    LATLNG(-1.4722,-82.2876),
    LATLNG(-0.1099,-81.7383)
//    LATLNG(-0.6402,-80.7688)
).
SET MAXSPEED TO 10. // max speed for rover to drive
SET MAXTURNSPEED TO 2.5. // maxspeed in turn

// Find out what is 80% of capacity!
//SET FULLCHARGE TO SHIP:ELECTRICCHARGE:CAPACITY * 0.8.
SET MAXCHARGE TO ROUND(SHIP:ELECTRICCHARGE,0).
SET FULLCHARGE TO SHIP:ELECTRICCHARGE * 0.8.
SET MINCHARGE TO CEILING(MAX(900, MAXCHARGE / 10)).
SET POWER TO wheelThrottle.
print "Full electric charge is: " + MAXCHARGE. // Assuming ship fully charged


PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "RX Missing".
PRINT "Max Electric Charge: " + MAXCHARGE.
print "Minimum operational charge set to: " + MINCHARGE.

SET POWER TO 0.

LIGHTS ON.
BREAKS ON.
LEGS ON.
PANELS ON.
WAIT 3.

LIST SENSORS IN SENSELIST.
FOR S IN SENSELIST {
    PRINT "SENSOR: " + S:TYPE.
    PRINT "VALUE: " + S:DISPLAY.
    WAIT 1.
    IF S:ACTIVE {
        PRINT "       ACTIVE".
    } ELSE {
        S:TOGGLE().
        PRINT "       SENSOR ACTIVATED NOW! *BEEP!*".
        WAIT 1.
    }
    WAIT 1.
}

DECLARE FUNCTION Telemetry {
    SET LINENUM TO 0.
    PRINT "Ground speed is: " + ROUND(groundSpeed,1) + "m/s                      " AT(0,LINENUM).
    PRINT "Trottle command is: " + ROUND(wheelThrottle * 100,0) + "%                            " AT(0,LINENUM + 1).
    PRINT "Current Latitude: " + ROUND(SHIP:geoposition:lat, 4) + "               " AT(0,LINENUM + 2).
    PRINT "Current Longitude: " + ROUND(SHIP:geoposition:lng, 4) + "                " AT(0,LINENUM + 3).
    SET currentPitch to ROUND(90 - VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR),1).
    PRINT "Heading: " + ROUND(mod(360 - latlng(90,0):bearing,360), 0) + " / Pitch: " + currentPitch + "                     " AT(0,LINENUM + 4).
//    PRINT "Heading/Roll/Pitch to be implemented!                          " AT (0,LINENUM + 4).
    PRINT "Steering: " + ROUND(wheelSteering, 3) + "                   " AT(0,LINENUM + 5).
    PRINT "Electric Charge: " + ROUND(SHIP:ELECTRICCHARGE, 2) + " / " + ROUND((SHIP:ELECTRICCHARGE/MAXCHARGE)*100,1) + "%      " AT(0,LINENUM + 6).
}

DECLARE FUNCTION WPTelemetry {
    DECLARE PARAMETER WP.
    SET LINENUM TO 7.
    PRINT "Bearing to target is: " + ROUND(WP:BEARING,4) + "              " AT(0,LINENUM). 
    PRINT "Distance Remaining to WP: " + FLOOR(WP:DISTANCE) + "m                " AT (0,LINENUM + 1).
    PRINT "WP Latitude: " + ROUND(WP:LAT, 4) + "        " AT(0,LINENUM + 2).
    PRINT "WP Longitude: " + ROUND(WP:LNG, 4) + "         " AT(0,LINENUM + 3).
}

DECLARE FUNCTION CHARGE {
    SET wheelThrottle TO 0.
    BREAKS ON.
    LEGS ON.
    WAIT 1.
    LIGHTS OFF.
    SET SHIP:CONTROL:NEUTRALIZE TO True.
    print "Preparing for full charge.".
    SET PANELSOPEN TO PANELS.
    // CHECK THAT SOLAR PANELS ARE EXTENDED
    IF PANELSOPEN {
        WAIT 0.1.
    } ELSE {
        PRINT "Extending Solar Panels.".
        PANELS ON.
        WAIT 1.
    }
    // UNTIL CHARGED WAIT
    UNTIL SHIP:ELECTRICCHARGE > FULLCHARGE {
        Telemetry().
        WAIT 1.
    }
    IF PANELSOPEN {
        WAIT 0.1.
    } ELSE {
        PANELS OFF.
        PRINT "Retracting Solar Panels.".
        WAIT 5.
        PRINT "Panels Parked.".
    }
    LIGHTS ON.
    Telemetry().
    PRINT "Charge completed!".
}

DECLARE FUNCTION SCIENCE {
    SET POWER TO 0.
    SET wheelThrottle TO POWER.
    Telemetry().
//    SET mysensors TO list(
//        "sensorThermometer",
//        "sensorBarometer",
//        "sensorAccelerometer",
//        "sensorAtmosphere"
//    ).
    SET mysensors TO SHIP:PARTSNAMEDPATTERN("sensor").
    WAIT 1.
    Telemetry().
    PANELS ON.
    PRINT "Preparing Science!".
//    SET P TO SHIP:PARTSNAMED("mediumDishAntenna")[0].
//    SET A TO P:GETMODULE("ModuleRTAntenna").
//    A:DOEVENT("Activate").
//    A:SETIELD("target", "Mission Control").
    SET RADIODELAY TO ship:connection:delay + 1.
    until SHIP:ELECTRICCHARGE > FULLCHARGE * 0.95 {
        WAIT 1.
        Telemetry().
    }
    WAIT 1.
    // do science stuff
    FOR s IN mysensors {
//        PRINT s.
//        SET P TO SHIP:PARTSNAMED(s)[0].
//        SET M TO P:GETMODULE("ModuleScienceExperiment").
        SET M TO s:GETMODULE("ModuleScienceExperiment").
        PRINT "Trying Scinece for " + s:TITLE.
    // check connection and empty buffer
        Telemetry().
        if M:HASDATA {
            PRINT M:DATA[0]:DATAAMOUNT + " Mits of data stored from previous experiment.".
            M:TRANSMIT.
            SET TRANSMITTIME TO CEILING(RADIODELAY + M:DATA[0]:DATAAMOUNT / 2.85) * 1.1.
            PRINT "Transmit Time Estimated to " + ROUND(TRANSMITTIME,1) + " seconds".
            PANELS ON.
            UNTIL TRANSMITTIME < 0 {
                Telemetry().
                SET TRANSMITTIME TO TRANSMITTIME -1. 
                WAIT 1.
            }
            until SHIP:ELECTRICCHARGE > FULLCHARGE * 0.8 {
                Telemetry().
                WAIT 1.
            }
        }
        WAIT 1.
        Telemetry().
        M:DUMP.
        M:RESET.
        WAIT 1.
        Telemetry().
        M:DEPLOY.
        WAIT 1.
        Telemetry().
    // check connection and empty buffer
        if M:HASDATA {
            PRINT "Experiment yelded " + M:DATA[0]:DATAAMOUNT + " Mits of data to transmit.".
            M:TRANSMIT.
            SET TRANSMITTIME TO CEILING(RADIODELAY + M:DATA[0]:DATAAMOUNT / 2.85) * 1.1.
             // Slowest antenna transmits 2.86 Mits per second.
            PRINT "Transmit Time Estimated to " + ROUND(TRANSMITTIME,1) + " seconds".
            PANELS ON.
            UNTIL TRANSMITTIME < 0 {
                Telemetry().
                SET TRANSMITTIME TO TRANSMITTIME -1. 
                WAIT 1.
            }
            until SHIP:ELECTRICCHARGE > FULLCHARGE * 0.8 {
                Telemetry().
                WAIT 1.
            }
        }
        Telemetry().
    }
    PRINT "Science Completed *BEEP!*".
    Telemetry().
}

DECLARE FUNCTION PathObstructed {
    IF POWER > 0.9 AND groundSpeed < 0.3 {
        return true.
    }
    return false.
}

DECLARE FUNCTION DeTour {
    PRINT "Need to do a small detour".
    SET POWER TO POWER * -0.5.
    Telemetry().
    PRINT "OBSTRUCTION: Position LATLNG("+ROUND(SHIP:geoposition:lat, 4)+","+ROUND(SHIP:geoposition:lng, 4)+")".
//    LOG "OBSTRUCTION: Position LATLNG("+ROUND(SHIP:geoposition:lat, 4)+","+ROUND(SHIP:geoposition:lng, 4)+")".
    // make a WP 100m behind. (really needed?)
    // make a WP 200m to the right
    SET WP_DETOUR TO SHIP:BODY:GEOPOSITIONOF(SHIP:POSITION + 200 * SHIP:FACING:STARVECTOR). 
    SET WP_AFT TO SHIP:BODY:GEOPOSITIONOF(SHIP:POSITION + -50 * SHIP:FACING:FOREVECTOR). 
    // drive to these WPs
    DRIVE(WP_AFT).
    DRIVE(WP_DETOUR).
}

DECLARE FUNCTION DRIVE {
    DECLARE PARAMETER WP.    
    PANELS OFF.
    Telemetry().
    WAIT 1.
    Telemetry().
    UNTIL WP:DISTANCE < 20 {
        IF PathObstructed() {
            DeTour().
        }
        SET wheelSteering TO WP.
        IF WP:DISTANCE > 120 {
            IF groundSpeed > MAXSPEED * 0.90 { SET POWER TO POWER - 0.01.} // Near max speed
            IF groundSpeed > MAXSPEED * 1.05 AND POWER > 0 { SET POWER TO 0. } // Power cutof
            IF groundSpeed > MAXSPEED { SET POWER TO POWER - 0.01.} // at max speed
            IF groundSpeed < MAXSPEED * 0.80 { SET POWER TO POWER + 0.01.} // less than 80% speed
        } ELSE IF WP:DISTANCE < 120 AND groundSpeed > MAXSPEED * 0.9 {
            SET POWER TO POWER - 0.01.
        } ELSE IF WP:DISTANCE < 100 AND groundSpeed > MAXSPEED * 0.8 {
            SET POWER TO POWER - 0.01.
        } ELSE IF WP:DISTANCE < 80 AND groundSpeed > MAXSPEED * 0.7 {
            SET POWER TO POWER - 0.01.
        } ELSE IF WP:DISTANCE < 60 AND groundSpeed > MAXSPEED * 0.6 {
            SET POWER TO POWER - 0.01.
        } ELSE IF WP:DISTANCE < 40 AND groundSpeed > MAXSPEED * 0.5 { SET POWER TO POWER - 0.01. } // Arriving, slow down
        IF groundSpeed < MAXSPEED * 0.2 { SET POWER TO POWER + 0.01. }
        IF groundSpeed < 0.3 AND POWER < 0 { SET POWER TO 0. } // Going Backwords!
        IF WP:BEARING > 10 OR WP:BEARING < -10 { // sharp turn
            IF groundSpeed > MAXTURNSPEED * 0.90 { SET POWER TO POWER - 0.01.} // near max turn speed
            IF groundSpeed > MAXTURNSPEED { SET POWER TO 0. } // max turn speed
            IF groundSpeed > MAXTURNSPEED * 1.2 { // Fuck!
                BREAKS ON.
                SET POWER TO 0.
                LEGS ON.
                WAIT 3.
                }
            IF groundSpeed < MAXTURNSPEED * 0.85 { SET POWER TO POWER + 0.01. // low turn speed
                BREAKS OFF.
                // If Legs are on, preset power to match pitch and set legs off
                LEGS OFF.
                }
            WAIT 0.1.
        } ELSE {
            BREAKS OFF.
                // If Legs are on, preset power to match pitch and set legs off
            LEGS OFF.
        }
        IF groundSpeed > MAXSPEED * 1.2 {
            BREAKS ON. 
            LEGS ON. 
            SET POWER TO 0.
            WAIT 3.
        }
        IF POWER > 1 { SET POWER TO 1.}
        IF POWER < -1 { SET POWER TO -1.}
        SET wheelThrottle TO POWER.
        Telemetry().
        WPTelemetry(WP).
        IF SHIP:ELECTRICCHARGE < MINCHARGE { CHARGE(). }
        WAIT 0.1.
    }
    SET wheelThrottle TO 0.
    BREAKS ON.
    LEGS ON.
    WAIT 1.
    PRINT "Reached WP at " + ROUND(WP:LAT,4) + "/" + ROUND(WP:LNG,4) + ". *BEEP!*".
}

Telemetry().
//SCIENCE().
FOR P IN WP_LIST {
    DRIVE(P).
    // gather and transmit science data
    SCIENCE().
}

BREAKS ON.
LEGS ON.
PANELS ON.
SET wheelThrottle TO 0.
UNLOCK wheelThrottle.
UNLOCK wheelSteering.
Telemetry().
UNTIL SHIP:ELECTRICCHARGE > MAXCHARGE *0.9 {
    Telemetry().
    WAIT 1.
}
//SET SHIP:CONTROL:PILOTWHEELSTEER.
//SET SHIP:CONTROL:pilotwheelthrottle.
SET SHIP:CONTROL:NEUTRALIZE TO True.
WAIT 5.
PRINT "Script Releasing Control!".
PRINT "Returning ROVER " + SHIPNAME + " to MANUAL CONTROL!".