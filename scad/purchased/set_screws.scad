// parameters for physical realization of cup-tip set screws
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Unlike shafts and heat-set inserts, NopSCADlib already registers these: M3_grub_screw and
// M4_grub_screw carry the schema, screw() draws them and screw_pilot_hole() gives the tap radius,
// and their socket sizes - 1.5 mm on M3, 2.0 on M4 - are the same numbers McMaster tabulate for
// these parts. So the geometry is not ours to re-register. What NopSCADlib does not carry is which
// part you buy, or how long it is: screw() takes length as an argument rather than holding it, and
// length is exactly what distinguishes one catalogue row from the next. That is what these rows
// are - a purchasable part bound to a NopSCADlib type.

// 316 rather than 18-8, on the same reasoning as the shaft: these sit in the culture, the reactor
// is chemically sterilised and never autoclaved, and McMaster rate 316 against bleach where the
// cheaper grades weaken. The lid's heat-set inserts are 18-8, but those are dry - a wetted 18-8
// insert would repeat the conflict docs/procurement.md records against the 440C bearing.

// CUP tip, not flat or cone. The tip has to bite a soft shaft - the 316 rotary shaft is Rockwell
// B83 - because friction alone is not what holds this joint once PETG creeps. A cone tip would
// need a matching dimple and would fix the impeller's height to it; a cup tip makes its own.

//                        ["name"      part_no      screw          length  material  hardness  pack]

// The working pair, two per impeller at 120 degrees. Length is chosen against the hub wall, not
// picked from the catalogue for its own sake: the hub is 10 mm in radius over a 4.2 mm bore, so
// 5.8 mm of thread stands between the socket and the shaft, and a 6 mm screw arrives at the shaft
// surface sitting flush. See impeller.scad, which derives the tapped hole from this row.
set_screw_m4x6_316   = ["M4x6 316",  "92029A142", M4_grub_screw,  6,      "316 SS", "B80",    50 ];

// Registered against hubs this project does not yet have. An 8 mm screw wants 7.8 mm of wall - a
// 12 mm hub radius - and would stand 2 mm proud of the one drawn today.
set_screw_m4x8_316   = ["M4x8 316",  "92029A144", M4_grub_screw,  8,      "316 SS", "B80",    25 ];

// The fallback if M4 cannot be tapped. It is not the safer choice for being smaller: thread shear
// area goes with circumference, so at equal depth an M3 holds three quarters of what an M4 does,
// and it needs 8.7 mm of engagement to carry what the M4 carries in 6.5.
set_screw_m3x6_316   = ["M3x6 316",  "92029A103", M3_grub_screw,  6,      "316 SS", "B80",    25 ];

set_screws = [set_screw_m4x6_316, set_screw_m4x8_316, set_screw_m3x6_316];

function set_screw_name(type) = type[0];
function set_screw_part_number(type) = type[1];
function set_screw_screw(type) = type[2]; // NopSCADlib screw type; screw(), screw_radius() etc.
function set_screw_length(type) = type[3];
function set_screw_material(type) = type[4];
function set_screw_hardness(type) = type[5]; // Rockwell B
function set_screw_pack(type) = type[6];

// Borrowed from the bound type rather than registered again, so a size change cannot drift.
function set_screw_diameter(type) = screw_radius(set_screw_screw(type)) * 2;
function set_screw_tap_radius(type) = screw_pilot_hole(set_screw_screw(type));
function set_screw_socket_af(type) = screw_socket_af(set_screw_screw(type));


use <NopSCADlib/vitamins/screw.scad>; // screw() draws the part these rows name
