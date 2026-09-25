// parameters for physical realization of impeller shafts
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rotary shafts, turned, ground and polished - not plain rod. The row carries tolerances because
// the shaft runs in the 608's inner race: shaft 8 -0.005/0 against bearing 8 -0.007/0 is a
// transition fit (0.005 clearance to 0.007 interference), which a rotating inner ring wants; h9
// rod would allow 0.043 of slop.
//
// 316 because the shaft is wetted and the reactor is chemically sterilised (7.5 % hydrogen peroxide;
// bleach only on the glass vessel, whose chloride 303/304 do not stand up to). NopSCADlib's rod() draws the geometry; the rows are ours.

//                  ["name"        part_no    [dia, dia_tol_lo, dia_tol_hi]   [length, len_tol], material, straightness_per_300]
shaft_8x200_316   = ["8x200_316",  "1265K64", [8,   -0.005,      0         ], [200,    0.25    ], "316 SS", 0.18];
shaft_8x400_316   = ["8x400_316",  "1265K66", [8,   -0.005,      0         ], [400,    0.25    ], "316 SS", 0.18];
shaft_8x600_316   = ["8x600_316",  "1265K67", [8,   -0.005,      0         ], [600,    0.25    ], "316 SS", 0.18];
shaft_8x800_316   = ["8x800_316",  "1265K68", [8,   -0.005,      0         ], [800,    0.25    ], "316 SS", 0.18];

// 600 and 800 are the same part in a longer cut, for taller vessels than any registered.

shafts = [shaft_8x200_316, shaft_8x400_316, shaft_8x600_316, shaft_8x800_316];

use <../utils/registries.scad>;
function shaft_by_name(name) = registry_by_name(shafts, name);

function shaft_name(type) = type[0];
function shaft_part_number(type) = type[1];
function shaft_diameter(type) = type[2][0];
function shaft_diameter_tol(type) = [type[2][1], type[2][2]]; // [lower, upper] deviation
function shaft_length(type) = type[3][0];
function shaft_length_tol(type) = type[3][1]; // plus or minus
function shaft_material(type) = type[4];
function shaft_straightness(type) = type[5]; // mm per 300 mm

// Extremes of the as-supplied diameter, for checking against a bearing bore.
function shaft_diameter_min(type) = shaft_diameter(type) + shaft_diameter_tol(type)[0];
function shaft_diameter_max(type) = shaft_diameter(type) + shaft_diameter_tol(type)[1];

use <NopSCADlib/vitamins/rod.scad>; // rod() draws the chamfered cylinder these actually are
