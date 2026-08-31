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

// Predicates, so the caller chooses the severity. Inclusive of both ends: the bands are quoted
// as "between" in the sources, and a value sitting exactly on one is not a departure.
function stirred_tank_in_band(value, band) = value >= band[0] && value <= band[1];

// ----- off-bottom clearance -----
//
// How high the lowest impeller rides above the vessel floor, in impeller diameters. Oldshue 1997
// p. 192 offers 1 to 2 d for fluidfoil impellers, and states the cost in the same breath:
// "mixing is not provided at low levels during draw off". It is a trade-off, not a rule, and it
// is the parameter that decides how much room a sparger has underneath.
//
// Nothing here gives a clearance for a twisted paddle, and the 1.0 d figure this project carried
// until 2026-08-21 came from a thesis misreading that sentence as an impeller-to-impeller
// spacing. See docs/references.md, Davis 2010.

function stirred_tank_clearance(impeller_diameter, factor) = impeller_diameter * factor;
function stirred_tank_clearance_ratio(clearance, impeller_diameter) = clearance / impeller_diameter;
// PERMISSIVE, not prescriptive. The sentence is "if the impeller CAN be placed one to two impeller
// diameters off bottom ... these impellers OFFER an excellent flow pattern as well as considerable
// economies in shaft design" - a reward for being able to sit high, not an instruction to. Sitting
// below it is a property of the vessel, so head() reports rather than warns on it.
function stirred_tank_clearance_band_fluidfoil() = [1.0, 2.0]; // Oldshue 1997 p. 192

// Oldshue states the condition in the sentence BEFORE the band, and it pulls the other way:
// fluidfoils "short-circuit the fluid to a relatively low distance above the impeller. Very
// careful consideration of the coverage over the impeller is important." He gives no number for
// it, so 0.5 d is REASONED, NOT CITED - it is the depth below which a down-pumping impeller starts
// drawing its own discharge back off the surface rather than turning the vessel over.
function stirred_tank_coverage(liquid_surface, impeller_top) = liquid_surface - impeller_top;
function stirred_tank_coverage_ratio(coverage, impeller_diameter) = coverage / impeller_diameter;
function stirred_tank_coverage_minimum() = 0.5;

// ----- pumping direction -----
//
// A pitched blade deflects fluid along its own normal, so reversing the shaft reverses the
// pumping. Birch & Ahmed state it outright: "the pumping orientation of this turbine was reversed
// by changing the direction of rotation of the stirrer". A mirrored pair therefore always opposes
// itself, and the rotation picks which of the two is the up-pumper.
//
// Converging is the arrangement where the flows meet BETWEEN the impellers. It matters because
// Birch & Ahmed put the sparge ring in the impeller's discharge - above an up-pumping blade, below
// a down-pumping one - and only a converging pair puts both discharges in the same place.

function stirred_tank_lower_pumps_up(rotation) = rotation > 0;
function stirred_tank_pair_converges(rotation) = stirred_tank_lower_pumps_up(rotation);

// ----- sparge ring -----
//
// Ring diameter in impeller diameters. Two independent experimental studies find rings LARGER
// than the impeller better, which is the opposite of the handbook sentence this project sized
// against until 2026-08-21:
//
//   Birch & Ahmed 1997 tested a ring at 1.4 D and found improved power draw and delayed flooding
//        with "little or no penalty in terms of the gas holdup". 1.4 is not arbitrary - the
//        annulus from R out to 1.41 R encloses the same volume the impeller sweeps.
//   Rewatkar & Joshi 1993 recommend a large ring outright, and report the critical speed for gas
//        dispersion lowest at a ring twice the impeller diameter.
//
// Both also find sparger LOCATION relative to the impeller matters more than its diameter, and
// both studied single impellers - neither settles a counter-pumping pair. Gas belongs in the
// impeller's discharge stream; which side that is depends on pumping direction.

function stirred_tank_sparge_ring_ratio(ring_diameter, impeller_diameter) = ring_diameter / impeller_diameter;
function stirred_tank_sparge_ring_band() = [1.0, 2.0]; // Birch & Ahmed 1997 tested 1.4; Rewatkar & Joshi 1993 optimum 2.0

// 1.4 is not a compromise between those two. Birch & Ahmed justify it: the volume the impeller
// sweeps, between the axis and its own radius, equals the volume of the annulus from that radius
// out to 1.41 times it. A ring there sits on the boundary of the impeller's own working volume.
function stirred_tank_sparge_ring_equal_volume_ratio() = sqrt(2);

// ----- gas flow -----
//
// vvm is volumes of gas per volume of liquid per minute, the unit every aeration figure in the
// microalgae literature uses. Returned in m^3/s because the orifice calculation wants SI.
function stirred_tank_gas_flow(vvm, volume_litres) = vvm * volume_litres / 1000 / 60;

// Barbosa 2003 eq. 4. Note his own runs were 0.4-5.4 m/s and he establishes NO critical velocity -
// the "30-50 m/s" this project once cited from him was unsupported. So this is reported, not bounded.
function stirred_tank_orifice_velocity(gas_flow, count, hole_diameter) =
  gas_flow / (count * PI / 4 * pow(hole_diameter / 1000, 2));

// What it costs to launch a bubble from a hole, against what it costs to push gas through it. The
// first is 1-3 orders larger, which is why hole-to-hole TOLERANCE and not channel area decides
// whether every hole flows - and why bigger holes are less sensitive, since 4 sigma / d falls as d
// rises while a fixed tolerance does not.
function stirred_tank_capillary_pressure(hole_diameter) = 4 * 0.072 / (hole_diameter / 1000);
function stirred_tank_orifice_pressure(velocity) = 0.5 * 1.2 * pow(velocity, 2) / pow(0.6, 2);

// ----- baffles -----
//
// Oldshue 1997 p. 202: four baffles "each 1/12 the tank diameter in width", and explicitly
// "either 3, 6 or 8 baffles can be used if preferred. The general principle is to use the same
// total projected area as exists with four baffles". So the count is a free choice and the
// constraint is total projected area - which is why width is derived from count here rather than
// registered beside it.

// Oldshue's baffles run the liquid depth, so the reference is an area and the comparison has to be
// made against area. A plate is only worth its wetted span: dry plate in the headspace does
// nothing, and a lid-hung plate loses the freeboard off the top before it starts.

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
// The gas stream's power is what the rising gas does to the liquid: its volumetric rate times the
// head it rises through. So this is a ceiling on aeration rate for a given impeller power, and it
// is the reason the impeller's TYPE and the sparger's rate are not independent choices.

function stirred_tank_gas_stream_power(gas_flow, liquid_height) =
  gas_flow * stirred_tank_medium_density() * 9.81 * liquid_height / 1000; // W, from m^3/s and mm

function stirred_tank_gas_power_ratio(pumping) = pumping == "radial" ? 3 : 8; // Oldshue's lower bound
function stirred_tank_gas_flow_ceiling(impeller_power, pumping, liquid_height) =
  impeller_power / stirred_tank_gas_power_ratio(pumping)
  / stirred_tank_gas_stream_power(1, liquid_height); // the power one unit of flow carries

// ----- baffle loading -----
//
// The plates react the torque the impeller puts into the fluid. Sharing it equally, each sees
// torque / (count * centroid radius). Cross-checked against the dynamic pressure of a tangential
// stream at 0.3 of tip speed, which agrees within 26 % - REASONED, NOT CITED either way, since no
// source held here loads a baffle.
//
// What that load decides is NOT a collision. The plate bends tangentially and the impeller sweeps
// a circle, so deflection does not close the radial gap to it. It decides two other things: at
// what point the plate bends away from the swirl instead of blocking it, and whether it sits on
// a frequency the drive excites.

function stirred_tank_baffle_load(torque, count, centroid_radius) =
  torque / (count * centroid_radius / 1000); // N, from N m and mm

function stirred_tank_baffle_second_moment(width, thickness) = width * pow(thickness, 3) / 12;

// Tip deflection of a cantilever under a UDL running from freeboard to length. mm in, mm out -
// N, mm and MPa are a consistent set, so nothing is converted. Integrating the point-load case
// P x^2 (3L - x) / 6EI over the loaded span, which is where the earlier form here went wrong: it
// understated a 280 mm plate at 49 mm of freeboard by 23 %, and it was checked only at a = 0,
// where both forms give the same qL^4/8EI.
function stirred_tank_baffle_deflection(load, length, freeboard, width, thickness, modulus) =
  let (a = freeboard, L = length, q = load / (L - a))
    q * (L * (pow(L, 3) - pow(a, 3)) / 6 - (pow(L, 4) - pow(a, 4)) / 24)
    / (modulus * stirred_tank_baffle_second_moment(width, thickness));

// What a joint in the plate adds to that. A dovetail neck is a local drop in second moment over
// the tail's depth, so it turns into extra rotation there and the tip swings by that rotation
// times what hangs below it. Per joint; a caller with several sums them. Conservative: it counts
// only the material crossing the joint plane, and ignores what the flanks carry in bearing.
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

/**
 * @brief The speed at which an excitation of a given order crosses a frequency, rpm.
 *
 * The inverse of the two above, and the number that actually decides a plate. Asking whether a
 * mode sits near an excitation AT ONE SPEED answers it for that speed only - which is the right
 * question for LOAD, where fastest is worst, and the wrong one for RESONANCE. A DC motor's speed is
 * continuous, so blade passing sweeps every frequency under its own maximum and something is always
 * crossed on the way up. What decides a plate is the SPEED the crossing happens at, and whether the
 * reactor is asked to sit there.
 *
 * @param frequency Hz, the mode being crossed
 * @param order     excitations per revolution: 1 for the shaft, the blade count for blade passing
 */
function stirred_tank_critical_speed(frequency, order) = frequency * 60 / order;

// ----- hydrodynamics -----
//
// Everything below takes millimetres and rpm, because that is what the model and the motor
// registry hold, and returns SI. The conversions live inside so no caller does unit arithmetic,
// which is where this sort of code usually goes wrong.

// The culture is dilute enough to take water at 20 C, and nothing in this design's sources gives
// properties for an algal suspension. Change these two and every number below follows.
function stirred_tank_medium_density() = 998.2; // kg/m^3
function stirred_tank_medium_viscosity() = 1.002e-3; // Pa s

// Medek's correlations for a pitched blade impeller, from Fořt et al. 2002, Acta Polytechnica
// 42(4), doi:10.14311/380. These give the power number and the pumping-capacity number as
// functions of the geometry rather than as one constant per shape, which is what lets a design
// move without silently carrying a Po measured on a different tank.
//
//   Po   = 1.507 nB^0.701 (C/D)^-0.165 (T/D)^-0.365 (H/T)^0.140 (sin a)^2.077
//   N_Qp = 0.745 nB^0.233 (C/D)^0.254  (T/D)^0.023  (H/T)^0.251 (sin a)^0.468
//
// The exponents say something the model should not lose: power climbs with blade angle about
// 4.4x faster than pumping does, so angle buys throughput expensively.
//
// blade_angle is degrees from the plane of rotation, clearance_ratio is C/D, tank_ratio is T/D
// (not D/T), height_ratio is liquid height over tank diameter.
function stirred_tank_medek_power_number(n_blades, clearance_ratio, tank_ratio, height_ratio, blade_angle) =
  1.507 * pow(n_blades, 0.701) * pow(clearance_ratio, -0.165) * pow(tank_ratio, -0.365)
  * pow(height_ratio, 0.140) * pow(sin(blade_angle), 2.077);

function stirred_tank_medek_flow_number(n_blades, clearance_ratio, tank_ratio, height_ratio, blade_angle) =
  0.745 * pow(n_blades, 0.233) * pow(clearance_ratio, 0.254) * pow(tank_ratio, 0.023)
  * pow(height_ratio, 0.251) * pow(sin(blade_angle), 0.468);

// The envelope the correlations were fitted in. Returned as a list of the names that fall outside
// it, so a consumer can echo exactly which ones rather than a bare true/false - an extrapolation
// that is out on one count is a different thing from one that is out on four.
//
// Fořt 2002 gives: nB 2-8, C/D 0.2-1.0, T/D 2.45-5.93, H/T 0.55-1.0, blade angle 15-60 degrees,
// four baffles at b/T = 0.1, and Re > 1e4.
function stirred_tank_medek_departures(n_blades, clearance_ratio, tank_ratio, height_ratio, blade_angle, baffles, reynolds) =
  [
    if (!(n_blades >= 2 && n_blades <= 8)) "blade count",
    if (!(clearance_ratio >= 0.2 && clearance_ratio <= 1.0)) "C/D",
    if (!(tank_ratio >= 2.45 && tank_ratio <= 5.93)) "T/D",
    if (!(height_ratio >= 0.55 && height_ratio <= 1.0)) "H/T",
    // undef is a departure, not a pass. A twisted blade has no single angle, and a correlation
    // keyed on one cannot cover it - unguarded the comparison warns instead of answering.
    if (is_undef(blade_angle) || !(blade_angle >= 15 && blade_angle <= 60)) "blade angle",
    if (baffles != 4) "baffle count",
    if (reynolds <= 1e4) "Reynolds",
  ];

// Po and the dissipation constant x used to live here as free functions named after the
// impellers they described - which was the tell that they are properties of a shape, not of a
// tank. They are now columns in custom/impellers.scad and arrive as arguments below.

// Impeller Reynolds number, rho*N*D^2/mu. Turbulent above 1e4 on the textbook threshold; Nienow
// 2021 uses a stricter ~2e4.
function stirred_tank_reynolds(impeller_diameter, rpm) =
  stirred_tank_medium_density() * (rpm / 60) * pow(impeller_diameter / 1000, 2)
  / stirred_tank_medium_viscosity();

// Tip speed, m/s. Reported only, never asserted against - see the header for why. It is still
// worth computing because the one measurement that exists for Chlorella is expressed in it:
// 1.26 m/s the growth optimum, 2.03 m/s where stirring stops paying. Leupold et al. 2013.
function stirred_tank_tip_speed(impeller_diameter, rpm) =
  PI * (impeller_diameter / 1000) * (rpm / 60);

// Shaft power drawn by one impeller, Po*rho*N^3*D^5, in W.
function stirred_tank_power(impeller_diameter, rpm, power_number) =
  power_number * stirred_tank_medium_density() * pow(rpm / 60, 3)
  * pow(impeller_diameter / 1000, 5);

// Mean velocity of the return leg, m/s: what the impeller pumps, Fl*N*D^3, divided by the annulus
// between it and the wall that the flow comes back down.
//
// A BULK number, and it has to be read as one - the vessel's average, not the speed at any
// particular place. It answers whether the tank MOVES, which is the question a probe that consumes
// what it measures actually asks. It says nothing about whether one corner of the vessel is
// stagnant, and a probe sits in exactly one corner.
function stirred_tank_circulation_velocity(flow_number, rpm, impeller_diameter, bore) =
  flow_number * (rpm / 60) * pow(impeller_diameter / 1000, 3)
  / (PI / 4 * (pow(bore / 1000, 2) - pow(impeller_diameter / 1000, 2)));

// Shaft torque from power, N m. The same fact as the power above said another way, P = 2 pi N T,
// and worth having because motors are rated in torque rather than power.
function stirred_tank_torque(power, rpm) = power / (2 * PI * (rpm / 60));

// Culture volume is NOT here any more. A cylinder on the bore was standing in for the jar, and its
// own note had the sign backwards - it read a few percent HIGH when in fact it read low, because
// the punt is a narrow pillar in a wide floor and the liquid in the annulus around it was simply
// dropped. The jar's registered profile answers it exactly: purchased/vessel.scad,
// vessel_profile_litres().

// Mean dissipation over the whole culture, W/m^3, from shaft power in W and volume in litres.
function stirred_tank_mean_dissipation(power, volume) = power / (volume / 1000);

// Peak local dissipation near the impeller, W/kg. This, not the vessel mean, is the quantity the
// cell-damage literature is about. Grenville 2017 eq. (24), +/- 15% - trade press, and the
// weakest-graded source this design leans on for anything.
function stirred_tank_max_dissipation(impeller_diameter, rpm, power_number, x) =
  1.04 * x * pow(power_number, 0.75) * pow(rpm / 60, 3) * pow(impeller_diameter / 1000, 2);

// ----- blend time -----
//
// How long the vessel takes to homogenise, which is the number a fermentation paper leads with and
// the one this model never reported. Ruszkowski's correlation, as given in Hall 2004 eq. (13):
//
//   t95 = 5.9 * T^(2/3) * eps^(-1/3) * (T/D)^(1/3)
//
// with T in metres, eps the tank-mean dissipation in W/kg, and the result in seconds. Encoded rather
// than the Cooke form Hall prints beside it because this one reproduces Hall's own table - 1.96 s
// against a published 1.9 for his 60 mm vessel, 2.59 against 2.6 for his 88 mm - and the Cooke
// figures could not be reproduced from the form as printed.
//
// Note what it does NOT depend on: impeller type. Blend time at a given specific power is close to
// impeller-independent, which is the whole point of stating it per unit power.
function stirred_tank_blend_time(bore, impeller_diameter, mean_dissipation) =
  5.9
  * pow(bore / 1000, 2 / 3)
  * pow(mean_dissipation / stirred_tank_medium_density(), -1 / 3)
  * pow(bore / impeller_diameter, 1 / 3);

// Ruszkowski's vessels, in m^3. Reported as a departure, not asserted: below the range the
// correlation is extrapolation, which is exactly what Hall does at 1.7e-4 and says so.
function stirred_tank_blend_time_volume_band() = [0.01, 10];

// ----- gas-liquid mass transfer -----
//
// Superficial gas velocity: the sparge flow spread over the vessel's cross section, m/s from m^3/s
// and mm. The velocity a bubble would rise at if the gas filled the bore, which is the form every
// kLa correlation is written in.
function stirred_tank_superficial_gas_velocity(gas_flow, bore) =
  gas_flow / (PI / 4 * pow(bore / 1000, 2));

// Van't Riet 1979, the standard first estimate. Two forms, because coalescence dominates the
// bubble size and so the interfacial area: a clean water-like broth lets bubbles merge, a salty one
// does not. Miracle-Gro at 0.2 g/L is dilute enough to be the coalescing case.
//
//   coalescing      kLa = 0.026 * (P/V)^0.4 * us^0.5
//   non-coalescing  kLa = 0.002 * (P/V)^0.7 * us^0.2
//
// P/V in W/m^3, us in m/s, kLa in 1/s. AIR-WATER correlations: this is an order-of-magnitude
// estimate for a real broth, not a measurement, and is reported rather than asserted on.
function stirred_tank_kla_coalescing(specific_power, superficial_velocity) =
  0.026 * pow(specific_power, 0.4) * pow(superficial_velocity, 0.5);
function stirred_tank_kla_non_coalescing(specific_power, superficial_velocity) =
  0.002 * pow(specific_power, 0.7) * pow(superficial_velocity, 0.2);

// Van't Riet's stated validity in specific power, W/m^3. This reactor runs under it, which is worth
// saying every render rather than discovering later.
function stirred_tank_kla_power_band() = [500, 10000];
