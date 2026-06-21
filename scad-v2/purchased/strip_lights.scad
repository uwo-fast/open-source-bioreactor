// parameters for physical realization of various strip lights
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

//        ["name"     [width, depth, length, radius]]
generic = ["generic", [14.1,   7.6,    336,   0.5  ]];

strips_lights = [generic];

use <strip_light.scad>

// Usage: 
//    strip_light(width, depth, length, radius)
//    or
//    strip_light(name)