// parameters for physical realization of various dc motors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability


//        ["name"     [motor_diameter, motor_length], [gearbox_diameter, gearbox_length, gearbox_shaft_diameter, gearbox_shaft_length]]
generic = ["generic", [34,             30],           [36,               26,             8,                      20]];

dc_motors = [generic];

use <dc_motor.scad>
