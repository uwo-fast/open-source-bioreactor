// parameters for physical realization of various dc motors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

include <gearboxes.scad>

// shaft and boss are the motor's own, measured with any gearbox removed

// speeds are at the OUTPUT, i.e. past the gearbox, which is the side vendors publish for an
// assembled gearmotor. No-load and rated are different facts and are kept apart on purpose: rated
// is the speed at rated torque, no-load is the ceiling with nothing on the shaft, and the two are
// ~1.5x apart here. Vendors name their variants by the no-load figure, so an unqualified catalogue
// speed is a no-load speed. Multiply by the gearbox ratio for the motor's own speed.

// rated_out_torque is the torque rated speed is quoted at, in N m. The sheets give kg.cm; it is
// converted here so nothing downstream has to.

//                        ["name"              [dia,  len ], [shaft_d, shaft_l], gearbox,               [boss_d, boss_l], [screw_cdist, screw_d], [no_load_out_rpm, rated_out_rpm], rated_out_torque]
// the motor currently on the bench; no longer available to order. The listing gives ten selectable
// 12 V speeds and this is the top one, unqualified, so it is taken as no-load; no rated figure is
// published. See docs/procurement.md for the URL.
motor_36gp_3530_5p18    = ["36GP-3530-5.18",   [34,   30  ], [2,       8      ], gearbox_36gp_5p18,     [8,      3     ], undef,                  [1154,            undef        ], undef ];
// E-S Motor 36D, RobotShop RM-ESMO-16Q. Sold as an assembled gearmotor, so the bare motor's own
// shaft and boss are not published. Speeds, ratio and every dimension above are the vendor's
// datasheet. Rated 950 rpm is 4.70 m/s at the tip on this impeller, well past the band, so it is
// registered as a product rather than as a candidate - see docs/agitation.md.
motor_36pg_3429_5p2     = ["36PG-3429-5.2",    [34,   29.4], [2,       8      ], gearbox_36pg_3429_5p2, [8,      3     ], undef,                  [1400,            950          ], 0.0637];
// E-S Motor 36D with encoder, RobotShop RM-ESMO-071, the drive for the next build. Magnetic, two
// channels, 12 PPR at the motor shaft. The encoder is not registered here yet and nothing reads
// it; len is the sheet's overall 57, which is not separately dimensioned past the can.
motor_36pg_555pm_14_en  = ["36PG-555PM-14-EN", [36,   57  ], [2,       8      ], gearbox_36pg_555pm_14, [8,      3     ], undef,                  [420,             320          ], 0.4903];
// bare motor supplied on the peri pump head, no part number, 12 V / 5 W, no published speed
motor_12v_5w            = ["12v_5w",           [27.5, 38  ], [2.3,     20     ], undef,                 [10,     3     ], [15.75,       2      ], undef,                            undef ];

dc_motors = [motor_36gp_3530_5p18, motor_36pg_3429_5p2, motor_36pg_555pm_14_en, motor_12v_5w];

use <dc_motor.scad>

// example usage (open this file directly to preview)
// dc_motor(motor_36gp_3530_5p18);
