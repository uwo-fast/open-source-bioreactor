/**
 * @file gas_supply.scad
 * @brief The gas supply UPSTREAM of the sterile inlet: pump, throttle and flow meter.
 *
 * The boundary between this file and utils/stirred_tank.scad is the inlet fitting. Gas behaviour
 * inside the vessel (orifice velocity, capillary pressure, ring diameter) is in stirred_tank.scad.
 * Delivering gas to that fitting at a known rate is covered here.
 *
 * None of the sources this project holds describe a diaphragm pump curve or the readable range of
 * a rotameter. Both are conventions, stated here so a reader can see and dispute them instead of
 * inferring them from a number.
 */

// Diaphragm pump flow, taken as linear between its two published points. Real curves sag below a
// straight line, so this OVER-estimates flow at pressure. That is the safe direction when checking
// whether a pump has enough margin.
function gas_pump_flow(free_flow, dead_head, back_pressure) =
  free_flow * (1 - back_pressure / dead_head);

// The inverse: the pressure drop a throttle must add for the pump to settle at a target flow. The
// vessel back-pressure counts toward this and is usually a small part of it.
function gas_pump_back_pressure_for(free_flow, dead_head, target_flow) =
  dead_head * (1 - target_flow / free_flow);
function gas_throttle_pressure(free_flow, dead_head, target_flow, system_pressure) =
  gas_pump_back_pressure_for(free_flow, dead_head, target_flow) - system_pressure;

// A straight line through two flows whose pressure drops the caller has already computed:
// [slope, offset]. Two points are enough because the membrane filter dominates and is linear in
// flow; the check valve and tubes add about 2 % curvature.
function gas_line_secant(flow_lo, pressure_lo, flow_hi, pressure_hi) =
  let (_slope = (pressure_hi - pressure_lo) / (flow_hi - flow_lo))
    [_slope, pressure_lo - _slope * flow_lo];

// Operating flow, L/min: the intersection of the pump curve and the line curve. gas_pump_flow()
// gives flow against a fixed back pressure, but the line back pressure varies with flow.
function gas_operating_flow(free_flow, dead_head, line) =
  free_flow * (dead_head - line[1]) / (dead_head + free_flow * line[0]);

// Maximum slope of an additional filter, kPa per L/min, before target_flow becomes unreachable:
// the slope at which the operating point lands exactly on the target flow.
function gas_filter_slope_budget(free_flow, dead_head, line, target_flow) =
  ((free_flow * (dead_head - line[1]) / target_flow - dead_head) / free_flow - line[0]) / 1000;

// Pneumatic power at free flow AND dead head, divided by electrical input. Diaphragm pumps run at
// 10-30 %, so a value near 100 % shows the catalogue quotes the two ends of a curve.
function gas_pump_implied_efficiency(free_flow, dead_head, power) =
  free_flow / 60000 * dead_head / power;

// ----- pressure drop along the line, between the pump and the sparge holes -----

function gas_air_density() = 1.204; // kg/m^3, dry air at 20 C
function gas_air_viscosity() = 1.81e-5; // Pa s, at 20 C

// Drop across a membrane filter, Pa. Linear in flow (Darcy). flow L/min, slope kPa per L/min.
function gas_filter_pressure_drop(flow, slope) = slope * flow * 1000;

// Drop along a tube, Pa. Darcy-Weisbach, laminar or Blasius depending on Reynolds number. flow
// L/min, bore and length mm.
function gas_tube_pressure_drop(flow, bore, length) =
  let (
    _d = bore / 1000,
    _area = PI * pow(_d, 2) / 4,
    _v = flow / 60000 / _area,
    _re = gas_air_density() * _v * _d / gas_air_viscosity(),
    _f = _re < 2300 ? 64 / _re : 0.316 / pow(_re, 0.25)
  ) _f * (length / 1000) / _d * gas_air_density() * pow(_v, 2) / 2;

// Subcritical compressible flow through a valve, in the imperial units Cv is defined in. flow
// L/min, pressures Pa (downstream is gauge). The first function gives the drop across a valve of
// known Cv; the second gives the Cv a throttle needs for a target drop.
function gas_valve_pressure_drop(flow, cv, downstream) =
  let (_scfm = flow / 28.3168, _p2 = 14.7 + downstream / 6894.76)
    pow(_scfm / (22.67 * cv), 2) * 530 / _p2 * 6894.76;

function gas_valve_cv(flow, drop, downstream) =
  let (
    _scfm = flow / 28.3168,
    _dp = drop / 6894.76,
    _p2 = 14.7 + downstream / 6894.76
  ) _scfm / (22.67 * sqrt(_dp * _p2 / 530));

// Rotameters cannot be read below 10 % of full scale, so a range [lo, hi] needs a full scale of at
// least hi whose tenth is at most lo.
function gas_meter_readable_fraction() = 0.1;
function gas_meter_scales() = [1, 2, 5, 10, 15, 25, 50]; // common commercial sizes
function gas_meter_full_scale(flow_low, flow_high) =
  let (_fits = [
      for (s = gas_meter_scales())
        if (s >= flow_high && gas_meter_readable_fraction() * s <= flow_low) s
    ])
    len(_fits) > 0 ? _fits[0] : undef;
