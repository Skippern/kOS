RUN ONCE "0:lib/utils/std".

// GLOBAL TimeToTransmit TO 0.

DECLARE FUNCTION telemetryScience {
    PARAMETER FirstLine TO 0.
    SET LINENUM TO FirstLine.

    PRINT "NOT ACTIVE!" AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    print "Next transmission at: " + printTime(TimeToTransmit:SECONDS, 0) + "                                         " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    print "Time now: " + printTime(TIME:SECONDS, 0) + "                                                               " AT(0,LINENUM).
    SET ttg TO TimeToTransmit:seconds - TIME:seconds.
    SET LINENUM TO LINENUM + 1.
    PRINT "Time to transmision: " + printTime( ttg, 1 ) + "                                        " AT(0,LINENUM).
    SET LINENUM TO LINENUM + 1.
    PRINT "                                                                   " AT(0,LINENUM).
}
