// parameters for physical realization of various thermocouple probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability


//        ["name"     [neck_diameter, neck_height, flats_diameter, flats_height, body_diameter, body_height, tip_diameter, tip_height, wire_diameter, wire_height]]
generic = ["generic", [10,            12,          26,             5,            21,            20,          3.5,          115,        3,             10         ]];

thermocouple_probes = [generic];

use <thermocouple_probe.scad>

// example usage (open this file directly to preview)
// thermocouple_probe(generic);     // registered set
// translate([45, 0, 0])            // direct (inline type)
//   thermocouple_probe(["custom", [10, 12, 26, 5, 18, 20, 3.5, 130, 3, 10]], position_base=true);