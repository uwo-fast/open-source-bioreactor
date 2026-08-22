/**
 * @file gas_supply.scad
 * @brief What happens UPSTREAM of the sterile inlet: the pump, the throttle, and the meter.
 *
 * The line between this file and utils/stirred_tank.scad is the inlet fitting. Anything the gas
 * does inside the vessel - orifice velocity, capillary pressure, ring diameter - is the tank's and
 * lives there. Anything about getting gas to that fitting at a known rate is here.
 *
 * Everything below is REASONED, NOT CITED. No source held by this project describes a diaphragm
 * pump's curve or a rotameter's readable span; both are conventions, stated here so a reader can
 * disagree with them rather than having to infer them from a number.
 */

// A diaphragm pump between its two published points, taken as linear. Real curves sag below a
// straight line, so this OVER-estimates flow at pressure, which is the safe direction when the
// question is whether a pump has enough margin.
function gas_pump_flow(free_flow, dead_head, back_pressure) =
  free_flow * (1 - back_pressure / dead_head);

// Turned around: what a throttle has to drop for the pump to settle at a wanted flow. The vessel's
// own back-pressure counts toward this, and is usually a small part of it.
function gas_pump_back_pressure_for(free_flow, dead_head, target_flow) =
  dead_head * (1 - target_flow / free_flow);
function gas_throttle_pressure(free_flow, dead_head, target_flow, system_pressure) =
  gas_pump_back_pressure_for(free_flow, dead_head, target_flow) - system_pressure;

// The plausibility check the ReSun's listing fails. If a pump really delivered its free flow at its
// dead-head pressure it would be doing this much pneumatic work; compared against the electrical
// input it says whether the two numbers can be simultaneous. Diaphragm pumps run 10-30 % efficient,
// so anything approaching 100 % means the catalogue is quoting the ends of a curve.
function gas_pump_implied_efficiency(free_flow, dead_head, power) =
  free_flow / 60000 * dead_head / power;

// Rotameters are read against a scale and are not trustworthy near its bottom; 10 % of full scale
// is the usual limit quoted. So a range [lo, hi] needs a scale at or above hi whose tenth is at or
// below lo, and a wide enough range has no single scale that covers it.
function gas_meter_readable_fraction() = 0.1;
function gas_meter_scales() = [1, 2, 5, 10, 15, 25, 50]; // the sizes these are commonly sold in
function gas_meter_full_scale(flow_low, flow_high) =
  let (_fits = [
      for (s = gas_meter_scales())
        if (s >= flow_high && gas_meter_readable_fraction() * s <= flow_low) s
    ])
    len(_fits) > 0 ? _fits[0] : undef;
