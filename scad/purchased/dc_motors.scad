// parameters for physical realization of various dc motors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

include <gearboxes.scad>

// shaft and boss are the motor's own, measured with any gearbox removed

// speeds are at the OUTPUT, i.e. past the gearbox, which is the side vendors publish for an
// assembled gearmotor. No-load and rated are different facts and are kept apart on purpose: rated
// is the speed at rated torque, no-load is the ceiling with nothing on the shaft, and the two are
// ~1.5x apart here. Vendors name their variants by the no-load figure, so an unqualified catalogue
// speed is a no-load speed. Multiply by the gearbox ratio for the motor's own speed.

//                        ["name"            [dia,  len ], [shaft_d, shaft_l], gearbox,               [boss_d, boss_l], [screw_cdist, screw_d], [no_load_out_rpm, rated_out_rpm]]
// the motor currently on the bench; no longer available to order. The listing gives ten selectable
// 12 V speeds and this is the top one, unqualified, so it is taken as no-load; no rated figure is
// published. See docs/procurement.md for the URL.
motor_36gp_3530_5p18    = ["36GP-3530-5.18", [34,   30  ], [2,       8      ], gearbox_36gp_5p18,     [8,      3     ], undef,                  [1154,            undef        ]];
// E-S Motor 36D, RobotShop RM-ESMO-16Q, replacing the above on the next build. Sold as an
// assembled gearmotor, so the bare motor's own shaft and boss are not published. Speeds, ratio and
// every dimension above are the vendor's datasheet.
motor_36pg_3429_5p2     = ["36PG-3429-5.2",  [34,   29.4], [2,       8      ], gearbox_36pg_3429_5p2, [8,      3     ], undef,                  [1400,            950          ]];
// bare motor supplied on the peri pump head, no part number, 12 V / 5 W, no published speed
motor_12v_5w            = ["12v_5w",         [27.5, 38  ], [2.3,     20     ], undef,                 [10,     3     ], [15.75,       2      ], undef                            ];

dc_motors = [motor_36gp_3530_5p18, motor_36pg_3429_5p2, motor_12v_5w];

use <dc_motor.scad>

// example usage (open this file directly to preview)
// dc_motor(motor_36gp_3530_5p18);
