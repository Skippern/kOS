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
    print "Ready Sensors to gather new science.".
    SET mysensors TO list().
    Set partList to ship:parts.

    for thePart in partList {
        declare local moduleList to thePart:modules.
        from {local i is 0.} until i = moduleList:length step {set i to i+1.} do {
            set theModule to moduleList[i].
            if (theModule = "ModuleScienceExperiment") or (theModule = "DMModuleScienceAnimate") {
                mysensors:add(thePart).
            }
        }
    }

    // FOR x IN SHIP:PARTSNAMEDPATTERN("sensor") {
    //     mysensors:add(x).
    // }
    // FOR x IN SHIP:PARTSNAMED("GooExperiment") {
    //     mysensors:add(x).
    // }

    // SET mysensors TO SHIP:PARTSNAMEDPATTERN("sensor").
    FOR s IN mysensors {
        PRINT s.
        // PRINT s:NAME.
        PRINT "Gathering Science Data from " + s:TITLE.
        SET M TO s:GETMODULE("ModuleScienceExperiment").
        M:DEPLOY().
        WAIT 10.
        // WAIT UNTIL M:HASDATA.
        PRINT "Module Data Status: " + M:HASDATA.
        IF M:HASDATA {
            FOR sd IN M:DATA {
                PRINT "Data Title: " + sd:TITLE.
                PRINT sd.
                // PRINT "Science Value: " + sd:SCIENCEVALUE.
                // PRINT "Transmit Value: " + sd:TRANSMITVALUE.
                // PRINT "Data Amount: " + sd:DATAAMOUNT.
                // sd:TRANSMIT.
            }
            M:TRANSMIT().
            WAIT 10.
        }
        // M:RESET().

        // M:DUMP. // Dump any unstored data left in the sensor
        // WAIT 0.25.
        // M:RESET. // Reset sensor
        // WAIT 0.25.
        // M:DEPLOY. // Deploy sensor to read new data
        // Evaluate
        //      This should decide if data should be transfered to science lab, transmitted to kerbin, or stored for return
        // Transfer
        //      This should transfer data to science lab
        // Transmit
        //      This should transmit science back to Kerbin
        // Store
        //      This should store data for return, or manual transmision
    }
}

DECLARE FUNCTION transferScienceToLab {
    print "This function should evaluate stored science and transfer to lab data with local research value.".
}

DECLARE FUNCTION transmitScience {
    print "Preparing to transmit stored science.".
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
                SET TRANSMITTIME TO TRANSMITTIME -1. 
                WAIT 1.
            }
        }
    }
}

DECLARE FUNCTION transmitScienceLab {
    declare local ScienceLabModules to list().
    declare local partList to ship:parts.

    PRINT "Transmitting Available Science Research.".

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