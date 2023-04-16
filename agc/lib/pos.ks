DECLARE FUNCTION posn {
    SET a TO "'pos':{".
    SET a TO a+"'alt':"+SHIP:altitude+",".
    SET a TO a+"'y':"+VectorAngle(SHIP:UP:TOPVECTOR,SHIP:FACING:TOPVECTOR)+",".
    SET a TO a+"'r':"+VectorAngle(SHIP:UP:STARVECTOR,SHIP:FACING:STARVECTOR)+",".
    SET a TO a+"'p':"+VectorAngle(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR)+",".
    SET a TO a+"'groundspeed':"+SHIP:groundspeed+",".
    SET a TO a+"'vertspeed':"+SHIP:verticalspeed+",".
    SET a TO a+"'q':"+SHIP:Q * constant:ATMtoKPa+",".
    SET a TO a+"'airspeed':"+SHIP:airspeed+",".
    SET a TO a+"'geo':{".
    SET a TO a+"'lat':"+SHIP:geoposition:lat+",".
    SET a TO a+"'lng':"+SHIP:geoposition:lng+",".
    SET a TO a+"},".
    SET a TO a+"},".
    return a.
}