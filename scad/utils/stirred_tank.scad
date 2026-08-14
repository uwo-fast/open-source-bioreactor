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

// ----- hydrodynamics -----
//
// Everything below takes millimetres and rpm, because that is what the model and the motor
// registry hold, and returns SI. The conversions live inside so no caller does unit arithmetic,
// which is where this sort of code usually goes wrong.

// The culture is dilute enough to take water at 20 C, and nothing in this design's sources gives
// properties for an algal suspension. Change these two and every number below follows.
function stirred_tank_medium_density() = 998.2; // kg/m^3
function stirred_tank_medium_viscosity() = 1.002e-3; // Pa s

// Power number for a 4-blade folded axial impeller, Np = 0.99 +/- 0.04. Jirout & Rieger, CTU
// Prague. The closest MEASURED analogue to this project's blade, not a measurement of it: the
// twist makes this a different shape, so every power figure derived from it inherits that gap.
function stirred_tank_power_number_folded_axial_4() = 0.99;

// Impeller-type constant in the peak-dissipation correlation: Rushton 12, pitched blade 16,
// hydrofoil 17. Grenville 2017. This blade is a twisted paddle, so the pitched-blade value is the
// nearest of the three.
function stirred_tank_dissipation_factor_pitched_blade() = 16;

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
