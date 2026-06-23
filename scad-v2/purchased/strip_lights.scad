// parameters for physical realization of various strip lights
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

//                    ["name"     [width, depth, length, radius]]
generic_strip_light = ["generic", [14.1,   7.6,    336,   0.5  ]];

strip_lights = [generic_strip_light];

use <strip_light.scad>

// example usage (open this file directly to preview)
// strip_light(generic_strip_light);                                                // registered set
// translate([30, 0, 0]) strip_light(["custom", [14.1, 7.6, 200, 0.5]]); // direct (inline type)