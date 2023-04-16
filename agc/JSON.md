# JSON

Documentation of JSON object, what the different codes means

## Variables

* **link**: list
  * station connected to
  * delay
* **craft**: dict
  * **name**: string name
  * **type**: ENUM(Ship)
  * **status**: ENUM(LANDED, SPLASHED, PRELAUNCH, FLYING, SUB?ORBITAL, ORBITING, ESCAPING, DOCKED)
  * **orbit**: strign
* **pos**: dict
  * **altitude**: float _meter_
  * **y**: float _yaw_
  * **r**: float _roll_
  * **p**: float _pitch_
  * **geo**: dict
    * **lat**: float
    * **lng**: float
* **man**: dict
  * **rcs**: bool
  * **sas**: bool
  * **sasmode**: ENUM(STABILITYASSIST, PROGRADE, RETROGRADE, NORMAL, ANTINORMAL, RADIALIN, RADIALOUT, TARGET, ANTITARGET, MANEUVER, STABILITY)
  * **throttle**: float _%_
* **orbit**: dict
  * **ap**: float _apoapsis_
  * **pe**: float _periapsis_
  * **v**: float _orbit velocity_
  * **i**: float _inclination_
  * **e**: float _eccentricity_
  * **☊**: float _latitude of ascending node_
  * **ω**: float _argument of periapsis_
  * **♈︎**: float _rotation angle to aries_
  * **θ**: float _true anomaly_

## Errors

* **1** No connection, no communication to craft, no radio link.
