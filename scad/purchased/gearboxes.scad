// parameters for physical realization of various gearboxes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// out_boss is the pilot register standing off the output face. It is additive, so the output
// shaft sits on top of it and out_shaft_l stays free length past the boss rather than being
// eaten into. in_boss is the matching recess in the input face that receives the motor's own
// boss, and the input shaft bore is sunk past it by that depth. Both are optional, and neither
// counts toward len, which stays the body length.

// ratio is the reduction, output turns per input turn inverted: 5.18 means 5.18 input turns per
// output turn. The name string carries it too, but a name cannot be computed with.

//                        ["name"           [dia, len ], [out_shaft_d, out_shaft_l], [in_shaft_d, in_shaft_l], faceplate_bolt_circle_dia,  screw_d, [out_boss_d, out_boss_l], [in_boss_d, in_boss_l], ratio]
gearbox_36gp_5p18       = ["36GP-5.18",     [36,  26  ], [8,           20         ], [2,         8         ],   27.6,                      4.2,     [22,         3         ], [8,         3        ], 5.18 ];

// Carried by motor_36pg_3429_5p2. From the vendor outline drawing: 4-M3 tapped 5 mm deep on a
// 28 mm bolt circle, with a 22 mm pilot register around the output shaft. That shaft is D-cut,
// 15 mm of flat at 7 mm across; the schema carries no flat, so only the 8 x 20 round is here.
gearbox_36pg_3429_5p2   = ["36PG-3429-5.2", [36,  26.5], [8,           20         ], [2,         8         ],   28,                        3,       [22,         3         ], [8,         3        ], 5.2  ];

// Both bosses are the 36GP's: the 22 out_boss is the pilot register the drawing gives for the
// 36PG and the same feature on the 36GP, and the 8 x 3 in_boss is taken from
// motor_36gp_3530_5p18's boss. The 36PG ships assembled and publishes neither, so its pair is
// carried over rather than measured.

gearboxes = [gearbox_36gp_5p18, gearbox_36pg_3429_5p2];

use <gearbox.scad>

// example usage (open this file directly to preview)
//gearbox(gearbox_36gp_5p18);
