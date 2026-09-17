// parameters for physical realization of heat-set threaded inserts
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Rows carry NopSCADlib's insert schema so insert(), insert_hole_radius() and insert_hole_length()
// work on them unchanged. Registered here because none of the library's rows is a part we can buy.

//        length  outer_d  hole_d  screw  barrel_d  ring1_h  ring2_d  ring3_d  pitch  chamfer  part_no      material   pack

// McMaster 97163A152, 18-8 stainless, M4 x 0.7; the lid's mount screws land in four. Stainless
// over brass because the face sees splash and wipe-downs; it wants a hotter iron and longer dwell.
// Length and hole are the catalogue's (hole 5.6 against a 5.7404 maximum); the ring diameters are
// NopSCADlib's nominal straight body, not the real tapered knurl. [9] and [10] are the library's
// thread pitch and chamfer, undef on a heat-fit insert; the project's fields start at [11].
insert_m4x4p7_ss = ["M4x4.7 18-8", 4.7,  6.3,     5.6,    4,     5.15,     1.0,     6.0,     5.55,    undef, undef,   "97163A152", "18-8 SS", 10];

heat_set_inserts = [insert_m4x4p7_ss];

function heat_set_insert_name(type) = type[0];
function heat_set_insert_part_number(type) = type[11];
function heat_set_insert_material(type) = type[12];
function heat_set_insert_pack(type) = type[13];
