// parameters for physical realization of peristaltic dosing pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A bought unit - head and motor in one body - inside the catalogue's 67 x 55 x 41 envelope,
// unmeasured. The 67 runs along the motor's axis: the motor below the faceplate, the head the rest.
// Flow, voltage and power are on the purchase list; nothing here doses.

include <dc_motors.scad>

//                        ["name"                part_no          [l,  w,  h ], [tube_id, tube_od], motor       ]
peri_pump_kamoer_nkp   = ["Kamoer NKP-DC-S10B", "NKP-DC-S10B",   [67, 55, 41], [3,       5      ], motor_12v_5w];

peri_pumps = [peri_pump_kamoer_nkp];

use <../utils/registries.scad>;
function peri_pump_by_name(name) = registry_by_name(peri_pumps, name, "sslll");

use <peri_pump.scad>;
