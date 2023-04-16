RUN ONCE "0:lib/utils/std".

DECLARE FUNCTION sensors {
    SET a TO "'sensors':{".
    SET a TO a+"'T':"+TIME:seconds+",".
    SET a TO a+"'L':"+SHIP:SENSORS:LIGHT+",".
    IF (hasTermometer) { SET a TO a+"'K':"+SHIP:SENSORS:TEMP+",". }
    IF (hasBarometer) { SET a TO a+"'p':"+SHIP:SENSORS:PRES+",". }
    IF (hasAccelerometer) { SET a TO a+"'A':"+SHIP:SENSORS:ACC:MAG+",". }
    IF (hasGravometer) { SET a TO a+"'G':"+SHIP:SENSORS:GRAV:MAG+",". }
    SET a TO a+"'calculated':{".
        SET a TO a+"'A':"+getCalculatedAccelleration():MAG+",".
        SET a TO a+"'G':"+getLocalG()+",".
    SET a TO a+"},".
    SET a TO a+"},".
    return a.
}