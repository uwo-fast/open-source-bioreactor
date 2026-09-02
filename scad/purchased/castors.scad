// parameters for physical realization of various swivel plate castors
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

//               ["name"     [plate_x, plate_y, bolt_dx, bolt_dy, bolt_dia, plate_thick, mount_height, wheel_dia, wheel_width, swivel_offset]]
generic_castor = ["generic", [60,      60,      46,      46,      6,        4,           75,           50,        22,          18           ]];

// PRE-REGISTRY. generic_castor is a placeholder, not a product - no source, no part number - so by
// the swept-list rule it does not belong here. It stays because removing it would leave the list
// empty, and registering a real castor would decide a purchase nobody has scoped. cart.scad is
// outside the main build (see MESH_SKIP and the reactor assembly), so nothing waits on it.
castors = [generic_castor];

use <castor.scad>

// example usage (open this file directly to preview)
// castor(generic_castor);                                                          // registered set
// translate([90, 0, 0]) castor(["custom", [70, 70, 54, 54, 8, 5, 100, 75, 32, 24]]); // direct (inline type)
