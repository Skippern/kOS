DECLARE FUNCTION craft {
    SET a TO "'craft':{".
    SET a TO a+"'name':"+SHIPNAME+",".
    SET a TO a+"'type':"+SHIP:TYPE+",".
    SET a TO a+"'dwt':"+SHIP:DRYMASS+",".
    SET a TO a+"'status':"+SHIP:STATUS+",".
    SET a TO a+"'orbit':"+SHIP:BODY:NAME+",".
    SET a TO a+"},".
    return a.
}