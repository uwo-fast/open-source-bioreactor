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
