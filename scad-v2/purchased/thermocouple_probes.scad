// parameters for physical realization of various thermocouple probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability


//                           ["name"               [neck_diameter, neck_height, flats_diameter, flats_height, body_diameter, body_height, tip_diameter, tip_height, wire_diameter, wire_height]]
generic_thermocouple_probe = ["generic",           [10,            12,          26,             5,            21,            20,          3.5,          115,        3,             10         ]];

// McMaster-Carr 3872K117: Type K, 1/2 NPT male, 9 in x 1/8 in probe, 4 ft fiberglass cable.
// Probe diameter and length are from the vendor listing; fitting dimensions remain approximate
// CAD clearances until the hex/threaded body are measured directly.
mcmaster_3872K117_thermocouple_probe = ["mcmaster_3872K117", [10,            12,          26,             5,            21.3,          20,          3.175,        228.6,      3,             25         ]];

thermocouple_probes = [generic_thermocouple_probe, mcmaster_3872K117_thermocouple_probe];

use <thermocouple_probe.scad>

// example usage (open this file directly to preview)
thermocouple_probe(generic_thermocouple_probe);     // registered set
translate([45, 0, 0])            // direct (inline type)
  thermocouple_probe(mcmaster_3872K117_thermocouple_probe, position_base=true);
