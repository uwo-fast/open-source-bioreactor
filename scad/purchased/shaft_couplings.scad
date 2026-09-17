// parameters for physical realization of shaft couplings
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rows carry NopSCADlib's shaft coupling schema so shaft_coupling() and the sc_* accessors work
// unchanged; the library has no 8-to-8. diameter1 is the gearbox end, diameter2 the impeller end.

//                         ["name"          length  outer_d  shaft1  shaft2  flexible]

// uxcell rigid aluminium coupling, twin set screws per side, sold in twos; the listing's own
// dimensions, no part number published.
shaft_coupler_8x8_rigid  = ["SC_8x8_rigid", 25,     14,      8,      8,      false];

shaft_couplings = [shaft_coupler_8x8_rigid];

function shaft_coupling_name(type) = type[0];
// undef, not "" or "n/a": check-bom skips an empty string and "n/a" would grep-match the buy list.
function shaft_coupling_part_number(type) = undef;

use <NopSCADlib/vitamins/shaft_coupling.scad>;
