// parameters for physical realization of various swivel plate castors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

//               ["name"     [plate_x, plate_y, bolt_dx, bolt_dy, bolt_dia, plate_thick, mount_height, wheel_dia, wheel_width, swivel_offset]]
generic_castor = ["generic", [60,      60,      46,      46,      6,        4,           75,           50,        22,          18           ]];

// generic_castor is a placeholder; no real castor has been scoped, and only the cart uses it.
castors = [generic_castor];

use <castor.scad>
