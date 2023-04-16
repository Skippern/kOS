// Start by loading necessary libs
RUN ONCE "0:lib/utils/std".
RUN ONCE "0:lib/comms".

CLEARSCREEN.
SET blanks TO "                                                   ".


RUN ONCE "0:agc/lib/pos".
RUN ONCE "0:agc/lib/maneuver".
RUN ONCE "0:agc/lib/orbit".
RUN ONCE "0:agc/lib/craft".
RUN ONCE "0:agc/lib/eta".
RUN ONCE "0:agc/lib/stage".
RUN ONCE "0:agc/lib/resources".
RUN ONCE "0:agc/lib/thrust".
RUN ONCE "0:agc/lib/sensors".
RUN ONCE "0:agc/lib/eta".
RUN ONCE "0:agc/lib/target".

DECLARE FUNCTION mainLoop {
    // Main program loop
    // clearScreen.
    if (hasConnection()) {
        // We have connection, lets build a JSON
        SET Link TO LIST(connectedTo(), getKSCDelay()).

        PRINT "{'link':['"+Link[0]+"',"+Link[1]+"],"+craft()+orbitpos()+posn()+man()+arrivals()+stageres()+resources()+thrustdata()+sensors()+targ()+"}"+blanks AT(0,0).
    } else {
        walkConnection().
        PRINT "{'error':[1,]}"+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks+blanks AT(0,0).
    }
}

UNTIL False {
    mainLoop.
    WAIT 0.1.
}