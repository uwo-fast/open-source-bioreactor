// parameters for physical realization of various dc motors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

include <gearboxes.scad>

//        ["name"     [motor_dia, motor_len], shaft,  gearbox]
generic = ["generic", [34,        30],        undef,  generic_gearbox];

dc_motors = [generic];

use <dc_motor.scad>

// example usage (open this file directly to preview)
// dc_motor(generic);
