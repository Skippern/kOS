// lib/AGC.ks
//
// A very simple script to make an AGC visualization on top of screen.

// Variables for AGC DSKY readouts
DECLARE GLOBAL AGCprogram IS 0.
DECLARE GLOBAL AGCverb IS 0.
DECLARE GLOBAL AGCnoun IS 0.
DECLARE GLOBAL AGC_ReadOut1 IS 0.
DECLARE GLOBAL AGC_ReadOut2 IS 0.
DECLARE GLOBAL AGC_ReadOut3 IS 0.

DECLARE AGCProgramList TO lexicon(
    00, "CMC IDLING",
    01, "PRELAUNCH OR SERVICE-INITIALIZATION",
    02, "PRELAUNCH OR SERVICE-GYRO COMPASSING", 
    03, "PRELAUNCH OR SERVICE-OPTICAL VERIFICATION OF GYRO COMPASSING", 
    06, "GNCS POWER DOWN", 
    07, "SYSTEMS TEST",
        // BOOST 
    11, "EARTH ORBIT INSERTION MONITOR (EOI)",
    15, "TLI INITIATE/CUTOFF",
        // COAST
    20, "UNIVERSAL TRACKING",
    21, "GROUND TRACK DETERMINATION",
    22, "ORBITAL NAVIGATION",
    23, "CIS LUNAR MIDCOURSE NAVIGATION",
    24, "RATE-AIMED OPTICS (LANDMARK TRACKING)",
    27, "CMC UPDATE",
    29, "TIME-TO-LONGITUDE",
        // PRE-THRUST TARGETING
    30, "EXTERNAL DELTA V",
    31, "HEIGHT ADJUSTMENT MANEUVER (HAM)",
    32, "CO-ELLIPTIC SQUENCE INITIATION (CSI)",
    33, "CONSTANT DELTA ALTITUDE (CDH)",
    34, "TRANSFER PHASE INITIATION (TPI)",
    35, "TRANSFER PHASE (TPF)",
    36, "PLANGE CHANGE (PCM)",
    37, "RETURN TO EARTH (RTE)",
        // THRUSTING
    40, "SPS",
    41, "RCS",
    47, "THRUST MONITOR",
        // ALIGNMENT
    51, "IMU ORIENTATION DETERMINATION",
    52, "IMU REALIGN",
    53, "BACK-UP IMU ORIENTATION DETERMINATION",
    54, "BACK-UP IMU REALIGN",
        // ENTRY
    61, "ENTRY - PREPARATION",
    62, "ENTRY-CM/SM SEPARATION AND PRE-ENTRY MANEUVER",
    63, "ENTRY INITIALIZATION",
    64, "ENTRY-POST 0.05G",
    65, "ENTRY-UP CONTROL",
    66, "ENTRY-BALLISTIC",
    67, "ENTRY-FINAL PHASE",
        // PRE-THRUSTING OTHER VEHICLE
    72, "LM CO-ELLIPTIC SEQUENCE INITIATION (CSI) TARGET",
    73, "LM CONSTANT DELTA ALTITUDE (CDH TARGETING",
    74, "LM TRANSFER PHASE INITIATION (TPI) TARGETING",
    75, "LM TRANSFER PHASE (MIDCOURSE) TARGETING",
    76, "LM TARGET DELTA V",
    77, "CSM TARGET DELTA V",
    79, "RENDEZVOUS FINAL PHASE"
).
DECLARE AGCVerbList TO lexicon(
        00, "NOT IN USE",
        01, "DISPLAY OCTAL COMP 1 IN R1", 
        02, "DISPLAY OCTAL COMP 2 IN R1", 
        03, "DISPLAY OCTAL COMP 3 IN R1", 
        04, "DISPLAY OCTAL COMP 1, 2 IN R1, R2", 
        05, "DISPLAY OCTAL COMP 1, 2, 3 IN R1, R2, R3", 
        06, "DISPLAY DECIMAL IN R1 OR R1, R2 OR R1, R2, R3", 
        07, "DISPLAY DOUBLE PREC DECIMAL IN R1, R2 (TEST ONLY)", 
        08, "", 
        09, "", 
        10, "", 
        11, "MONITOR OCTAL COMP 1 IN R1", 
        12, "MONITOR OCTAL COMP 2 IN R1", 
        13, "MONITOR OCTAL COMP 3 IN R1", 
        14, "MONITOR OCTAL COMP 1, 2 IN R1, R2", 
        15, "MONITOR OCTAL COMP 1, 2, 3 IN R1, R2, R3", 
        16, "MONITOR DECIMAL IN R1 OR R1, R2 OR R1, R2, R3", 
        17, "MONITOR DOUBLE PREC DECIMAL IN R1, R2 (TEST ONLY)", 
        18, "", 
        19, "", 
        20, "", 
        21, "LOAD COMPONENT 1 INTO R1", 
        22, "LOAD COMPONENT 2 INTO R2", 
        23, "LOAD COMPONENT 3 INTO R3", 
        24, "LOAD COMPONENT 1, 2 INTO R1, R2", 
        25, "LOAD COMPONENT 1, 2, 3 INTO R1, R2, R3", 
        26, "", 
        27, "DISPLAYFIXED MEMORY", 
        28, "", 
        29, "", 
        30, "REQUEST EXECUTIVE", 
        31, "REQUEST WAITLIST", 
        32, "RECYCLE PROGRAM", 
        33, "PROCEED WITHOUT DSKY INPUTS", 
        34, "TERMINATE FUNCTION", 
        35, "TEST LIGHTS", 
        36, "REQUEST FRESH START", 
        37, "CHANGE PROGRAM (MAJOR MODE)", 
        38, "", 
        39, "", 
        40, "ZERO CDU'S", 
        41, "COARSE ALIGN CDU'S", 
        42, "FINE ALIGN IMU", 
        43, "LOAD IMU ATT ERROR METERS", 
        44, "SET SURFACE FLAG", 
        45, "RESET SURFACE FLAG", 
        46, "ESTABLISH G & C CONTROL", 
        47, "MOVE LM STATE VECTOR INTO CM STATE VECTOR", 
        48, "REQUEST DAP DATA LOAD (RCS)", 
        49, "REQUEST CREW DEFINED MANEUVER (RCS)", 
        50, "PLEASE PERFORM", 
        51, "PLEASE MARK", 
        52, "MARK ON OFFSET LANDING SITE", 
        53, "PLEASE PERFORM ALTERNATE LOG MARK", 
        54, "REQUEST RENDEZVOUS BACKUP SIGHTING MARK ROUTINE (R23)", 
        55, "INCREMENT AGC TIME (DECIMAL)", 
        56, "TERMINATE TRACKING (P20)", 
        57, "DISPLAY UPDATE STATE OF FULTKFLG", 
        58, "ENABLE AUTO MANEUVER IN P20", 
        59, "PLEASE CALIBRATE", 
        60, "SET ASTRONAUT TOTAL ATTITUDE (N17) TO PRESENT ATTITUDE", 
        61, "DISPLAY DAP ATTITUDE ERROR", 
        62, "DISPLAY TOTAL ATTITUDE ERROR WRT N23", 
        63, "DISPLAY TOTAL ASTRONAUT ATTITUDE ERROR WRT N17", 
        64, "REQUEST S-BAND ANTENNA ROUTINE", 
        65, "OPTICAL VERIFICATION OF PRELAUNCH ALIGNMENT", 
        66, "VEHICLE ATTACHED, MOVE THIS VEHICLE STATE VECTOR TO OTHER VEHICLE STATE VECTOR", 
        67, "DISPLAY W MATRIX", 
        68, "", 
        69, "CAUSE RESTART", 
        70, "UPDATE LIFTOFF TIME", 
        71, "UNIVERSAL UPDATE - BLOCK ADR", 
        72, "UNIVERSAL UPDATE - SINGLE ADR", 
        73, "UPDATE AGC TIME (OCTAL)", 
        74, "INITIALIZE ERASABLE DUMP VIA DOWNLINK", 
        75, "BACKUP LIFTOFF", 
        76, "", 
        77, "", 
        78, "UPDATE PRELAUNCH AZIMUTH", 
        79, "", 
        80, "UPDATE LM STATE VECTOR", 
        81, "UPDATE CSM STATE VECTOR", 
        82, "REQUEST ORBITAL PARAMETER DISPLAY (R30)", 
        83, "REQUEST RENDEZVOUS PARAMETER DISPLAY (R31)", 
        84, "", 
        85, "REQUEST RENDEZVOUS PARAMETER DISPLAY NO. 2 (R34)", 
        86, "REJECT RENDEZVOUS BACKUP SIGHTING MARK", 
        87, "SET VHF RANGE FLAG", 
        88, "RESET VHF RANGE FLAG", 
        89, "REQUEST RENDEZVOUS FINAL ATTITUDE (R65)", 
        90, "REQUEST RENDEZVOUS OUT OF PLANE DISPLAY (R36)", 
        91, "DISPLAY BANK SUM", 
        92, "OPERATE IMU PERFORMANCE TEST (P07)", 
        93, "ENABLE W MATRIX INITIALIZATION", 
        94, "PERFORM CISLUNAR ATTITUDE MANEUVER (P23)", 
        95, "", 
        96, "TERMINATE INTEGRATION AND OO TO P09", 
        97, "PERFORM ENGINE FAIL PROCEDURE", 
        98, "", 
        99, "PLEASE ENABLE ENGINE"
).


DECLARE GLOBAL FUNCTION setAGCprogram {
    DECLARE PARAMETER arg.
    IF arg < 0 OR arg > 99 { RETURN False. }
    SET AGCprogram TO arg.
    RETURN True.
}
DECLARE FUNCTION setAGCverb {
    DECLARE PARAMETER arg.
    IF arg < 0 OR arg > 99 { RETURN False. }
    SET AGCverb TO arg.
    RETURN True.
}
DECLARE FUNCTION setAGCnoun {
    DECLARE PARAMETER arg.
    IF arg < 0 OR arg > 99 { RETURN False. }
    SET AGCnoun TO arg.
    RETURN True.
}
DECLARE FUNCTION setAGCr1 {
    DECLARE PARAMETER arg.
    DECLARE PARAMETER sign IS True.
    IF arg < 0 OR arg > 99999 { RETURN False. }
    IF sign {
        SET AGC_ReadOut1 TO ABS(arg).
    } ELSE {
        SET AGC_ReadOut1 TO ABS(arg) * -1.
    }
    RETURN True.
}
DECLARE FUNCTION setAGCr2{
    DECLARE PARAMETER arg.
    DECLARE PARAMETER sign IS True.
    IF arg < 0 OR arg > 99999 { RETURN False. }
    IF sign {
        SET AGC_ReadOut2 TO ABS(arg).
    } ELSE {
        SET AGC_ReadOut2 TO ABS(arg) * -1.
    }
    RETURN True.
}
DECLARE FUNCTION setAGCr3 {
    DECLARE PARAMETER arg.
    DECLARE PARAMETER sign IS True.
    IF arg < 0 OR arg > 99999 { RETURN False. }
    IF sign {
        SET AGC_ReadOut3 TO ABS(arg).
    } ELSE {
        SET AGC_ReadOut3 TO ABS(arg) * -1.
    }
    RETURN True.
}

DECLARE FUNCTION getAGCReadOut{
    DECLARE PARAMETER bank IS 1.
    IF bank = 1 {
        RETURN AGC_ReadOut1.
    } ELSE IF bank = 2 {
        RETURN AGC_ReadOut2.
    } ELSE IF bank = 3 {
        RETURN AGC_ReadOut3.
    }
    RETURN False.
}

DECLARE FUNCTION getAGCprogram {
    DECLARE PARAMETER verbose IS False.
    IF verbose {
        IF AGCProgramList:haskey(AGCprogram) {
            RETURN AGCProgramList[AGCprogram].
        } ELSE {
            RETURN "UNDEFINED".
        }
    }
    RETURN AGCprogram.
}
DECLARE FUNCTION getAGCverb {
    DECLARE PARAMETER verbose IS False.
    IF verbose {
        IF AGCVerbList:haskey(AGCverb) {
            RETURN AGCVerbList[AGCverb].
        } ELSE {
            RETURN "UNDEFINED".
        }
    }
    RETURN AGCverb.
}
DECLARE FUNCTION getAGCnoun {
    DECLARE PARAMETER verbose IS False.
    IF verbose {
    //     SET i TO AGCverb.
    //     IF i = 00 { RETURN "NOT IN USE".
    //     } ELSE IF i = 01 { RETURN "SPECIFY MACHINE ADDRESS (FRACTIONAL)". // 3 COMP // .XXXXX FOR EACH
    //     } ELSE IF i = 02 { RETURN "SPECIFY MACHINE ADDRESS (WHOLE)". // 3 COMP // XXXXXX. FOR EACH
    //     } ELSE IF i = 03 { RETURN "SPECIFY MACHINE ADDRESS (DEGREES)". // 3 COMP // XXX.XX DEG FOR EACH
    //     } ELSE IF i = 04 { RETURN "". 
    //     } ELSE IF i = 05 { RETURN "ANGULAR ERROR/DIFFERENCE". // 1 COMP // XXX.XX DEG
    //     } ELSE IF i = 06 { RETURN "OPTION CODE". // 1 COMP // OCTAL ONLY FOR EACH 
    //     //LOADING NOUN 07 WILL SET OR RESET SELECTED BITS IN ANY ERASABLE LOCATION
    //     } ELSE IF i = 07 { RETURN "ECADR OF WORD TO BE MODIFIED". // 3 COMP // OCTAL ONLY FOR EACH
    //                                                             // ONES FOR BITS TO BE MODIFIED
    //                                                             // 1 TO SET OR 0 TO RESET SELECTED BITS 
    //     } ELSE IF i = 08 { RETURN "ALARM DATA". // 3 COMP // OCTAL ONLY FOR EACH 
    //     } ELSE IF i = 09 { RETURN "ALARM CODES". 
    //     } ELSE IF i = 10 { RETURN "CHANNEL TO BE SPECIFIED". // 1 COMP // OCTAL ONLY 
    //     } ELSE IF i = 11 { RETURN "TIG OF CSI". // 3 COMP // 00XXX. HRS
    //                                                       // 000XX. MIN
    //                                                       // 0XX.XX SEC
    //     } ELSE IF i = 12 { RETURN "OPTION CODE". // 2 COMP // OCTAL ONLY FOR EACH (USED BY EXTENDED VERBS ONLY) 
    //     } ELSE IF i = 13 { RETURN "TIG OF CDH". // 3 COMP // 00XXX. HRS
    //                                                       // 000XX. MIN
    //                                                       // 0XX.XX SEC 
    //     } ELSE IF i = 14 { RETURN "INERTIAL VEL MAG AT TLI CUTOFF". // 1 COMP // XXXXX. FT/SEC 
    //     } ELSE IF i = 15 { RETURN "INCREMENT MACHINE ADDRESS". // 1 COMP // OCTAL ONLY
    //     } ELSE IF i = 16 { RETURN "". 


    //     //END
    //     } ELSE RETURN "NOT DEFINED".
    }
    RETURN AGCnoun.
}