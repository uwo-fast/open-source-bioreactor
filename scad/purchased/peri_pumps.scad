// parameters for physical realization of peristaltic dosing pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A bought unit - head and motor in one body - inside the catalogue's 67 x 55 x 41 envelope. The 67
// runs along the motor's axis: the motor below the faceplate, the head the rest. Flow, voltage and
// power are on the purchase list; nothing here doses.
//
// head: what peri_pump() draws the head from, [cover_d, plate_t, [hole_spacing, hole_d],
// [barb_pitch, barb_od, barb_reach]]. cover_d is a caliper reading, 27.99. Every other figure is
// estimated from photos scaled off it, until calipers replace it; the envelope stays the
// catalogue's, which the frame's spacing check reads, and the drawing sits inside it.

include <dc_motors.scad>

//                        ["name"                part_no          [l,  w,  h ], [tube_id, tube_od], motor,        head                                 ]
peri_pump_kamoer_nkp   = ["Kamoer NKP-DC-S10B", "NKP-DC-S10B",   [67, 55, 41], [3,       5      ], motor_12v_5w, [28, 2.5, [40, 3], [15, 3.5, 23]]];

peri_pumps = [peri_pump_kamoer_nkp];

use <../utils/registries.scad>;
function peri_pump_by_name(name) = registry_by_name(peri_pumps, name, "ssllll");

use <peri_pump.scad>;
