RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/comms".

DECLARE FUNCTION telemetryComms {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    PRINT "NOT ACTIVE!" AT(0,LINENUM).
}
