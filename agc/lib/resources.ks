DECLARE FUNCTION resources {
    SET a TO "'resource':{".
    IF (SHIP:ELECTRICCHARGE > 0) { SET a TO a+"'el':"+SHIP:ELECTRICCHARGE+",". }
    IF (SHIP:MONOPROPELLANT > 0) { SET a TO a+"'mp':"+SHIP:MONOPROPELLANT+",". }
    IF (SHIP:LIQUIDFUEL > 0) { SET a TO a+"'lf':"+SHIP:LIQUIDFUEL+",". }
    IF (SHIP:OXIDIZER > 0) { SET a TO a+"'ox':"+SHIP:OXIDIZER+",". }
    IF (SHIP:SOLIDFUEL > 0) { SET a TO a+"'sf':"+SHIP:SOLIDFUEL+",". }
    IF (SHIP:ABLATOR > 0) { SET a TO a+"'hs':"+SHIP:ABLATOR+",". }
    IF (SHIP:XENONGAS > 0) { SET a TO a+"'xe':"+SHIP:XENONGAS+",". }
    IF (SHIP:ORE > 0) { SET a TO a+"'fe':"+SHIP:ORE+",". }
    IF (SHIP:INTAKEAIR > 0) { SET a TO a+"'ar':"+SHIP:INTAKEAIR+",". }
    SET a TO a+"},".
    SET a TO "'capacity':{".
    // IF (SHIP:ELECTRICCHARGE:CAPACITY > 0) { SET a TO a+"'el':"+SHIP:ELECTRICCHARGE:CAPACITY+",". }
    // IF (SHIP:MONOPROPELLANT:CAPACITY > 0) { SET a TO a+"'mp':"+SHIP:MONOPROPELLANT:CAPACITY+",". }
    // IF (SHIP:LIQUIDFUEL:CAPACITY > 0) { SET a TO a+"'lf':"+SHIP:LIQUIDFUEL:CAPACITY+",". }
    // IF (SHIP:OXIDIZER:CAPACITY > 0) { SET a TO a+"'ox':"+SHIP:OXIDIZER:CAPACITY+",". }
    // IF (SHIP:SOLIDFUEL:CAPACITY > 0) { SET a TO a+"'sf':"+SHIP:SOLIDFUEL:CAPACITY+",". }
    // IF (SHIP:ABLATOR:CAPACITY > 0) { SET a TO a+"'hs':"+SHIP:ABLATOR:CAPACITY+",". }
    // IF (SHIP:XENONGAS:CAPACITY > 0) { SET a TO a+"'xe':"+SHIP:XENONGAS:CAPACITY+",". }
    // IF (SHIP:ORE:CAPACITY > 0) { SET a TO a+"'fe':"+SHIP:ORE:CAPACITY+",". }
    // IF (SHIP:INTAKEAIR:CAPACITY > 0) { SET a TO a+"'ar':"+SHIP:INTAKEAIR:CAPACITY+",". }
    SET a TO a+"},".
    return a.
}