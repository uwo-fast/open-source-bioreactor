// parameters for physical realization of various dc motors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

include <gearboxes.scad>

// shaft and boss are the motor's own, measured with any gearbox removed

//                        ["name"            [dia,  len ], [shaft_d, shaft_l], gearbox,               [boss_d, boss_l], [screw_cdist, screw_d]]
// the motor currently on the bench; no longer available to order
motor_36gp_3530_5p18    = ["36GP-3530-5.18", [34,   30  ], [2,       8      ], gearbox_36gp_5p18,     [8,      3     ], undef                 ];
// E-S Motor 36D, RobotShop RM-ESMO-16Q, replacing the above on the next build. Sold as an
// assembled gearmotor, so the bare motor's own shaft and boss are not published.
motor_36pg_3429_5p2     = ["36PG-3429-5.2",  [34,   29.4], [2,       8      ], gearbox_36pg_3429_5p2, [8,      3     ], undef                 ];
// bare motor supplied on the peri pump head, no part number, 12 V / 5 W
motor_12v_5w            = ["12v_5w",         [27.5, 38  ], [2.3,     20     ], undef,                 [10,     3     ], [15.75,       2      ]];

dc_motors = [motor_36gp_3530_5p18, motor_36pg_3429_5p2, motor_12v_5w];

use <dc_motor.scad>

// example usage (open this file directly to preview)
// dc_motor(motor_36gp_3530_5p18);
