// parameters for physical realization of various dc motors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

include <gearboxes.scad>

//                 ["name"     [motor_dia, motor_len], shaft,  gearbox]
generic_dc_motor = ["generic", [34,        30],        undef,  generic_gearbox];

dc_motors = [generic_dc_motor];

use <dc_motor.scad>

// example usage (open this file directly to preview)
// dc_motor(generic_dc_motor);
