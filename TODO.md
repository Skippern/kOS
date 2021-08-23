# TODO

* orbit/hoffman - Hoffman manoeuvre to other celestial body
* orbit/geostation - Set Geostationary orbit at specified Longitude
* orbit/rendezvous - Rendezvous with object
* landing/landing - Safe controlled landing in specified position
* orbit/step - Jump ahead or back certain % of orbit, useful for positioning satellites.
* lib/deltav2burn - calculate burn time for specific deltaV maneuver
* lib/AGC - functions related to displaying AGC equivalents of prorgams running
* rover/path - drive a path to get to a destination avoiding obstacles
* rover/explore - explore an area and gather science while avoiding obstacles
* flight/takeoff - get an aircraft to safe altitude
* flight/landing - land an aircraft
* flight/autopilot - fly a path of waypoints
* lib/science/contracts - get data related to contracts, such as type of science and experiment waypoint
* agc/agc - the actual AGC adjusted for Kerbal physics (with option for modded physics / Real Solar System?)
* agc/dsky - Apollo AGC DSKY for ingame display
* agc/RPi - DSKY for a dedicated RPi unit over telnet
* lib/link - Get or send data between active computers

# WORK IN PROGRESS

* orbit/gravityturn - Gravity turn to end as soon as Periapsis is at safe height
* orbit/setOrbit - adjust inclination, deescending node, argument of Periopsis
* lib/utils/std - collection of standard functions and variables
* lib/orbitals - collection of data about (experience needed for different scripts) of celestial bodies

# DONE

* boot/boot - default minimum boot
* boot/autotelemetryOrbiter - auto boots telemetry for orbitals
* lib/countdown - visual countdown
* telemetry/orbit - all interresting data for orbital crafts, what is sent back to KSC
* lib/comms - various functions for communicatoin, supports vanilla and RemoteTech
* lib/getScience - runs experiments and transmits back
* landing/safedescent - Get inside athmosphere, athmospheric break, parachute down.
