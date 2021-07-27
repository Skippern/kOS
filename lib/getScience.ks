// lib/getScience.ks
//
// Run through all possible science moduls, retrieve science.
// Check for connection to KSC
// Transmit data that have value as transmitted
// Save data that have no value if transmitted (in case recovery)
//
// If there are saved data in a science modul, when called,
// try transmiting data or move it to a different location (i.e.,
// command module)

KUNIVERSE:timewarp:cancelwarp().

SET mysensors TO SHIP:PARTSNAMEDPATTERN("sensor").
PRINT "Preparing Science!".
SET RADIODELAY TO ship:connection:delay + 1.

FOR s IN mysensors {
    SET M TO s:GETMODULE("ModuleScienceExperiment").
    PRINT "Gathering Science Data from " + s:TITLE.
// check connection and empty buffer
    if M:HASDATA {
        PRINT M:DATA[0]:DATAAMOUNT + " Mits of data stored from previous experiment.".
        M:TRANSMIT.
        SET TRANSMITTIME TO CEILING(RADIODELAY + M:DATA[0]:DATAAMOUNT / 2.85) * 1.1.
        PRINT "Transmit Time Estimated to " + ROUND(TRANSMITTIME,1) + " seconds".
        UNTIL TRANSMITTIME < 0 {
            SET TRANSMITTIME TO TRANSMITTIME -1. 
            WAIT 1.
        }
    }
    WAIT 1.
    M:DUMP.
    M:RESET.
    WAIT 1.
    M:DEPLOY.
    WAIT 1.
    if M:HASDATA {
        PRINT "Experiment yelded " + M:DATA[0]:DATAAMOUNT + " Mits of data to transmit.".
        M:TRANSMIT.
        SET TRANSMITTIME TO CEILING(RADIODELAY + M:DATA[0]:DATAAMOUNT / 2.85) * 1.1.
        // Slowest antenna transmits 2.86 Mits per second.
        PRINT "Transmit Time Estimated to " + ROUND(TRANSMITTIME,1) + " seconds".
        UNTIL TRANSMITTIME < 0 {
            SET TRANSMITTIME TO TRANSMITTIME -1. 
            WAIT 1.
        }
    }
}