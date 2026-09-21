/**
 * @file stirred_tank.scad
 * @brief Sizing an impeller against the tank it stirs
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description Stirred-tank relations, kept apart from the geometry that uses them.
 * custom/impeller.scad draws whatever it is handed; this decides what to hand it.
 *
 * The tank diameter T in all of these is the vessel's WETTED BORE, not the outside of the glass.
 * Sizing against the outer diameter lets the ratio drift with wall thickness - across this
 * project's own vessel registry that is 0.468 to 0.489 for one nominal 0.45 - which is how a
 * controlled parameter quietly stops being controlled.
 *
 *   D/T  0.3 to 0.5, about 0.3 for radial flow impellers. "Impellers that are too small do not
 *        generate enough fluid movement; oversized impellers require more power while being less
 *        efficient." Fitschen et al. 2019, Chem. Ing. Tech. 91:1794-1801,
 *        doi:10.1002/cite.201900121
 *
 *   D/T  0.4 to 0.5 for axial-flow hydrofoils in cell culture, as a dual pair with clearance
 *        between them of 0.33 to 0.5 T and the sparger below the lower impeller. Nienow 2006,
 *        Cytotechnology 50:9-33, doi:10.1007/s10616-006-9005-8, design guideline (a)
 *
 *   D/T  0.44 to 0.46 "most preferred" for axial impellers. Lonza US10883076B2
 *
 *   As D approaches 0.5 T an axial impeller loses its strong axial motion. Rotondi et al. 2021,
 *        Biotechnol Lett 43:1103-1116, doi:10.1007/s10529-021-03076-3
 *
 *   spacing  1.0 to 2.0 impeller diameters. Spacing that is too small "decreases the power
 *        imparted to the fluid by up to 35 %" against a properly spaced pair. Fitschen 2019.
 *        Their own rig ran d/D = 0.33, a radial ratio, so this is carried from the literature
 *        they review rather than measured on an axial impeller - do not over-claim it.
 *
 * Deliberately absent: any tip-speed limit. Tip speed is widely quoted and does not survive
 * scrutiny - "it does not even have the correct dimensions" for shear rate (s-1) or shear stress
 * (Pa), Nienow 2006, restated in Chem. Ing. Tech. 2020, doi:10.1002/cite.202000176. The 1.5 m/s
 * figure in circulation is one measurement on human melanoma cells in 5 % serum (Kioukia 1992,
 * via Varley and Birch 1999) generalised into a universal rule, in a paper that two sentences
 * later reports 6 m/s causing no measurable harm to a hybridoma line.
 *
 * These are bands, not limits. This reactor is a research instrument and a ratio outside a band
 * may be exactly what someone is studying, so nothing here asserts. The bands exist so a consumer
 * can report where it sits and say so out loud - see the echo in head.scad.
 *
 * Draws nothing and sets no $fn.
 */

// The impeller the tank asks for. bore is the wetted internal diameter, not the outer.
function stirred_tank_impeller_diameter(bore, ratio) = bore * ratio;

// Centre-to-centre spacing of a stacked pair, in impeller diameters.
function stirred_tank_impeller_spacing(impeller_diameter, factor) = impeller_diameter * factor;

// What the tank actually got, for reporting against the bands below.
function stirred_tank_ratio(impeller_diameter, bore) = impeller_diameter / bore;

// [low, high] bands. Functions rather than constants so a consumer can echo them alongside the
// value without restating the numbers.
function stirred_tank_ratio_band() = [0.3, 0.5]; // Fitschen 2019, all impeller types
function stirred_tank_ratio_band_axial() = [0.4, 0.5]; // Nienow 2006 guideline (a)
function stirred_tank_spacing_band() = [1.0, 2.0]; // Fitschen 2019, in impeller diameters

// How many impellers the spacing band implies: Fitschen 2019 eq. (5), (H - d)/d > N > (H - 2d)/(2d),
// from 1-2 d between impellers with the lowest one diameter off the floor. Fitschen relays it from
// Davis 2010, whose own sources do not contain it, so there is no primary. The variable is
// liquid height over IMPELLER diameter; H/T only stands in for it at one D/T.
function stirred_tank_impeller_count_bounds(liquid_height, impeller_diameter) =
  [
    (liquid_height - 2 * impeller_diameter) / (2 * impeller_diameter),
    (liquid_height - impeller_diameter) / impeller_diameter
  ];

// Strict, as the inequality is written.
function stirred_tank_impeller_count_fits(count, liquid_height, impeller_diameter) =
  let (_b = stirred_tank_impeller_count_bounds(liquid_height, impeller_diameter))
    count > _b[0] && count < _b[1];

// Inclusive of both ends: the bands are quoted as "between".
function stirred_tank_in_band(value, band) = value >= band[0] && value <= band[1];

// ----- off-bottom clearance -----
//
// How high the lowest impeller rides above the vessel floor, in impeller diameters. Oldshue 1997
// p. 192 offers 1 to 2 d for fluidfoil impellers, with the cost that "mixing is not provided at
// low levels during draw off". A trade-off, not a rule, and what decides a sparger's room.

function stirred_tank_clearance(impeller_diameter, factor) = impeller_diameter * factor;
function stirred_tank_clearance_ratio(clearance, impeller_diameter) = clearance / impeller_diameter;
// Permissive, not prescriptive: "if the impeller CAN be placed one to two impeller diameters off
// bottom ... these impellers OFFER an excellent flow pattern".
function stirred_tank_clearance_band_fluidfoil() = [1.0, 2.0]; // Oldshue 1997 p. 192

// Oldshue's condition pulls the other way: fluidfoils "short-circuit the fluid to a relatively low
// distance above the impeller. Very careful consideration of the coverage over the impeller is
// important." He gives no number, so 0.5 d is reasoned, not cited.
function stirred_tank_coverage(liquid_surface, impeller_top) = liquid_surface - impeller_top;
function stirred_tank_coverage_ratio(coverage, impeller_diameter) = coverage / impeller_diameter;
function stirred_tank_coverage_minimum() = 0.5;

// ----- pumping direction -----
//
// Reversing the shaft reverses a pitched blade's pumping (Birch & Ahmed), so a mirrored pair
// always opposes itself and the rotation picks the up-pumper. Converging means the flows meet
// between the impellers, which is where Birch & Ahmed put the sparge ring.

function stirred_tank_lower_pumps_up(rotation) = rotation > 0;
function stirred_tank_pair_converges(rotation) = stirred_tank_lower_pumps_up(rotation);

// ----- sparge ring -----
//
// Ring diameter in impeller diameters. Two independent studies find rings LARGER than the
// impeller better:
//
//   Birch & Ahmed 1997 tested a ring at 1.4 D and found improved power draw and delayed flooding
//        with "little or no penalty in terms of the gas holdup". 1.4 is not arbitrary - the
//        annulus from R out to 1.41 R encloses the same volume the impeller sweeps.
//   Rewatkar & Joshi 1993 recommend a large ring outright, and report the critical speed for gas
//        dispersion lowest at a ring twice the impeller diameter.
//
// Both find location relative to the impeller matters more than diameter, and both studied single
// impellers - neither settles a counter-pumping pair.

function stirred_tank_sparge_ring_ratio(ring_diameter, impeller_diameter) = ring_diameter / impeller_diameter;
function stirred_tank_sparge_ring_band() = [1.0, 2.0]; // Birch & Ahmed 1997 tested 1.4; Rewatkar & Joshi 1993 optimum 2.0

// Birch & Ahmed's 1.4: the volume the impeller sweeps equals the annulus from its radius out to
// 1.41 times it, so a ring there sits on the boundary of the impeller's working volume.
function stirred_tank_sparge_ring_equal_volume_ratio() = sqrt(2);

// ----- gas flow -----
//
// vvm is volumes of gas per volume of liquid per minute, the unit every aeration figure in the
// microalgae literature uses. Returned in m^3/s because the orifice calculation wants SI.
function stirred_tank_gas_flow(vvm, volume_litres) = vvm * volume_litres / 1000 / 60;

// Barbosa 2003 eq. 4. His runs were 0.4-5.4 m/s and he establishes no critical velocity, so this
// is reported, not bounded.
function stirred_tank_orifice_velocity(gas_flow, count, hole_diameter) =
  gas_flow / (count * PI / 4 * pow(hole_diameter / 1000, 2));

// What it costs to launch a bubble from a hole, 1-3 orders above what it costs to push gas through
// it - so hole-to-hole tolerance, not channel area, decides whether every hole flows.
function stirred_tank_capillary_pressure(hole_diameter) =
  4 * stirred_tank_surface_tension() / (hole_diameter / 1000);
// Shared by the forward and inverse forms. 1.2, not gas_air_density_at_20c()'s 1.204, because
// every orifice figure published here was computed with it.
function stirred_tank_orifice_cd() = 0.6;
function stirred_tank_orifice_density() = 1.2; // kg/m^3, air
function stirred_tank_orifice_pressure(velocity) =
  0.5 * stirred_tank_orifice_density() * pow(velocity, 2) / pow(stirred_tank_orifice_cd(), 2);

// Inverse: the area at which a given drop is spent, so a pressure can be a budget. What a hand-cut
// vent slot has to beat.
function stirred_tank_orifice_area(gas_flow, pressure) =
  gas_flow / (stirred_tank_orifice_cd() * sqrt(2 * pressure / stirred_tank_orifice_density()));

// ----- what the hole actually makes -----
//
// Bubble diameter at formation, from the force balance that gives Tate's law: a bubble grows on the
// orifice until buoyancy beats the surface tension holding it to the rim, so
//
//   pi * d_o * sigma  =  (pi/6) * d_b^3 * (rho_l - rho_g) * g
//
// Quasi-static, so a FLOOR: above a low gas rate the size becomes flow-dependent and larger
// (Kulkarni & Joshi 2005). Uyar's 0.8 mm orifice gives 3.28 mm by this against 4.18-4.25 measured.
// Bubble size is the strongest lever on kLa (Uyar: five-fold across three reactors, against 15 %
// from the impeller) but goes as the cube root of hole diameter, so a drilled ring cannot reach
// what a sintered sparger makes.
function stirred_tank_bubble_diameter(hole_diameter) =
  1000 * pow(
    6 * (hole_diameter / 1000) * stirred_tank_surface_tension()
    / (9.81 * (stirred_tank_medium_density() - gas_air_density_at_20c())),
    1 / 3
  );

// Air at 20 C.
function gas_air_density_at_20c() = 1.204; // kg/m^3

// Interfacial area per unit volume of dispersion, 1/m: a = 6*eps/d_b. kLa is kL times this.
function stirred_tank_specific_area(holdup, bubble_diameter) =
  6 * holdup / (bubble_diameter / 1000);

// Bubbles a second. Barbosa puts cell damage at bubble formation, so damage scales with this.
function stirred_tank_bubble_rate(gas_flow, bubble_diameter) =
  gas_flow / (PI / 6 * pow(bubble_diameter / 1000, 3));

// ----- whether a sparger's bore is a plenum -----
//
// A manifold shares evenly only if the resistance at the holes dominates the pressure differences
// along the bore. Two numbers say whether it does.

// Gas speed inside the sparger tube. `paths` is how many ways flow splits at the feed: two for a
// ring fed at one point, one per arm for a spider.
function stirred_tank_sparge_bore_velocity(gas_flow, bore_diameter, paths = 2) =
  gas_flow / (paths * PI / 4 * pow(bore_diameter / 1000, 2));

// The velocity head that speed carries; large against what a hole costs and the far holes starve.
function stirred_tank_sparge_bore_head(velocity) = 0.5 * gas_air_density_at_20c() * pow(velocity, 2);

// Total hole area over bore area. Well under 1 and the bore is the plenum it should be; at or above
// 1 the holes are competing with it.
function stirred_tank_sparge_open_area_ratio(hole_count, hole_diameter, bore_diameter, paths = 2) =
  hole_count * pow(hole_diameter, 2) / (paths * pow(bore_diameter, 2));

// ----- baffles -----
//
// Oldshue 1997 p. 202: four baffles "each 1/12 the tank diameter in width", and "either 3, 6 or 8
// baffles can be used if preferred. The general principle is to use the same total projected area
// as exists with four baffles". So width derives from count, and the reference is an area over the
// liquid depth; a plate is only worth its wetted span.

function stirred_tank_baffle_reference_width(tank_diameter) = 4 * tank_diameter / 12; // four at T/12
function stirred_tank_baffle_reference_area(tank_diameter, liquid_height) =
  stirred_tank_baffle_reference_width(tank_diameter) * liquid_height;
function stirred_tank_baffle_wetted_length(length, freeboard, liquid_height) =
  max(0, min(length - freeboard, liquid_height)); // freeboard is how far the plate's top sits dry
function stirred_tank_baffle_area_ratio(tank_diameter, liquid_height, count, width, wetted_length) =
  count * width * wetted_length / stirred_tank_baffle_reference_area(tank_diameter, liquid_height);

// ----- gas against the impeller -----
//
// Oldshue 1997 p. 228, on axial impellers in a gassed system: "the upward flow of gas tends to
// negate the downward action of the pumping capacity of the axial flow turbine. A radial flow
// turbine must have three times more power than the power in the gas stream for the mixer power
// level to be fully effective. On the other hand, the axial flow impeller must have eight to ten
// times more power than in the gas stream for it to establish the axial flow pattern."
//
// The gas stream's power is its volumetric rate times the head it rises through, so this is a
// ceiling on aeration rate for a given impeller power.

function stirred_tank_gas_stream_power(gas_flow, liquid_height) =
  gas_flow * stirred_tank_medium_density() * 9.81 * liquid_height / 1000; // W, from m^3/s and mm

function stirred_tank_gas_power_ratio(pumping) = pumping == "radial" ? 3 : 8; // Oldshue's lower bound
function stirred_tank_gas_flow_ceiling(impeller_power, pumping, liquid_height) =
  impeller_power / stirred_tank_gas_power_ratio(pumping)
  / stirred_tank_gas_stream_power(1, liquid_height); // the power one unit of flow carries

// ----- baffle loading -----
//
// The plates react the impeller's torque, shared equally: torque / (count * centroid radius).
// Reasoned, not cited; a tangential stream at 0.3 of tip speed agrees within 26 %. The plate bends
// tangentially, so this decides swirl-blocking and resonance, not the radial gap.

function stirred_tank_baffle_load(torque, count, centroid_radius) =
  torque / (count * centroid_radius / 1000); // N, from N m and mm

function stirred_tank_baffle_second_moment(width, thickness) = width * pow(thickness, 3) / 12;

// Tip deflection of a cantilever under a UDL running from freeboard to length: the point-load
// case P x^2 (3L - x) / 6EI integrated over the loaded span. N, mm and MPa are a consistent set.
function stirred_tank_baffle_deflection(load, length, freeboard, width, thickness, modulus) =
  let (a = freeboard, L = length, q = load / (L - a))
    q * (L * (pow(L, 3) - pow(a, 3)) / 6 - (pow(L, 4) - pow(a, 4)) / 24)
    / (modulus * stirred_tank_baffle_second_moment(width, thickness));

// What a joint adds: a dovetail neck is a local drop in second moment over the tail's depth, so
// extra rotation there times what hangs below. Per joint. Conservative - ignores the flanks.
function stirred_tank_baffle_joint_deflection(load, length, freeboard, width, thickness, modulus, joint, neck, depth) =
  let (
    a = freeboard, L = length, q = load / (L - a),
    _moment = joint >= a
      ? q * pow(L - joint, 2) / 2
      : q * (pow(L - a, 2) / 2 + (L - a) * (a - joint))
  )
    _moment * depth * (
      1 / stirred_tank_baffle_second_moment(width, neck)
      - 1 / stirred_tank_baffle_second_moment(width, thickness)
    ) / modulus * (L - joint);

// First bending mode of the plate as a cantilever in liquid, Hz. The entrained water dominates the
// mass - for a plate this slender it is over twice the PETG's own - so added mass is not optional.
// Everything inside is SI; the caller works in mm, MPa and kg/m^3.
function stirred_tank_baffle_frequency(length, width, thickness, modulus, solid_density) =
  let (
    _L = length / 1000, _w = width / 1000, _t = thickness / 1000,
    _I = _w * pow(_t, 3) / 12,
    _m = solid_density * _w * _t + stirred_tank_medium_density() * PI * pow(_w / 2, 2)
  ) pow(1.875, 2) / (2 * PI) * sqrt(modulus * 1e6 * _I / (_m * pow(_L, 4)));

// The drive's two excitations: once per shaft turn from runout and imbalance, and once per blade.
function stirred_tank_shaft_frequency(rpm) = rpm / 60;
function stirred_tank_blade_frequency(rpm, n_blades) = rpm * n_blades / 60;

// The rpm at which an excitation of a given order (1 for the shaft, blade count for blade passing)
// crosses a mode. A DC motor sweeps every frequency under its maximum, so what decides a plate is
// the speed of the crossing and whether the reactor sits there.
function stirred_tank_critical_speed(frequency, order) = frequency * 60 / order;

// ----- hydrodynamics -----
//
// Everything below takes millimetres and rpm, what the model and the motor registry hold, and
// returns SI. No caller does unit arithmetic.

// The culture is dilute enough to take water at 20 C.
function stirred_tank_medium_density() = 998.2; // kg/m^3
function stirred_tank_medium_viscosity() = 1.002e-3; // Pa s
// Air against water at 20 C.
function stirred_tank_surface_tension() = 0.072; // N/m

// Medek's correlations for a pitched blade impeller, from Fořt et al. 2002, Acta Polytechnica
// 42(4), doi:10.14311/380. These give the power number and the pumping-capacity number as
// functions of the geometry rather than as one constant per shape, which is what lets a design
// move without silently carrying a Po measured on a different tank.
//
//   Po   = 1.507 nB^0.701 (C/D)^-0.165 (T/D)^-0.365 (H/T)^0.140 (sin a)^2.077
//   N_Qp = 0.745 nB^0.233 (C/D)^0.254  (T/D)^0.023  (H/T)^0.251 (sin a)^0.468
//
// Power climbs with blade angle about 4.4x faster than pumping does.
//
// blade_angle is degrees from the plane of rotation, clearance_ratio is C/D, tank_ratio is T/D
// (not D/T), height_ratio is liquid height over tank diameter.
function stirred_tank_medek_power_number(n_blades, clearance_ratio, tank_ratio, height_ratio, blade_angle) =
  1.507 * pow(n_blades, 0.701) * pow(clearance_ratio, -0.165) * pow(tank_ratio, -0.365)
  * pow(height_ratio, 0.140) * pow(sin(blade_angle), 2.077);

function stirred_tank_medek_flow_number(n_blades, clearance_ratio, tank_ratio, height_ratio, blade_angle) =
  0.745 * pow(n_blades, 0.233) * pow(clearance_ratio, 0.254) * pow(tank_ratio, 0.023)
  * pow(height_ratio, 0.251) * pow(sin(blade_angle), 0.468);

// The envelope the correlations were fitted in, returned as the names that fall outside it.
//
// Fořt 2002 gives: nB 2-8, C/D 0.2-1.0, T/D 2.45-5.93, H/T 0.55-1.0, blade angle 15-60 degrees,
// four baffles at b/T = 0.1, and Re > 1e4.
function stirred_tank_medek_departures(n_blades, clearance_ratio, tank_ratio, height_ratio, blade_angle, baffles, reynolds) =
  [
    if (!(n_blades >= 2 && n_blades <= 8)) "blade count",
    if (!(clearance_ratio >= 0.2 && clearance_ratio <= 1.0)) "C/D",
    if (!(tank_ratio >= 2.45 && tank_ratio <= 5.93)) "T/D",
    if (!(height_ratio >= 0.55 && height_ratio <= 1.0)) "H/T",
    // undef is a departure, not a pass: a twisted blade has no single angle
    if (is_undef(blade_angle) || !(blade_angle >= 15 && blade_angle <= 60)) "blade angle",
    if (baffles != 4) "baffle count",
    if (reynolds <= 1e4) "Reynolds",
  ];

// Impeller Reynolds number, rho*N*D^2/mu. Turbulent above 1e4; Nienow 2021 uses ~2e4.
function stirred_tank_reynolds(impeller_diameter, rpm) =
  stirred_tank_medium_density() * (rpm / 60) * pow(impeller_diameter / 1000, 2)
  / stirred_tank_medium_viscosity();

// Tip speed, m/s. Reported only (see the header). The one Chlorella measurement is in it:
// 1.26 m/s the growth optimum, 2.03 m/s where stirring stops paying. Leupold et al. 2013.
function stirred_tank_tip_speed(impeller_diameter, rpm) =
  PI * (impeller_diameter / 1000) * (rpm / 60);

// Shaft power drawn by one impeller, Po*rho*N^3*D^5, in W.
function stirred_tank_power(impeller_diameter, rpm, power_number) =
  power_number * stirred_tank_medium_density() * pow(rpm / 60, 3)
  * pow(impeller_diameter / 1000, 5);

// Mean velocity of the return leg, m/s: Fl*N*D^3 over the annulus between impeller and wall. A
// bulk number; it says nothing about the corner a probe sits in.
function stirred_tank_circulation_velocity(flow_number, rpm, impeller_diameter, bore) =
  flow_number * (rpm / 60) * pow(impeller_diameter / 1000, 3)
  / (PI / 4 * (pow(bore / 1000, 2) - pow(impeller_diameter / 1000, 2)));

// Shaft torque from power, N m: P = 2 pi N T. Motors are rated in torque.
function stirred_tank_torque(power, rpm) = power / (2 * PI * (rpm / 60));

// Culture volume is the jar's registered profile: purchased/vessel.scad, vessel_profile_litres().

// Mean dissipation over the whole culture, W/m^3, from shaft power in W and volume in litres.
function stirred_tank_mean_dissipation(power, volume) = power / (volume / 1000);

// Peak local dissipation near the impeller, W/kg - what the cell-damage literature is about.
// Grenville 2017 eq. (24), +/- 15%, trade press and the weakest source this design leans on.
function stirred_tank_max_dissipation(impeller_diameter, rpm, power_number, x) =
  1.04 * x * pow(power_number, 0.75) * pow(rpm / 60, 3) * pow(impeller_diameter / 1000, 2);

// ----- blend time -----
//
// How long the vessel takes to homogenise. Ruszkowski's correlation, as given in Hall 2004 eq. (13):
//
//   t95 = 5.9 * T^(2/3) * eps^(-1/3) * (T/D)^(1/3)
//
// with T in metres, eps the tank-mean dissipation in W/kg, and the result in seconds. This form
// reproduces Hall's own table (1.96 s against 1.9, 2.59 against 2.6); the Cooke form beside it
// does not. Impeller type is not a term: blend time per unit power is close to impeller-independent.
function stirred_tank_blend_time(bore, impeller_diameter, mean_dissipation) =
  5.9
  * pow(bore / 1000, 2 / 3)
  * pow(mean_dissipation / stirred_tank_medium_density(), -1 / 3)
  * pow(bore / impeller_diameter, 1 / 3);

// Ruszkowski's vessels, in m^3. Reported as a departure, not asserted: below the range the
// correlation is extrapolation, which is exactly what Hall does at 1.7e-4 and says so.
function stirred_tank_blend_time_volume_band() = [0.01, 10];

// ----- eccentricity -----
//
// What moving the impeller off the axis buys in an UNBAFFLED vessel, which is the only case it is
// claimed for. Karcz 2005 eq. (6), p. 2372:
//
//   Theta = 48.5 + (1/M) * exp[-1.89 * (1/M) * (e/R)] * exp[8.18 * M]
//
// Theta is the dimensionless mixing time n*t_m, M is +0.32 up-pumping and -0.32 down-pumping,
// and R is the tank RADIUS, so e/R is twice e/T. Used only as a ratio against the centred case:
// Theta's magnitude is Karcz's 270 L tank, not this vessel. Mean relative error +/-10%; at
// e/T = 0.2 this gives 0.425 where Hall 2004 measured 0.36 on a pitched blade.
function stirred_tank_karcz_m(pumps_up) = pumps_up ? 0.32 : -0.32;

function stirred_tank_eccentric_theta(eccentricity_ratio, pumps_up = true) =
  let (_m = stirred_tank_karcz_m(pumps_up), _e_over_r = 2 * eccentricity_ratio) // R = T/2
    48.5 + (1 / _m) * exp(-1.89 * (1 / _m) * _e_over_r) * exp(8.18 * _m);

// Fraction of the centred blend time an offset buys back. 0 on the axis, about 0.43 at the far end
// of the fitted range.
function stirred_tank_eccentric_gain(eccentricity_ratio, pumps_up = true) =
  1 - stirred_tank_eccentric_theta(eccentricity_ratio, pumps_up)
  / stirred_tank_eccentric_theta(0, pumps_up);

function stirred_tank_eccentricity_band() = [0, 0.285]; // e/T, from the paper's e/R over <0, 0.57>
function stirred_tank_karcz_reynolds_band() = [2e4, 8e4];

// What this vessel violates, by name. Karcz fitted one geometry and varied only e/R and Re, so
// most are single conditions (the tolerances let a float compare). `pumping mode` is the one that
// matters: a counter-pumping pair is neither branch, and the branches disagree at the centred
// case by nearly two to one. Every figure quoted here is the up-pumping branch, which Hall's
// up-pumping PBT corroborates.
function stirred_tank_eccentric_departures(impeller_ratio, height_ratio, volume, reynolds,
                                           eccentricity_ratio, baffles, counter_pumping,
                                           is_propeller) =
  [
    if (abs(impeller_ratio - 0.33) > 0.005) "D/T",
    if (abs(height_ratio - 1.0) > 0.005) "H/T",
    if (abs(volume - 270) > 2.7) "scale",
    if (!stirred_tank_in_band(reynolds, stirred_tank_karcz_reynolds_band())) "Reynolds",
    if (!stirred_tank_in_band(eccentricity_ratio, stirred_tank_eccentricity_band())) "e/T",
    if (baffles != 0) "baffle count",
    if (counter_pumping) "pumping mode",
    // fitted on a 3-blade propeller, S = D, w = 0.2 D; blade form is not a term
    if (!is_propeller) "impeller type",
  ];

// ----- gas-liquid mass transfer -----
//
// Superficial gas velocity: the sparge flow over the vessel's cross section, m/s from m^3/s and mm.
function stirred_tank_superficial_gas_velocity(gas_flow, bore) =
  gas_flow / (PI / 4 * pow(bore / 1000, 2));

// Van't Riet 1979, the standard first estimate. Two forms, because coalescence dominates the
// bubble size and so the interfacial area: a clean water-like broth lets bubbles merge, a salty one
// does not. Miracle-Gro at 0.2 g/L is dilute enough to be the coalescing case.
//
//   coalescing      kLa = 0.026 * (P/V)^0.4 * us^0.5
//   non-coalescing  kLa = 0.002 * (P/V)^0.7 * us^0.2
//
// P/V in W/m^3, us in m/s, kLa in 1/s. Air-water correlations: an order of magnitude, reported.
function stirred_tank_kla_coalescing(specific_power, superficial_velocity) =
  0.026 * pow(specific_power, 0.4) * pow(superficial_velocity, 0.5);
function stirred_tank_kla_non_coalescing(specific_power, superficial_velocity) =
  0.002 * pow(specific_power, 0.7) * pow(superficial_velocity, 0.2);

// Van't Riet's stated validity in specific power, W/m^3.
function stirred_tank_kla_power_band() = [500, 10000];
