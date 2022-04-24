// To automatically check for science, transfer data to science lab, and transmit data

DECLARE GLOBAL ScienceInterval TO 60.
DECLARE GLOBAL IntevalFrame TO 0.

DECLARE FUNCTION autoRunScience {
    SET IntevalFrame TO IntevalFrame + 1.
    IF IntevalFrame > ScienceInterval {
        SET IntevalFrame TO 0.
        transmitScienceLab().
        // getScience().
        // transmitScience().
    }
}

DECLARE FUNCTION getScience {
    SET mysensors TO SHIP:PARTSNAMEDPATTERN("sensor").
    FOR s IN mysensors {
//        PRINT s:NAME.
        PRINT "Gathering Science Data from " + s:TITLE.
        SET M TO s:GETMODULE("ModuleScienceExperiment").
        M:DUMP.
        M:RESET.
        M:DEPLOY.
    }
}

DECLARE FUNCTION transferScienceToLab {
    print "This function should evaluate store science and transfer to lab data with local research value".
}

DECLARE FUNCTION transmitScience {
    SET mysensors TO SHIP:PARTSNAMEDPATTERN("sensor").
    FOR s IN mysensors {
        PRINT s:NAME.
        SET M TO s:GETMODULE("ModuleScienceExperiment").
        if M:HASDATA {
            WAIT 0.5.
            PRINT "Experiment yelded " + M:DATA[0]:DATAAMOUNT + " Mits of data to transmit.".
            M:TRANSMIT.
            SET TRANSMITTIME TO CEILING(RADIODELAY + M:DATA[0]:DATAAMOUNT / 2.85) * 1.1.
            // Slowest antenna transmits 2.86 Mits per second.
            PRINT "Transmit Time Estimated to " + ROUND(TRANSMITTIME,1) + " seconds".
            PANELS ON.
            UNTIL TRANSMITTIME < 0 {
                Telemetry().
                SET TRANSMITTIME TO TRANSMITTIME -1. 
                WAIT 1.
            }
        }
    }
}

DECLARE FUNCTION transmitScienceLab {
    declare local ScienceLabModules to list().
    declare local partList to ship:parts.

    // PRINT "Transmitting Available Science Research".

    for thePart in partList {
        declare local moduleList to thePart:modules.
        from {local i is 0.} until i = moduleList:length step {set i to i+1.} do {
            set theModule to moduleList[i].
            if (theModule = "ModuleScienceLab") {
                ScienceLabModules:add(thePart:getModuleByIndex(i)). // add it to the list
                thePart:getModuleByIndex(i):DOEVENT("Transmit Science").
            }
        }
    }
}

// transmitScienceLab().
// getScience().
// transmitScience().