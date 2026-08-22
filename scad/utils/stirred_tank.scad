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

function stirred_tank_sparge_ring_diameter(impeller_diameter, ratio) = impeller_diameter * ratio;
function stirred_tank_sparge_ring_ratio(ring_diameter, impeller_diameter) = ring_diameter / impeller_diameter;
function stirred_tank_sparge_ring_band() = [1.0, 2.0]; // Birch & Ahmed 1997 tested 1.4; Rewatkar & Joshi 1993 optimum 2.0

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
function stirred_tank_baffle_width(tank_diameter, count) = stirred_tank_baffle_reference_width(tank_diameter) / count;
function stirred_tank_baffle_wetted_length(length, freeboard, liquid_height) =
  max(0, min(length - freeboard, liquid_height)); // freeboard is how far the plate's top sits dry
function stirred_tank_baffle_area_ratio(tank_diameter, liquid_height, count, width, wetted_length) =
  count * width * wetted_length / stirred_tank_baffle_reference_area(tank_diameter, liquid_height);

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
// N, mm and MPa are a consistent set, so nothing is converted.
function stirred_tank_baffle_deflection(load, length, freeboard, width, thickness, modulus) =
  let (a = freeboard, L = length, q = load / (L - a))
    q * ((pow(L, 4) - pow(a, 4)) / 8 - a * (pow(L, 3) - pow(a, 3)) / 6)
    / (modulus * stirred_tank_baffle_second_moment(width, thickness));

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

// ----- hydrodynamics -----
//
// Everything below takes millimetres and rpm, because that is what the model and the motor
// registry hold, and returns SI. The conversions live inside so no caller does unit arithmetic,
// which is where this sort of code usually goes wrong.

// The culture is dilute enough to take water at 20 C, and nothing in this design's sources gives
// properties for an algal suspension. Change these two and every number below follows.
function stirred_tank_medium_density() = 998.2; // kg/m^3
function stirred_tank_medium_viscosity() = 1.002e-3; // Pa s

// Medek's correlations for a pitched blade impeller, from Fort et al. 2002, Acta Polytechnica
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
// Fort 2002 gives: nB 2-8, C/D 0.2-1.0, T/D 2.45-5.93, H/T 0.55-1.0, blade angle 15-60 degrees,
// four baffles at b/T = 0.1, and Re > 1e4.
function stirred_tank_medek_departures(n_blades, clearance_ratio, tank_ratio, height_ratio, blade_angle, baffles, reynolds) =
  [
    if (!(n_blades >= 2 && n_blades <= 8)) "blade count",
    if (!(clearance_ratio >= 0.2 && clearance_ratio <= 1.0)) "C/D",
    if (!(tank_ratio >= 2.45 && tank_ratio <= 5.93)) "T/D",
    if (!(height_ratio >= 0.55 && height_ratio <= 1.0)) "H/T",
    if (!(blade_angle >= 15 && blade_angle <= 60)) "blade angle",
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

// Shaft torque from power, N m. The same fact as the power above said another way, P = 2 pi N T,
// and worth having because motors are rated in torque rather than power.
function stirred_tank_torque(power, rpm) = power / (2 * PI * (rpm / 60));

// Culture volume of a plain cylindrical tank, litres, from bore and liquid depth in mm. A
// cylinder ignores the shoulder taper and the punt, so it runs a few percent high.
function stirred_tank_volume(bore, depth) = PI / 4 * pow(bore, 2) * depth / 1e6;

// Mean dissipation over the whole culture, W/m^3, from shaft power in W and volume in litres.
function stirred_tank_mean_dissipation(power, volume) = power / (volume / 1000);

// Peak local dissipation near the impeller, W/kg. This, not the vessel mean, is the quantity the
// cell-damage literature is about. Grenville 2017 eq. (24), +/- 15% - trade press, and the
// weakest-graded source this design leans on for anything.
function stirred_tank_max_dissipation(impeller_diameter, rpm, power_number, x) =
  1.04 * x * pow(power_number, 0.75) * pow(rpm / 60, 3) * pow(impeller_diameter / 1000, 2);
