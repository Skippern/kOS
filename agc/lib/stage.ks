DECLARE FUNCTION stageres {
    SET a TO "'stage':{".
    SET a TO a+"'stage':"+STAGE:NUMBER+",".
    SET a TO a+"'deltav':"+STAGE:DELTAV:CURRENT+",".
    SET a TO a+"'resource':{".
    IF (STAGE:ELECTRICCHARGE > 0) { SET a TO a+"'el':"+STAGE:ELECTRICCHARGE+",". }
    IF (STAGE:MONOPROPELLANT > 0) { SET a TO a+"'mp':"+STAGE:MONOPROPELLANT+",". }
    IF (STAGE:LIQUIDFUEL > 0) { SET a TO a+"'lf':"+STAGE:LIQUIDFUEL+",". }
    IF (STAGE:OXIDIZER > 0) { SET a TO a+"'ox':"+STAGE:OXIDIZER+",". }
    IF (STAGE:SOLIDFUEL > 0) { SET a TO a+"'sf':"+STAGE:SOLIDFUEL+",". }
    IF (STAGE:ABLATOR > 0) { SET a TO a+"'hs':"+STAGE:ABLATOR+",". }
    IF (STAGE:XENONGAS > 0) { SET a TO a+"'xe':"+STAGE:XENONGAS+",". }
    IF (STAGE:ORE > 0) { SET a TO a+"'fe':"+STAGE:ORE+",". }
    IF (STAGE:INTAKEAIR > 0) { SET a TO a+"'ar':"+STAGE:INTAKEAIR+",". }
    SET a TO a+"},".
    SET a TO a+"},".
    return a.
}