// lib/countdown.ks
//
// A countdown to run in start of launch procedures
//
// Always to be executed from 0: 
//CLEARSCREEN.
PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "... " + countdown.
    HUDTEXT(countdown, 1, 4, 26, RED, False).
    WAIT 1. // pauses the script here for 1 second.
}
HUDTEXT("0", 3, 4, 26, RED, False).