/**
 * @file gas_supply.scad
 * @brief What happens UPSTREAM of the sterile inlet: the pump, the throttle, and the meter.
 *
 * The line between this file and utils/stirred_tank.scad is the inlet fitting. Anything the gas
 * does inside the vessel - orifice velocity, capillary pressure, ring diameter - is the tank's and
 * lives there. Anything about getting gas to that fitting at a known rate is here.
 *
 * No source held by this project describes a diaphragm pump's curve or a rotameter's readable
 * span; both are conventions, stated here so a reader can disagree with them rather than having
 * to infer them from a number.
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

// A straight line through two flows the caller has already priced: [slope, offset]. Two points
// is enough because the membrane filter dominates and is linear in flow; the check valve and the
// tubes bend it about 2 %.
function gas_line_secant(flow_lo, pressure_lo, flow_hi, pressure_hi) =
  let (_slope = (pressure_hi - pressure_lo) / (flow_hi - flow_lo))
    [_slope, pressure_lo - _slope * flow_lo];

// Where the pump settles: its own curve crossed with the line's, L/min. gas_pump_flow() answers
// a different question - flow against a back pressure held fixed - and a line does not hold still.
function gas_operating_flow(free_flow, dead_head, line) =
  free_flow * (dead_head - line[1]) / (dead_head + free_flow * line[0]);

// The most another filter may cost, kPa per L/min, before target_flow stops being reachable: the
// slope at which the crossing lands exactly on the flow wanted.
function gas_filter_slope_budget(free_flow, dead_head, line, target_flow) =
  ((free_flow * (dead_head - line[1]) / target_flow - dead_head) / free_flow - line[0]) / 1000;

// Pneumatic work at free flow AND dead head, over electrical input. Diaphragm pumps run 10-30 %,
// so anything approaching 100 % means the catalogue quotes the two ends of a curve.
function gas_pump_implied_efficiency(free_flow, dead_head, power) =
  free_flow / 60000 * dead_head / power;

// ----- what the line itself costs, between the pump and the sparge holes -----

function gas_air_density() = 1.204; // kg/m^3, dry air at 20 C
function gas_air_viscosity() = 1.81e-5; // Pa s, at 20 C

// Drop across a membrane filter, Pa. Linear in flow (Darcy). flow L/min, slope kPa per L/min.
function gas_filter_pressure_drop(flow, slope) = slope * flow * 1000;

// Drop along a tube, Pa. Darcy-Weisbach, laminar or Blasius as Reynolds decides. flow L/min, mm.
function gas_tube_pressure_drop(flow, bore, length) =
  let (
    _d = bore / 1000,
    _area = PI * pow(_d, 2) / 4,
    _v = flow / 60000 / _area,
    _re = gas_air_density() * _v * _d / gas_air_viscosity(),
    _f = _re < 2300 ? 64 / _re : 0.316 / pow(_re, 0.25)
  ) _f * (length / 1000) / _d * gas_air_density() * pow(_v, 2) / 2;

// Subcritical compressible flow through a valve, in the imperial terms Cv is defined in. flow
// L/min, pressures Pa (downstream is gauge). The drop a valve of known Cv costs, and the Cv a
// throttle needs for a wanted drop.
function gas_valve_pressure_drop(flow, cv, downstream) =
  let (_scfm = flow / 28.3168, _p2 = 14.7 + downstream / 6894.76)
    pow(_scfm / (22.67 * cv), 2) * 530 / _p2 * 6894.76;

function gas_valve_cv(flow, drop, downstream) =
  let (
    _scfm = flow / 28.3168,
    _dp = drop / 6894.76,
    _p2 = 14.7 + downstream / 6894.76
  ) _scfm / (22.67 * sqrt(_dp * _p2 / 530));

// Rotameters are not readable below 10 % of full scale, so a range [lo, hi] needs a scale at or
// above hi whose tenth is at or below lo.
function gas_meter_readable_fraction() = 0.1;
function gas_meter_scales() = [1, 2, 5, 10, 15, 25, 50]; // the sizes these are commonly sold in
function gas_meter_full_scale(flow_low, flow_high) =
  let (_fits = [
      for (s = gas_meter_scales())
        if (s >= flow_high && gas_meter_readable_fraction() * s <= flow_low) s
    ])
    len(_fits) > 0 ? _fits[0] : undef;
