// parameters for physical realization of peristaltic dosing pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A bought unit - head and motor in one body. Flow, voltage and power are on the purchase list;
// nothing here doses.
//
// [l, w, h]: l is the catalogue's 67 along the motor's axis, terminals included; w x h is the
// faceplate, by calipers, 54.6 x 40.5, which the catalogue rounds to 55 x 41. The frame's spacing
// check reads w.
//
// head: [cover_d, depth, plate_t, [hole_spacing, hole_d], [barb_pitch, barb_od, barb_reach]].
// By calipers: depth, the faceplate's face to the cover's top, 20; plate_t 3; hole_spacing 48,
// which the printed frame mount's screws fit; barb_pitch 18, centre to centre. Estimated from
// photos, until calipers replace them: cover_d, hole_d, barb_od and barb_reach, the barb's tip
// from the motor's axis.

include <dc_motors.scad>

//                        ["name"                part_no          [l,  w,    h   ], [tube_id, tube_od], motor,        head                                     ]
peri_pump_kamoer_nkp   = ["Kamoer NKP-DC-S10B", "NKP-DC-S10B",   [67, 54.6, 40.5], [3,       5      ], motor_12v_5w, [34, 20, 3, [48, 3.5], [18, 3.5, 25]]];

peri_pumps = [peri_pump_kamoer_nkp];

use <../utils/registries.scad>;
function peri_pump_by_name(name) = registry_by_name(peri_pumps, name, "ssllll");

use <peri_pump.scad>;
