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

// ----- what the line itself costs, between the pump and the sparge holes -----
//
// The vessel's own back-pressure is only part of what the pump has to beat. The membrane filter and
// the riser take their share first, and until this landed head() reported the vessel's figure alone
// as "what the gas supply has to beat", which understated it several times over.

function gas_air_density() = 1.204; // kg/m^3, dry air at 20 C
function gas_air_viscosity() = 1.81e-5; // Pa s, at 20 C

/**
 * @brief Drop across a membrane filter, Pa.
 *
 * Linear in flow, which is the right model rather than a convenience: flow through a membrane at
 * these pressures is viscous, and Darcy's law makes it proportional. The slope is a property of one
 * filter and belongs to the caller.
 *
 * @param flow  L/min
 * @param slope kPa per L/min
 */
function gas_filter_pressure_drop(flow, slope) = slope * flow * 1000;

/**
 * @brief Drop along a length of tube, Pa. Darcy-Weisbach, laminar or Blasius as Reynolds decides.
 * @param flow   L/min
 * @param bore   mm
 * @param length mm
 */
function gas_tube_pressure_drop(flow, bore, length) =
  let (
    _d = bore / 1000,
    _area = PI * pow(_d, 2) / 4,
    _v = flow / 60000 / _area,
    _re = gas_air_density() * _v * _d / gas_air_viscosity(),
    _f = _re < 2300 ? 64 / _re : 0.316 / pow(_re, 0.25)
  ) _f * (length / 1000) / _d * gas_air_density() * pow(_v, 2) / 2;

/**
 * @brief Flow coefficient a throttle needs to pass a gas flow at a wanted drop.
 *
 * Cv is how valves are actually sold, so this is what turns "the throttle has to drop N Pa" into a
 * part number. Subcritical compressible flow, in the imperial terms the coefficient is defined in -
 * the conversions live here so no caller does them.
 *
 * @param flow          L/min
 * @param drop          Pa across the valve
 * @param downstream    Pa gauge downstream of it
 * @return Cv
 */
// The drop a valve of KNOWN Cv costs at a given flow - the inverse of gas_valve_cv() below, and the
// one a bought valve needs. Sizing a throttle asks "what Cv passes this flow at this drop"; a check
// valve is already chosen, so the question turns round: its Cv is on the datasheet and the flow is
// what the vessel wants, and what falls out is what it takes off the line.
function gas_valve_pressure_drop(flow, cv, downstream) =
  let (_scfm = flow / 28.3168, _p2 = 14.7 + downstream / 6894.76)
    pow(_scfm / (22.67 * cv), 2) * 530 / _p2 * 6894.76;

function gas_valve_cv(flow, drop, downstream) =
  let (
    _scfm = flow / 28.3168,
    _dp = drop / 6894.76,
    _p2 = 14.7 + downstream / 6894.76
  ) _scfm / (22.67 * sqrt(_dp * _p2 / 530));

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
