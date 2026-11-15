// parameters for physical realization of various gearboxes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// out_boss is the pilot register standing off the output face (out_shaft_l is free length past
// it); in_boss is the recess in the input face that receives the motor's boss. Neither counts
// toward len. ratio is input turns per output turn.

//                        ["name"            [dia, len ], [out_shaft_d, out_shaft_l], [in_shaft_d, in_shaft_l], faceplate_bolt_circle_dia,  screw_d, [out_boss_d, out_boss_l], [in_boss_d, in_boss_l], ratio]
gearbox_36gp_3530_5p18  = ["36GP-3530-5.18", [36,  26  ], [8,           26         ], [2,         8         ],   27.6,                      4.2,     [22,         3         ], [8,         3        ], 5.18 ];

// From the vendor outline drawing: 4-M3 tapped 5 mm deep on a 28 mm circle, 22 mm pilot. The
// D-cut shaft (15 mm flat at 7 across) is not in the schema; only the 8 x 20 round is.
gearbox_36pg_3429_5p2   = ["36PG-3429-5.2",  [36,  26.5], [8,           20         ], [2,         8         ],   28,                        3,       [22,         2         ], [8,         3        ], 5.2  ];

// Same Ø28 faceplate as the 3429 but tapped M4. 34.5 is the 3429 sheet's length at 14:1; the
// encoder sheet tabulates none.
gearbox_36pg_555pm_14   = ["36PG-555PM-14",  [36,  34.5], [8,           20         ], [2,         8         ],   28,                        4,       [22,         2         ], [8,         3        ], 14   ];

// The 22 x 2 out_boss is off the E-S outline drawings; the 36GP's 3 mm is unmeasured. Both
// in_bosses are taken from the 36GP's own boss - the 36PG ships assembled and publishes none.

// 36PG family, from the E-S outline drawings and ratio tables. Gearbox length goes with the
// ratio group, not with the motor: 26.5 mm at 3.71 and 5.2, 34.5 mm at 14, 19 and 27, 42.5 mm
// at 51, 100 and 139, 50.5 mm at 264 and 515.
// The 36PG-3429 at 12 V, by ratio, as no-load rpm / rated rpm / rated kg.cm:
//   3.71  1950/1350/0.45     5.2  1400/950/0.65     14  520/360/1.8     19  385/265/2.4
//   27    270/190/3.5        51   140/100/6.5       100 72/50/13.5      139 52/36/18.5
//   264   28/19/34           515  14/10/50

gearboxes = [gearbox_36gp_3530_5p18, gearbox_36pg_3429_5p2, gearbox_36pg_555pm_14];

use <gearbox.scad>
