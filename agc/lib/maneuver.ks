DECLARE FUNCTION man {
    SET a TO "'man':{".
    SET a TO a+"'rcs':"+RCS+",".
    SET a TO a+"'sas':"+SAS+",".
    SET a TO a+"'sasmode':"+SASMODE+",".
    SET a TO a+"'throttle':"+THROTTLE+",".
    SET a TO a+"},".
    return a.
}