RUN ONCE "0:lib/utils/std".

DECLARE FUNCTION telemetrySurface {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    PRINT "NOT ACTIVE!" AT(0,LINENUM).
}
