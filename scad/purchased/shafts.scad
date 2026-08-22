// parameters for physical realization of impeller shafts
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// NopSCADlib draws a smooth rod but registers none - it gives rod(d, l) taking bare scalars, with
// no schema and no accessors, unlike the shaft-coupling and ball-bearing types it does carry. So
// the rows and accessors are ours and only the geometry is borrowed, which is the same split
// purchased/shaft_couplings.scad uses in the other direction.

// These are ROTARY SHAFTS, turned, ground and polished - not plain rod. That distinction is the
// whole reason the row carries tolerances: the shaft runs directly in the 608 bearing's inner
// race, so the fit is set by two tolerances meeting, not by a nominal diameter.
//
//   shaft   8 mm -0.005/0   ->  7.995 .. 8.000
//   608     8 mm -0.007/0   ->  7.993 .. 8.000
//
// which is a TRANSITION fit, 0.005 mm clearance to 0.007 mm interference. That is what a rotating
// inner ring wants - a little interference stops the race creeping on the shaft. Plain rod at h9
// would allow 0.043 mm of slop and fret the bore instead. head() checks this rather than trusting
// that any 8 mm bar will do.

// 316 rather than 303/304 because this is a wetted part in a vessel that is CHEMICALLY sterilised
// - the reactor cannot be autoclaved, so the shaft meets hypochlorite rather than steam, and
// McMaster rate 316 as standing up to bleach and chlorine where the cheaper grades are not.
// Both rows are REACH and RoHS 3 compliant, which is the same test the lid inserts were held to.

// length is the ordered length. Nothing derives from it except how far the shaft protrudes above
// the lid, so a longer shaft does not reach deeper - it pushes the motor higher. See head.scad.

//                  ["name"            part_no[dia, dia_tol_lo, dia_tol_hi]   [length, len_tol], material, straightness_per_300]
shaft_8x200_316   = ["8x200_316",  "1265K64", [8,   -0.005,      0         ], [200,    0.25    ], "316 SS", 0.18];
shaft_8x400_316   = ["8x400_316",  "1265K66", [8,   -0.005,      0         ], [400,    0.25    ], "316 SS", 0.18];
shaft_8x600_316   = ["8x600_316",  "1265K67", [8,   -0.005,      0         ], [600,    0.25    ], "316 SS", 0.18];
shaft_8x800_316   = ["8x800_316",  "1265K68", [8,   -0.005,      0         ], [800,    0.25    ], "316 SS", 0.18];

// 600 and 800 are registered for vessels this project does not yet have. They are the same part in
// a longer cut - identical tolerance, straightness and grade - so a taller jar needs a row change
// and nothing else. Not currently reachable: the registered jar is 295 mm internal, and head()
// rejects a shaft that leaves the mount too slender.

shafts = [shaft_8x200_316, shaft_8x400_316, shaft_8x600_316, shaft_8x800_316];

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

// example usage - keep commented, this file is include'd and would emit a shaft into every
// consumer (see shaft_couplings.scad for the same note)
// rod(d = shaft_diameter(shaft_8x400_316), l = shaft_length(shaft_8x400_316), center = false);
