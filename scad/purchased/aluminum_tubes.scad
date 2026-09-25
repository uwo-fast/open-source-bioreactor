// parameters for physical realization of aluminum tubing
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// Tube that has to be bent by hand, which is the condenser's coolant coil: soft enough to wind on
// its former, and a fraction of the cost of a soft stainless tube. Not for anything in the culture,
// which stays 316 (steel_tubes.scad). Aluminum stands the 7.5 % hydrogen peroxide everything but the
// probes is sterilised with, and not bleach or chlorite, which only the glass vessel ever gets.
//
// McMaster's seamless 3003 coils, soft temper, flared-fitting grade, sold by the coil. Transcribed
// from their "Aluminum Tubing" listing, read 2026-09-24. Sizes are inch; the row stores mm. The
// listing also gives a pressure rating (580 to 2,300 psi at 72 F), not registered because nothing
// here comes near it. ID is od - 2 * wall, as the listing's ID column agrees to its rounding.

//                                ["name"           part_no     [od,             wall          ], material, construction, temper]
aluminum_tube_1_8x0p025         = ["1/8x0.025",     "5177K61",  [ 1/8  * 25.4, 0.025 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_3_16x0p028        = ["3/16x0.028",    "5177K62",  [ 3/16 * 25.4, 0.028 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_1_4x0p032         = ["1/4x0.032",     "5177K63",  [ 1/4  * 25.4, 0.032 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_1_4x0p049         = ["1/4x0.049",     "5177K64",  [ 1/4  * 25.4, 0.049 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_5_16x0p035        = ["5/16x0.035",    "5177K65",  [ 5/16 * 25.4, 0.035 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_3_8x0p035         = ["3/8x0.035",     "5177K66",  [ 3/8  * 25.4, 0.035 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_3_8x0p049         = ["3/8x0.049",     "5177K67",  [ 3/8  * 25.4, 0.049 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_7_16x0p035        = ["7/16x0.035",    "5177K68",  [ 7/16 * 25.4, 0.035 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_1_2x0p035         = ["1/2x0.035",     "5177K69",  [ 1/2  * 25.4, 0.035 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_1_2x0p049         = ["1/2x0.049",     "5177K71",  [ 1/2  * 25.4, 0.049 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_1_2x0p065         = ["1/2x0.065",     "5177K72",  [ 1/2  * 25.4, 0.065 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_5_8x0p035         = ["5/8x0.035",     "5177K73",  [ 5/8  * 25.4, 0.035 * 25.4], "3003 Al", "seamless",   "soft"];
aluminum_tube_5_8x0p049         = ["5/8x0.049",     "5177K74",  [ 5/8  * 25.4, 0.049 * 25.4], "3003 Al", "seamless",   "soft"];

aluminum_tubes = [aluminum_tube_1_8x0p025, aluminum_tube_3_16x0p028, aluminum_tube_1_4x0p032,
                  aluminum_tube_1_4x0p049, aluminum_tube_5_16x0p035, aluminum_tube_3_8x0p035,
                  aluminum_tube_3_8x0p049, aluminum_tube_7_16x0p035, aluminum_tube_1_2x0p035,
                  aluminum_tube_1_2x0p049, aluminum_tube_1_2x0p065, aluminum_tube_5_8x0p035,
                  aluminum_tube_5_8x0p049];

use <../utils/registries.scad>;
function aluminum_tube_by_name(name) = registry_by_name(aluminum_tubes, name);

function aluminum_tube_name(type)          = type[0];
function aluminum_tube_part_number(type)   = type[1];
function aluminum_tube_od(type)            = type[2][0];
function aluminum_tube_wall(type)          = type[2][1];
function aluminum_tube_material(type)      = type[3];
function aluminum_tube_construction(type)  = type[4];
function aluminum_tube_temper(type)        = type[5];

// derived
function aluminum_tube_id(type) = aluminum_tube_od(type) - 2 * aluminum_tube_wall(type);

// Sold as coils of 10, 25, 50 and 100 ft (not every size in every length), in mm.
function aluminum_tube_coil_lengths() = [10, 25, 50, 100] * 304.8;
