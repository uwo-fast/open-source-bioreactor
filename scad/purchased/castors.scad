// parameters for physical realization of various swivel plate castors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

//               ["name"     [plate_x, plate_y, bolt_dx, bolt_dy, bolt_dia, plate_thick, mount_height, wheel_dia, wheel_width, swivel_offset]]
generic_castor = ["generic", [60,      60,      46,      46,      6,        4,           75,           50,        22,          18           ]];

castors = [generic_castor];

use <castor.scad>

// example usage (open this file directly to preview)
// castor(generic_castor);                                                          // registered set
// translate([90, 0, 0]) castor(["custom", [70, 70, 54, 54, 8, 5, 100, 75, 32, 24]]); // direct (inline type)
