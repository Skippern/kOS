DECLARE FUNCTION arrivals {
    SET a TO "'eta':{".
    SET a TO a+"'ap':"+ETA:APOAPSIS+",".
    SET a TO a+"'pe':"+ETA:PERIAPSIS+",".
    IF (ETA:NEXTNODE < 2147483647) {
        SET a TO a+"'node':"+ETA:NEXTNODE+",".
    } ELSE {
        SET a TO a+"'node':-1,".
    }
    IF (ETA:TRANSITION < 2147483647) {
        SET a TO a+"'transition':"+ETA:TRANSITION+",".
    } ELSE {
        SET a TO a+"'transition':-1,".
    }
    SET a TO a+"},".
    return a.
}