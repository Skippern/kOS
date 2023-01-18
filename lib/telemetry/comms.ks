RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/comms".

DECLARE FUNCTION telemetryComms {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    if (hasConnection) {
        PRINT "CONNECTED      " AT(0,LINENUM).
    } else {
        PRINT "NOT CONNECTED! " AT(0,LINENUM).
        walkConnection.
    }
}
