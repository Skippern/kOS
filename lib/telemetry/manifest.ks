RUN ONCE "0:lib/utils/std".

DECLARE FUNCTION telemetryManifest {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    PRINT "Manifest for " + SHIP:TYPE + ": " + SHIPNAME + "                           " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT " = = = = = = = = = = CREW = = = = = = = = = =          " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "    NAME" AT(0,LINENUM).
    PRINT "GENDER" AT(25,LINENUM).
    PRINT "CLASS" AT(33,LINENUM).
    PRINT "LEVEL" AT(43,LINENUM).
    SET i TO 0.
    FOR C IN SHIP:CREW {
        SET LINENUM TO LINENUM + 1.
        SET i TO i + 1.
        SET j TO i.
        IF i < 10 { SET j TO " "+i. }
        PRINT j+") " + C:NAME AT(0, LINENUM).
        PRINT C:GENDER AT(25, LINENUM).
        PRINT C:TRAIT AT(33, LINENUM).
        IF C:TOURIST {
            PRINT " (T)" AT(43, LINENUM).
        } else {
            PRINT " ("+C:EXPERIENCE+")" AT(43, LINENUM).
        }
    }
}
