//
// quick/turist.ks
//
// A simple combined quick script to complete a gravityturn to orbut
// and come safe down.
//
// Requirements: Enough deltaV for safe orbit + reach athmosphere
//
// Depart with rotation require less deltaV to reach orbit
//
// Minimum deltaV: 2000
// Recommended deltaV: 2500

SWITCH TO 0.
// Gravity turn up
WAIT 1.
//RUN "0:orbit/gravityturn".
RUN "0:orbit/gravityturn" (90, 80, 175000, False, 0, True).
//RUN "0:orbit/gravityturn" (350, 82).
// Immediate safe descent
WAIT 5.
RUN "0:landing/safedescent".
