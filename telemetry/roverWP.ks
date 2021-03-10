clearScreen.

SET WP TO LATLNG(-0.6402,-80.7688).
SET MAXCHARGE TO ROUND(SHIP:ELECTRICCHARGE,0).

UNTIL false {
    PRINT "Ground speed is: " + ROUND(groundSpeed,1) + "m/s                  " AT(0,0).
    PRINT "Throttle command is: " + ROUND(wheelThrottle * 100,0) + "%                            " AT(0,1).
    PRINT "Current Latitude: " + ROUND(SHIP:geoposition:lat, 4) + "               " AT(0,2).
    PRINT "Current Longitude: " + ROUND(SHIP:geoposition:lng, 4) + "                " AT(0,3).
    SET currentPitch to ROUND(90 - VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR),1).
    PRINT "Heading: " + ROUND(mod(360 - latlng(90,0):bearing,360), 0) + " / Pitch: " + currentPitch + "                     " AT(0,4).
    PRINT "Steering: " + ROUND(wheelSteering, 3) + "                   " AT(0,5).
    PRINT "Electric Charge: " + ROUND(SHIP:ELECTRICCHARGE, 2) + " / " + ROUND((SHIP:ELECTRICCHARGE/MAXCHARGE)*100,1) + "%      " AT(0,6).
    PRINT "Bearing to target is: " + ROUND(WP:BEARING,4) + "              " AT(0,7). 
    PRINT "Direction to target is: " + ROUND(WP:HEADING,1) + "              " AT(0,8).
    PRINT "Distance Remaining to WP: " + FLOOR(WP:DISTANCE) + "m                " AT (0,9).
    PRINT "WP Latitude: " + ROUND(WP:LAT, 4) + "        " AT(0,10).
    PRINT "WP Longitude: " + ROUND(WP:LNG, 4) + "         " AT(0,11).

    WAIT 1.
}