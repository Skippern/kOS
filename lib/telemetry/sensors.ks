RUN ONCE "0:lib/utils/std".

DECLARE FUNCTION telemetrySensors {
    PARAMETER FirstLine TO 0.

    SET LINENUM TO FirstLine.
    PRINT "Light Exposure: " + ROUND(SHIP:SENSORS:LIGHT * 100,3) + " klx           " AT(0,LINENUM).
    // Was checking up, since the KSP Wiki say SHIP:SENSORS:LIGHT is 1 at Kerbin Orbit,
    // and Illimunence (light exposure per square meter) in direct sunlight is 100 klx, 
    // than sensor * 100 should give a somewhat valid result in klx (1 lx = 1 lm/m2)
    // some numbers:
    // Direct sunlight: 32 - 100 klx
    // Normal Daylight: 10 - 25 klx
    // Overcast day: 1 klx
    // Fullmoon: 0.05 - 0.3 lx
    // Moonless clear night: 0.002 lx
    // Moonless overcast: 0.0001 lx
    SET LINENUM TO LINENUM + 1.
    IF hasTermometer {
        PRINT "Temp: " + ROUND(SHIP:SENSORS:TEMP,2) + "K / "+ROUND(SHIP:SENSORS:TEMP - 273.15, 2) +"°C / "+ ROUND(SHIP:SENSORS:TEMP * (9/5) - 459.67, 2) +"°F            " AT(0,LINENUM).   // ℉   ℃
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
    SET LINENUM TO LINENUM + 1.
    IF hasAccelerometer {
        PRINT "Acceleration: " + ROUND(SHIP:SENSORS:ACC:MAG / kerbinSurfaceG,2) + "G / "+ROUND(SHIP:SENSORS:ACC:MAG,1)+"m/s²                  " AT(0,LINENUM).
    } ELSE {
        PRINT "Acceleration: " + ROUND( getCalculatedAccelleration():MAG / kerbinSurfaceG,2) + "G (calculated)            " AT(0,LINENUM).
    }
    SET LINENUM TO LINENUM + 1.
    IF hasGravometer {
        PRINT "Gravity: "+ ROUND(SHIP:SENSORS:GRAV:MAG,4) +"m/s²                        " AT(0,LINENUM).
    } ELSE {
        PRINT "Gravity: "+ ROUND(getLocalG(), 4) +"m/s² (calculated)                  " AT(0,LINENUM).
    }

}
