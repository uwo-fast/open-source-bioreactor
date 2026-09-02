// parameters for physical realization of shaft couplings
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rows carry NopSCADlib's shaft coupling schema so its shaft_coupling() and the sc_* accessors
// work on them unchanged. Registered here rather than taken from that library because it carries
// only SC_5x8_rigid and SC_6x8_flex, and the drive needs an 8-to-8 - the gearbox output shaft and
// the impeller shaft are both 8 mm, so the coupling joins two equal bores rather than stepping
// between them. diameter1 is the gearbox end and diameter2 the impeller end.

//                         ["name"          length  outer_d  shaft1  shaft2  flexible]

// uxcell rigid aluminium coupling, twin set screws per side, sold in twos. No part number is
// published, so the row is the listing's own dimensions: 25 mm long, 14 mm outside diameter.
// That outside diameter is the one number worth care here - the row this replaced carried 12.5,
// which is NopSCADlib's SC_5x8_rigid unchanged, so it described the library's part rather than
// the one on the bench.
shaft_coupler_8x8_rigid  = ["SC_8x8_rigid", 25,     14,      8,      8,      false];

shaft_couplings = [shaft_coupler_8x8_rigid];

// [0] is the one index NopSCADlib's sc_* accessors leave alone - they read [1] upward - so the
// name lives here rather than in a singular file this registry does not have.
function shaft_coupling_name(type) = type[0];

// No part number: uxcell publish none for this coupling, so the row above is the listing's own
// dimensions instead. undef rather than "" or "n/a" - an empty string is silently skipped by
// check-bom and "n/a" is a plausible string that would grep-match the buy list.
function shaft_coupling_part_number(type) = undef;

use <NopSCADlib/vitamins/shaft_coupling.scad>;

// example usage - keep commented, this file is include'd and would emit a coupling into every
// consumer (see 1a6df3d)
// shaft_coupling(shaft_coupler_8x8_rigid);
