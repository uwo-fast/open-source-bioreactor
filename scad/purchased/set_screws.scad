// parameters for physical realization of cup-tip set screws
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Each row binds a purchasable part to a NopSCADlib grub screw type. The library provides the
// geometry and tap radius; the row provides the part number and length. The library is included
// here because the rows reference its types.
include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/screws.scad>;

// 316 because the screws are wetted and the reactor is chemically sterilised. Cup tip so the
// screw still grips after the PETG creeps.

//                        ["name"      part_no      screw          length  material  hardness  pack]

// 6 mm reaches the shaft flush through a 10 mm hub radius.
set_screw_m4x6_316   = ["M4x6 316",  "92029A142", M4_grub_screw,  6,      "316 SS", "B80",    50 ];

// For a 12 mm hub radius.
set_screw_m4x8_316   = ["M4x8 316",  "92029A144", M4_grub_screw,  8,      "316 SS", "B80",    25 ];

// Fallback if M4 cannot be tapped. At equal depth it holds three quarters of the load an M4 does.
set_screw_m3x6_316   = ["M3x6 316",  "92029A103", M3_grub_screw,  6,      "316 SS", "B80",    25 ];

set_screws = [set_screw_m4x6_316, set_screw_m4x8_316, set_screw_m3x6_316];

function set_screw_name(type) = type[0];
function set_screw_part_number(type) = type[1];
function set_screw_screw(type) = type[2]; // NopSCADlib screw type; screw(), screw_radius() etc.
function set_screw_length(type) = type[3];
function set_screw_material(type) = type[4];
function set_screw_hardness(type) = type[5]; // Rockwell B
function set_screw_pack(type) = type[6];

// Read from the bound NopSCADlib type rather than stored again, so the sizes cannot drift apart.
function set_screw_diameter(type) = screw_radius(set_screw_screw(type)) * 2;
function set_screw_tap_radius(type) = screw_pilot_hole(set_screw_screw(type));
function set_screw_socket_af(type) = screw_socket_af(set_screw_screw(type));

use <NopSCADlib/vitamins/screw.scad>; // screw() draws the part these rows name
