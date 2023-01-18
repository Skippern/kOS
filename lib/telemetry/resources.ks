SET MAXCHARGE TO MAX(ROUND(SHIP:ELECTRICCHARGE,0),0.001).
SET MAXLF TO MAX(ROUND(SHIP:LIQUIDFUEL,0),0.001).
SET MAXOX TO MAX(ROUND(SHIP:OXIDIZER,0),0.001).
SET MAXMP TO MAX(ROUND(SHIP:MONOPROPELLANT,0),0.001).
SET MAXSF TO MAX(ROUND(SHIP:SOLIDFUEL,0),0.001).
SET MAXABLA TO MAX(ROUND(SHIP:ABLATOR,0),0.001).
SET XENOMAX TO MAX(ROUND(SHIP:XENONGAS,0),0.001).
SET AIRMAX TO MAX(ROUND(SHIP:INTAKEAIR,0),0.001).
SET MAXORE TO MAX(ROUND(SHIP:ORE,0),0.001).

RUN ONCE "0:lib/utils/std".

DECLARE FUNCTION telemetryResources {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    PRINT "Electric Charge: " + ROUND(SHIP:ELECTRICCHARGE, 2) + " / " + ROUND((SHIP:ELECTRICCHARGE/MAXCHARGE)*100,1) + "%      " AT(0,LINENUM).
    IF ROUND(SHIP:ELECTRICCHARGE/MAXCHARGE) < 0.3 {
        IF SHIP:ALTITUDE > SAFE_ALTITUDES[SHIP:BODY:NAME] {
            PANELS ON.
        }
    }
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
}
