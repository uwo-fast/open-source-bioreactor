// parameters for physical realization of heat-set threaded inserts
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rows carry NopSCADlib's insert schema so insert(), insert_hole_radius() and insert_hole_length()
// work on them unchanged. Registered here because none of the library's rows is a part we can buy.

//        length  outer_d  hole_d  screw  barrel_d  ring1_h  ring2_d  ring3_d  pitch  chamfer  part_no      material   pack

// McMaster 97163A152, 18-8 stainless, M4 x 0.7. Stainless rather than brass because the face is
// exposed to splashes and wipe-downs. Stainless needs a hotter iron and a longer dwell.
// Length and hole are catalogue values (hole 5.6 against a 5.7404 maximum). The ring diameters
// are NopSCADlib's nominal straight body, not the real tapered knurl. [9] and [10] are the library
// thread pitch and chamfer, undef for a heat-set insert. Project fields start at [11].
insert_m4x4p7_ss = ["M4x4.7 18-8", 4.7,  6.3,     5.6,    4,     5.15,     1.0,     6.0,     5.55,    undef, undef,   "97163A152", "18-8 SS", 10];

// McMaster 97163A150 and 97163A124, from the same tapered 18-8 family, for the two halves of the
// turbidity sampler. Length is from the catalogue and the hole is the catalogue drill size (9/64 in
// and 36 Ga; maxima 3.581 and 2.769). The remaining diameters are NopSCADlib's F1BM3 and F1BM2
// bodies, used for drawing only.
insert_m3x5p56_ss = ["M3x5.56 18-8", 5.56, 4.6,     3.57,   3,     3.65,     1.6,     4.4,     3.9,     undef, undef,   "97163A150", "18-8 SS", 10];
insert_m2x4p78_ss = ["M2x4.78 18-8", 4.78, 3.6,     2.71,   2,     3.0,      1.0,     3.4,     3.1,     undef, undef,   "97163A124", "18-8 SS", 1];

heat_set_inserts = [insert_m4x4p7_ss, insert_m3x5p56_ss, insert_m2x4p78_ss];

use <../utils/registries.scad>;
function heat_set_insert_by_name(name) = registry_by_name(heat_set_inserts, name, 14);

function heat_set_insert_name(type) = type[0];
function heat_set_insert_part_number(type) = type[11];
function heat_set_insert_material(type) = type[12];
function heat_set_insert_pack(type) = type[13];
