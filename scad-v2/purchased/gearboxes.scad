// parameters for physical realization of various gearboxes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

//                    ["name"       [dia, len], [out_shaft_d, out_shaft_l], [in_shaft_d, in_shaft_l], faceplate_cdist, screw_d]
gearbox_36pg_5p18   = ["36PG-5.18", [36,  26 ], [8,            20         ], [22,         3          ], 27.6,            4.2    ];

gearboxes = [gearbox_36pg_5p18];

use <gearbox.scad>

// example usage (open this file directly to preview)
// gearbox(gearbox_36pg_5p18);
