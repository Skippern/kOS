// Copied from REDDIT https://www.reddit.com/r/Kos/comments/3ftcwk/compute_burn_time_with_calculus/

// Calculate the burn time to complete a burn of a fixed Δv

// Base formulas:
// Δv = ∫ F / (m0 - consumptionRate * t) dt
// consumptionRate = F / (Isp * g)
// ∴ Δv = ∫ F / (m0 - (F * t / g * Isp)) dt

// Integrate:
// ∫ F / (m0 - (F * t / g * Isp)) dt = -g * Isp * log(g * m0 * Isp - F * t)
// F(t) - F(0) = known Δv
// Expand, simplify, and solve for t

DECLARE FUNCTION MANEUVER_TIME {
  PARAMETER dV.

  LIST ENGINES IN en.

  LOCAL f IS en[0]:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
  LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
  LOCAL e IS CONSTANT():E.            // Base of natural log
  LOCAL p IS en[0]:ISP.               // Engine ISP (s)
  LOCAL g IS 9.80665.                 // Gravitational acceleration constant (m/s²)

  RETURN g * m * p * (1 - e^(-dV / (g * p))) / f.
}