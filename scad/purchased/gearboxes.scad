// parameters for physical realization of various gearboxes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// out_boss is the pilot boss on the output face (out_shaft_l is the free length beyond it).
// in_boss is the recess in the input face that takes the motor boss. Neither counts toward len.
// ratio is input turns per output turn.

//                        ["name"            [dia, len ], [out_shaft_d, out_shaft_l], [in_shaft_d, in_shaft_l], faceplate_bolt_circle_dia,  screw_d, [out_boss_d, out_boss_l], [in_boss_d, in_boss_l], ratio]
gearbox_36gp_3530_5p18  = ["36GP-3530-5.18", [36,  26  ], [8,           26         ], [2,         8         ],   27.6,                      4.2,     [22,         3         ], [8,         3        ], 5.18 ];

// From the vendor outline drawing: 4-M3 tapped 5 mm deep on a 28 mm circle, 22 mm pilot. The
// D-cut shaft (15 mm flat at 7 across) is not in the schema; only the 8 x 20 round is.
gearbox_36pg_3429_5p2   = ["36PG-3429-5.2",  [36,  26.5], [8,           20         ], [2,         8         ],   28,                        3,       [22,         2         ], [8,         3        ], 5.2  ];

// Same Ø28 faceplate as the 3429, but tapped M4. The 34.5 length is from the 3429 datasheet at
// 14:1; the encoder datasheet gives no length.
gearbox_36pg_555pm_14   = ["36PG-555PM-14",  [36,  34.5], [8,           20         ], [2,         8         ],   28,                        4,       [22,         2         ], [8,         3        ], 14   ];

// The 22 x 2 out_boss is from the E-S outline drawings; the 3 mm on the 36GP is not measured.
// Both 36PG in_boss values are taken from the 36GP motor boss, because the 36PG ships assembled
// and no figure is published.

// 36PG family, from the E-S outline drawings and ratio tables. Gearbox length depends on the
// ratio group, not the motor: 26.5 mm at 3.71 and 5.2, 34.5 mm at 14, 19 and 27, 42.5 mm
// at 51, 100 and 139, 50.5 mm at 264 and 515.
// The 36PG-3429 at 12 V, by ratio, as no-load rpm / rated rpm / rated kg.cm:
//   3.71  1950/1350/0.45     5.2  1400/950/0.65     14  520/360/1.8     19  385/265/2.4
//   27    270/190/3.5        51   140/100/6.5       100 72/50/13.5      139 52/36/18.5
//   264   28/19/34           515  14/10/50

gearboxes = [gearbox_36gp_3530_5p18, gearbox_36pg_3429_5p2, gearbox_36pg_555pm_14];

use <gearbox.scad>
