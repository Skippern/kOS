// placeholder
CLEARSCREEN.

SET SASMODE TO "RETROGRADE".

UNTIL SHIP:PERIAPSIS < 69500 {
    SET SASMODE TO "RETROGRADE".
    LOCK THROTTLE TO 0.5.
}

UNTIL SHIP:APOAPSIS < 69999 {
    IF SHIP:ALTITUDE > 70000 {
        LOCK THROTTLE TO 0.
    } ELSE {
        SET SASMODE TO "RETROGRADE".
        LOCK THROTTLE TO 0.1.
    }
}

SAS OFF.
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
UNLOCK STEERING.
UNLOCK THROTTLE.
