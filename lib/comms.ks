// lib/comms
//
// Different functions to handle communication
//
// addons:available("RT") returns True if RemoteTech is active, else False
//

SET hasRT TO addons:available("RT").

SET myantennas TO SHIP:PARTSNAMEDPATTERN("antenna").
IF hasRT {
    SET myRT TO addons:RT.
} ELSE {
    SET myRT TO False.
}
// Mits/s
SET AntennaTransmissionSpeed TO lexicon(
    // STOCK
    "longAntenna", 3.33, // Communotron 16
    "SurfAntenna", 3.33, // Communotron 16-S
    "mediumDishAntenna", 5.71, // Communotron DTS-M1
    "HighGainAntenna", 20, // Communotron HG-55
// Communotron 88-88    20Mits/s
    "HighGainAntenna5.v2", 5.71, // HG-5 High Gain Antenna
    "RelayAntenna5", 2.86, // RA-2 Relay Antenna
    "RelayAntenna50", 5.71, // RA-15 Relay Antenna
    "RelayAntenna100", 11.43, // RA-100 Relay Antenna
    // RemoteTech
    "RTShortAntenna1", 200, // Reflectron DP-10
    "RTLonAntenna2", 200, //Communotron 32
    // Default value, lowest transmit speed in all modes
    "default", 2.86
).
// charge/Mit
SET AntennaEnergyConsume TO lexicon(
    // STOCK
    "longAntenna", 6, // Communotron 16
    "SurfAntenna", 6, // Communotron 16-S
    "mediumDishAntenna", 6, // Communotron DTS-M1
    "HighGainAntenna", 6.67, // Communotron HG-55
// Communotron 88-88       10 el/Mit
    "HighGainAntenna5.v2", 9, // HG-5 High Gain Antenna
    "RelayAntenna5", 24, // RA-2 Relay Antenna
    "RelayAntenna50", 12, // RA-15 Relay Antenna
    "RelayAntenna100", 6, // RA-100 Relay Antenna
    // Default value, highest energy cost in all modes
    "RTShortAntenna1", 7.5, // Reflectron DP-10
    "RTLonAntenna2", 7.5, //Communotron 32
    "default", 24
).
// Slowest Mit/s / s
DECLARE FUNCTION getTransmitSpeed { 
    SET R TO AntennaTransmissionSpeed["default"].
    FOR a IN myantennas {
        IF AntennaTransmissionSpeed:HASKEY(a:NAME) {
            SET i TO AntennaTransmissionSpeed[a:NAME].
            IF i > R { SET R TO i. }
        }
    }
    RETURN R.
}
// Highest charge / Mit
DECLARE FUNCTION getTransmitEnergy {
    SET R TO AntennaEnergyConsume["default"].
    FOR a in myantennas {
        IF AntennaEnergyConsume:HASKEY(a:NAME) {
            SET i TO AntennaEnergyConsume[a:NAME].
            IF i > R { SET R TO i. }
        }
    }
    RETURN R.
}
// Seconds delay to KSC
DECLARE FUNCTION getKSCDelay {
    IF hasRT {
//        RETURN myRT:KSCDELAY(SHIP). // Shortest route to KSC
        RETURN myRT:DELAY(SHIP). // Shortest route if another local command post available
    } ELSE { RETURN HOMECONNECTION:delay. }
}

DECLARE FUNCTION hasConnection {
    IF hasRT {
        FOR a IN myantennas {
            IF myRT:ANTENNAHASCONNECTION(a) {
                RETURN True.
            }
//            RETURN False.
        }
        RETURN myRT:HASCONNECTION(SHIP).
    }
    RETURN HOMECONNECTION:ISCONNECTED.
}
DECLARE FUNCTION connectedTo {
    IF hasRT {
        RETURN myRT:GROUNDSTATIONS()[0].
    }
    RETURN HOMECONNECTION:DESTINATION.
}
