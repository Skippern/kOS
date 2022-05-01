// lib/comms
//
// Different functions to handle communication
//
// addons:available("RT") returns True if RemoteTech is active, else False
//
SET myantennas TO SHIP:PARTSNAMEDPATTERN("antenna").
SET hasRT TO addons:available("RT").
IF hasRT {
    SET myRT TO addons:RT.
} ELSE {
    SET myRT TO False.
}
// Mits/s
SET AntennaTransmissionSpeed TO lexicon(
    // STOCK
    "longAntenna",           3.33, // Communotron 16
    "SurfAntenna",           3.33, // Communotron 16-S
    "mediumDishAntenna",     5.71, // Communotron DTS-M1
    "HighGainAntenna",      20, // Communotron HG-55
    "commDish",             20, // Communotron 88-88    20Mits/s
    "HighGainAntenna5.v2",   5.71, // HG-5 High Gain Antenna
    "RelayAntenna5",         2.86, // RA-2 Relay Antenna
    "RelayAntenna50",        5.71, // RA-15 Relay Antenna
    "RelayAntenna100",      11.43, // RA-100 Relay Antenna
    // RemoteTech
    "RTShortAntenna1",       7.5, // Reflectron DP-10
    "RTLongAntenna2",        7.5, //Communotron 32
    "RTShortDish2",          7.5, // Reflectron KR-7
    "RTShortDish1",          7.5, // Reflectron SS-5
    "RTLongDish2",           7.5, // Reflectron KR-14
    "RTLongDish1",           7.5, // Reflectron LL-5
    "RTLongAntenna3",        7.5, // CommTech EXP-VR-2T
    "RTGigaDish2",           7.5, // CommTech-1
    "RTGigaDish1",           7.5, // Reflectron GX-128
    // Antennas mod
    "helixAntenna",          7.5, // H1X Helical
    "yagiActual",            7.5, // YA6 Yagi
    "vhfBlade",              7.5, // V17-7 Scimitar
    "quadHelix",             7.5, // Q4-4 Quad Helix
    "yagiAntenna",           7.5, // LA-7 Log Periodic
    "hu6s125",               7.5, // HU6s-125 Twin Loop

    // Default value, lowest transmit speed in all modes
    "default",               2.86
).
// charge/Mit
SET AntennaEnergyConsumePerMit TO lexicon(
    // STOCK
    "longAntenna",          6, // Communotron 16
    "SurfAntenna",          6, // Communotron 16-S
    "mediumDishAntenna",    6, // Communotron DTS-M1
    "HighGainAntenna",      6.67, // Communotron HG-55
    "commDish",            10, // Communotron 88-88
    "HighGainAntenna5.v2",  9, // HG-5 High Gain Antenna
    "RelayAntenna5",       24, // RA-2 Relay Antenna
    "RelayAntenna50",      12, // RA-15 Relay Antenna
    "RelayAntenna100",      6, // RA-100 Relay Antenna
    // RemoteTech
    "RTShortAntenna1",      7.5, // Reflectron DP-10
    "RTLongAntenna2",       7.5, //Communotron 32
    "RTShortDish2",         7.5, // Reflectron KR-7
    "RTShortDish1",         7.5, // Reflectron SS-5
    "RTLongDish2",          7.5, // Reflectron KR-14
    "RTLongDish1",          7.5, // Reflectron LL-5
    "RTLongAntenna3",       7.5, // CommTech EXP-VR-2T
    "RTGigaDish2",          7.5, // CommTech-1
    "RTGigaDish1",          7.5, // Reflectron GX-128
    // Antennas mod
    "helixAntenna",         7.5, // H1X Helical
    "yagiActual",           7.5, // YA6 Yagi
    "vhfBlade",             7.5, // V17-7 Scimitar
    "quadHelix",            7.5, // Q4-4 Quad Helix
    "yagiAntenna",          7.5, // LA-7 Log Periodic
    "hu6s125",              7.5, // HU6s-125 Twin Loop

    // Default value, highest energy cost in all modes
    "default",             24
).
// Range in m
SET AntennaRange TO lexicon(
    // STOCK
    "longAntenna",          2500000, // Communotron 16
    "SurfAntenna",          1500000, // Communotron 16-S
    "mediumDishAntenna",   50000000, // Communotron DTS-M1
    "HighGainAntenna",  25000000000, // Communotron HG-55
    "commDish",         40000000000, // Communotron 88-88
    "HighGainAntenna5.v2", 20000000, // HG-5 High Gain Antenna
    "RelayAntenna5",      200000000, // RA-2 Relay Antenna
    "RelayAntenna50",   20000000000, // RA-15 Relay Antenna
    "RelayAntenna100", 250000000000, // RA-100 Relay Antenna
    // RemoteTech
    "RTShortAntenna1",       500000, // Reflectron DP-10
    "RTLongAntenna2",       5000000, //Communotron 32
    "RTShortDish2",        90000000, // Reflectron KR-7
    "RTShortDish1",           False, // Reflectron SS-5 // Replased with KR-7
    "RTLongDish2",      60000000000, // Reflectron KR-14
    "RTLongDish1",            False, // Reflectron LL-5 // Replaced with KR-14
    "RTLongAntenna3",       3000000, // CommTech EXP-VR-2T
    "RTGigaDish2",     350000000000, // CommTech-1
    "RTGigaDish1",     400000000000, // Reflectron GX-128
    // Antennas mod
    "helixAntenna",        70000000, // H1X Helical
    "yagiActual",       40000000000, // YA6 Yagi
    "vhfBlade",              300000, // V17-7 Scimitar
    "quadHelix",             100000, // Q4-4 Quad Helix
    "yagiAntenna",         50000000, // LA-7 Log Periodic
    "hu6s125",              1000000, // HU6s-125 Twin Loop

    // Default value, highest energy cost in all modes
    "default",                 3000    // Default value is set to 3000m
).
DECLARE FUNCTION getTransmitTime {
    DECLARE PARAMETER DataPack. // Scalar in Mits
    // RemoteTech probably transmits data differently, lets handle that here

    RETURN DataPack / getTransmitSpeed().
}
// Slowest Mit/s / s
DECLARE FUNCTION getAntennaRange { 
    LOCAL R IS False.
    LOCAL i IS 0.
    FOR a IN myantennas {
        IF AntennaRange:HASKEY(a:NAME) {
            SET i TO AntennaRange[a:NAME].
            IF i > R { SET R TO i. }
        }
    }
    IF R { RETURN R. }
    RETURN AntennaRange["default"].
}
// Slowest Mit/s / s
DECLARE FUNCTION getTransmitSpeed { 
    LOCAL R IS False.
    LOCAL i IS 0.
    FOR a IN myantennas {
        IF AntennaTransmissionSpeed:HASKEY(a:NAME) {
            SET i TO AntennaTransmissionSpeed[a:NAME].
            IF i > R { SET R TO i. }
        }
    }
    // IF R AND hasRT { RETURN 6.67. } // RT Default speed
    IF R { RETURN R. }
    RETURN AntennaTransmissionSpeed["default"].
}
// Highest charge / Mit
DECLARE FUNCTION getTransmitEnergy {
    LOCAL R IS False.
    LOCAL i IS 0.
    FOR a in myantennas {
        IF AntennaEnergyConsumePerMit:HASKEY(a:NAME) {
            SET i TO AntennaEnergyConsumePerMit[a:NAME].
            IF R > i { SET R TO i. }
        }
    }
    // IF R AND myRT { RETURN 7.5. } // RT Default Energy consume
    IF R { RETURN R. }
    RETURN AntennaEnergyConsumePerMit["default"].
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
        RETURN myRT:HASCONNECTION(SHIP).
    }
    RETURN HOMECONNECTION:ISCONNECTED.
}
DECLARE FUNCTION connectedTo {
    IF hasRT {
        RETURN myRT:GROUNDSTATIONS()[0].
    }
    IF HOMECONNECTION:DESTINATION = "HOME" { RETURN "KSC". }
    RETURN HOMECONNECTION:DESTINATION.
}

// This function thorws an exception, will need to figure out how to avoid that.
DECLARE FUNCTION activateAllLinks {
    IF NOT hasRT { RETURN True. }
    FOR a IN myantennas {
        FOR P IN SHIP:partsnamed(a:NAME) {
            SET M TO P:GETMODULE("ModuleRTAntenna").
            M:DOEVENT("activate").
            WAIT 0.5.
        }
    }
}

DECLARE FUNCTION queryStations {
    IF hasRT {
        SET StationList TO myRT:GROUNDSTATIONS().
        LIST Targets in tgt.
        FOR t IN tgt {
            StationList:ADD(t:NAME).
        }
        LIST Bodies IN bod.
        FOR b IN bod {
            StationList:ADD(b:NAME).
        }
        RETURN StationList.
    }
    RETURN list("KSC").
}
DECLARE FUNCTION queryConnectedStations {
    IF NOT hasRT { RETURN lexicon("KSC", True). }
    RETURN  lexicon().
}

DECLARE FUNCTION queryVesselAntennas {
    RETURN lexicon().
}

DECLARE FUNCTION walkConnection {
    IF hasRT {
        // Cycle through directional antennas, ignore omnidirectional antennas
        // If directional antenna has connection, step ahead
        // Connect to closest station that vessel is not connected to
        FOR a IN myantennas {
            FOR p IN SHIP:partsnamed(a:NAME) {
                SET m TO p:GETMODULE("ModuleRTAntenna").
                IF m:HASEVENT("deactivate") {
                    IF m:HASFIELD("dish range") {
                        IF NOT m:HASEVENT("transmit all science") {
                            m:SETFIELD("target", "no-target").
                        }
                        IF m:GETFIELD("status") = "Operational" {
                            FOR s IN queryStations() {
                                m:SETFIELD("target", s).
                                WAIT 0.25.
                                IF m:HASEVENT("transmit all science") { RETURN True. }
                            }
                            WAIT 0.5.
                        }
                    }
                }
            }
        }
    }
    IF hasConnection() {
        RETURN True.
    }
    // Code to connect to nearest station
    RETURN False.
}
