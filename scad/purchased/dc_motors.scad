// parameters for physical realization of various dc motors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

include <gearboxes.scad>

// shaft and boss belong to the bare motor, without a gearbox. Speeds are at the gearbox OUTPUT. A
// catalogue speed with no qualifier is taken as the no-load speed. rated is the speed at
// rated_out_torque (N m, converted from the datasheet kg.cm). encoder is [ppr, channels], with
// ppr per channel at the motor shaft.

//                        ["name"              [dia,  len ], [shaft_d, shaft_l], gearbox,               [boss_d, boss_l], [screw_cdist, screw_d], [no_load_out_rpm, rated_out_rpm], rated_out_torque, encoder,  part_no]
// The motor on the bench; discontinued. Speed is the highest 12 V speed listed, taken as no-load.
motor_36gp_3530_5p18    = ["36GP-3530-5.18",   [34,   30  ], [2,       8      ], gearbox_36gp_3530_5p18,     [8,      3     ], undef,                  [1154,            undef        ], undef,  undef,   undef        ]; // discontinued, no number published
// E-S Motor 36D, RobotShop RM-ESMO-16Q, from the datasheet.
motor_36pg_3429_5p2     = ["36PG-3429-5.2",    [34,   29.4], [2,       8      ], gearbox_36pg_3429_5p2, [8,      3     ], undef,                  [1400,            950          ], 0.0637, undef,   "RM-ESMO-16Q"];
// E-S Motor 36D with encoder, RobotShop RM-ESMO-071, the drive for the next build. Six flying
// leads: M1/M2 and encoder GND, A, B, Vcc. len is the overall length of 57 from the datasheet.
motor_36pg_555pm_14_en  = ["36PG-555PM-14-EN", [36,   57  ], [2,       8      ], gearbox_36pg_555pm_14, [8,      3     ], undef,                  [420,             320          ], 0.4903, [12, 2], "RM-ESMO-071"];
// bare motor supplied on the peri pump head, no part number, 12 V / 5 W, no published speed
motor_12v_5w            = ["12v_5w",           [27.5, 38  ], [2.3,     20     ], undef,                 [10,     3     ], [15.75,       2      ], undef,                            undef,  undef,   undef        ]; // arrives fitted to the pump head

// Two rows cannot be ordered (one is discontinued, one arrives fitted to the pump head). They stay
// in the list because the parts exist.
dc_motors = [motor_36gp_3530_5p18, motor_36pg_3429_5p2, motor_36pg_555pm_14_en, motor_12v_5w];

use <../utils/registries.scad>;
function dc_motor_by_name(name) = registry_by_name(dc_motors, name, "sllLLLLNLS");

use <dc_motor.scad>

// example usage (open this file directly to preview)
// dc_motor(motor_36gp_3530_5p18);
