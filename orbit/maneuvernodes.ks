// orbit/maneivernodes.ks
//
// Loop to prepare maneuvers in nodes.
//
// Nodes must be placed out from map view.
CLEARSCREEN.
SAS OFF.
SET MYSTEER TO HEADING(0,0).
LOCK STEERING TO MYSTEER.
SET BurnPhase TO False.

UNTIL False {
    // Main loop
    IF BurnPhase {
        SET dBurn TO NEXTNODE:DELTAV:MAG / 36.
        SET MYSTEER TO NEXTNODE:DELTAV.
        LOCK THROTTLE TO MIN(1.0, dBurn).
        PRINT " DO BURN!                                                " AT(0,0).
        PRINT "Delta Burn = "+ROUND(dBurn,1)+" and Throttle Command="+ROUND(THROTTLE*100,1)+"%          " AT(0,2).
        IF dBurn < 0.025 { 
            SET BurnPhase TO False. 
            UNLOCK STEERING.
            LOCK THROTTLE TO 0.
            UNLOCK THROTTLE.
            REMOVE NEXTNODE. // Might not work.
        }
        WAIT 0.001.
    } ELSE IF (ETA:NEXTNODE > 600 ) { // we don't bother to prepare nothing while node is more than 10 minutes away
        // check that we actually have a node and print out estimated time before a longer wait (time in minutes)
        PRINT "NO NODE OR NODE FAR AWAY" AT(0,0).
        LOCK THROTTLE TO 0.
        SET nextETA TO ROUND(ETA:NEXTNODE / 60,0).
        SET hr TO FLOOR(nextETA / 60).
        SET nextETA TO ROUND(nextETA - (hr * 60),0).
        IF HASNODE { PRINT "NODE ETA IN " + hr + "hr " + nextETA + "min        " AT(0,1). 
        } ELSE { PRINT "NO NODE SET                                    " AT(0,1). }
        WAIT 60.
    } ELSE {
        PRINT "NODE APPROACHING, DO SOMETHING                            " AT(0,0).
        SET MYSTEER TO NEXTNODE:DELTAV.
        IF ETA:NEXTNODE > 590 {
            KUNIVERSE:timewarp:cancelwarp().
        }
        // We have a node approaching, lets react.
        IF NEXTNODE:ETA > 60 {
            LOCK STEERING TO MYSTEER.
            SET tmp TO NEXTNODE:ETA.
            SET min TO FLOOR(tmp / 60).
            SET sec TO ROUND(tmp - (min*60),0).
            PRINT "NODE ETA IN " + min + "min " + sec + "s                 " AT(0,1).
            WAIT 1.
        } ELSE IF NEXTNODE:ETA < 0.3 AND NEXTNODE:ETA > 0 {
            SET tmp TO NEXTNODE:ETA.
            PRINT "ENTER BURN SEQUENCE                                " AT(0,0).
            PRINT "NODE ETA IN " + ROUND(NEXTNODE:ETA,1) + "s                " AT(0,1).
            SET BurnPhase TO True.
            WAIT 0.1.
        } ELSE IF NEXTNODE:ETA < 0 {
            PRINT "NODE PASSED, SET NEW NODE OR WAIT FOR NEXT ROUND!                " AT(0,0).
            LOCK THROTTLE TO 0.
            SET BurnPhase TO False.
            WAIT 1.
            UNLOCK THROTTLE.
            UNLOCK STEERING.
        } ELSE {
            SET tmp TO NEXTNODE:ETA.
            PRINT "ENTER BURN SEQUENCE                                " AT(0,0).
            PRINT "NODE ETA IN " + ROUND(NEXTNODE:ETA,1) + "s                " AT(0,1).
            IF NEXTNODE:ETA < 0.3 { SET BurnPhase TO True. }
            WAIT 0.1.
        }
//        WAIT 1.
    }
}