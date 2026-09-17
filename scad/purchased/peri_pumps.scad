// parameters for physical realization of peristaltic dosing pumps
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// A bought unit - head, motor and gearbox in one body - drawn as the catalogue's 67 x 55 x 41
// envelope, unmeasured. Flow, voltage and power are on the purchase list; nothing here doses.
// custom/peri_pump_head.scad is a printed head of our own, a stretch goal, with its own prefix.

//                        ["name"                part_no          [l,  w,  h ], [tube_id, tube_od]]
peri_pump_kamoer_nkp   = ["Kamoer NKP-DC-S10B", "NKP-DC-S10B",   [67, 55, 41], [3,       5      ]];

peri_pumps = [peri_pump_kamoer_nkp];

use <../utils/registries.scad>;
function peri_pump_by_name(name) = registry_by_name(peri_pumps, name);

use <peri_pump.scad>;
