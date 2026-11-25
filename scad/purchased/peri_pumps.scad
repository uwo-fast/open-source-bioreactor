// parameters for physical realization of peristaltic dosing pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A purchased unit, with head and motor in one body. Flow, voltage and power are on the purchase
// list; nothing in this model computes dosing.
//
// [l, w, h]: l is the catalogue 67 along the motor axis, terminals included. w x h is the
// faceplate, measured with calipers at 54.6 x 40.5 (the catalogue rounds to 55 x 41). The frame
// spacing check reads w.
//
// head: [cover_d, depth, plate_t, [hole_spacing, hole_d], [barb_pitch, barb_od, barb_reach]].
// Measured with calipers: depth (faceplate face to top of cover) 20, plate_t 3, hole_spacing 48
// (the screws of the printed frame mount fit it), and barb_pitch 18 centre to centre. Estimated
// from photos until measured: cover_d, hole_d, barb_od, and barb_reach (motor axis to barb tip).

include <dc_motors.scad>

//                        ["name"                part_no          [l,  w,    h   ], [tube_id, tube_od], motor,        head                                     ]
peri_pump_kamoer_nkp   = ["Kamoer NKP-DC-S10B", "NKP-DC-S10B",   [67, 54.6, 40.5], [3,       5      ], motor_12v_5w, [34, 20, 3, [48, 3.5], [18, 3.5, 25]]];

peri_pumps = [peri_pump_kamoer_nkp];

use <../utils/registries.scad>;
function peri_pump_by_name(name) = registry_by_name(peri_pumps, name, "ssllll");

use <peri_pump.scad>;
