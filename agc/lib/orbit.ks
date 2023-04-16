DECLARE FUNCTION orbitpos {
    SET a TO "'orbit':{".
    SET a TO a+"'ap':"+SHIP:APOAPSIS+",".
    SET a TO a+"'pe':"+SHIP:PERIAPSIS+",".
    SET a TO a+"'v':"+SHIP:ORBIT:VELOCITY:ORBIT:MAG+",".
    SET a TO a+"'i':"+SHIP:ORBIT:INCLINATION+",".
    SET a TO a+"'e':"+SHIP:ORBIT:ECCENTRICITY+",".
    SET a TO a+"'☊':"+SHIP:ORBIT:LAN+",".
    SET a TO a+"'ω':"+SHIP:ORBIT:argumentofperiapsis+",".
    SET a TO a+"'♈︎':"+BODY:ROTATIONANGLE+",".
    SET a TO a+"'θ':"+SHIP:ORBIT:trueanomaly+",".
    IF (SHIP:apoapsis > 0) { SET a TO a+"'t':"+SHIP:ORBIT:period+",". } ELSE { SET a TO a+"'t':-1,". }
    SET a TO a+"},".
    return a.

}