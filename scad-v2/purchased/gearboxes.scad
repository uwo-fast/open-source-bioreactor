// parameters for physical realization of various gearboxes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// faceplate_cdist is the bolt-circle diameter, not a span between two screws: gearbox() and
// motor_mount() both place the holes at faceplate_cdist / 2 from the axis.

//                        ["name"           [dia, len ], [out_shaft_d, out_shaft_l], [in_shaft_d, in_shaft_l], faceplate_cdist,  screw_d]
gearbox_36gp_5p18       = ["36GP-5.18",     [36,  26  ], [8,           20         ], [2,         8         ],   27.6,            4.2    ];

// Carried by motor_36pg_3429_5p2. From the vendor outline drawing: 4-M3 tapped 5 mm deep on a
// 28 mm bolt circle, with a 22 mm pilot register around the output shaft. That shaft is D-cut,
// 15 mm of flat at 7 mm across; the schema carries no flat, so only the 8 x 20 round is here.
gearbox_36pg_3429_5p2   = ["36PG-3429-5.2", [36,  26.5], [8,           20         ], [2,         8         ],   28,              3      ];

gearboxes = [gearbox_36gp_5p18, gearbox_36pg_3429_5p2];

use <gearbox.scad>

// example usage (open this file directly to preview)
gearbox(gearbox_36gp_5p18);
