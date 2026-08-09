// parameters for physical realization of various strip lights
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// All four are USB grow light bars of the same extrusion - the primary difference is length,
// with widths varying by a couple of tenths. Depth and front radius are the RWNTAO caliper
// readings, reused across the rows because only length and width were measured on the others.
// Lights per cord is recorded per row below but not registered; see TODO.md.

//                    ["name"         [width, depth, length, radius]];
generic_strip_light = ["generic",     [14.2,  7.6,   330,    0.5   ]];

// RWNTAO 13" 3000K full spectrum, 3 tubes per cord, 144 LEDs, dimmable + timer
// https://a.co/d/0b8s8zok
rwntao_13in         = ["RWNTAO 13in", [14.1,  7.6,   330,    0.5   ]];

// 13" 3000K full spectrum, 4 heads per cord, 192 LEDs, 10 dim levels, 3/9/12 h timer
// https://a.co/d/0gtCMpYn
grow_13in           = ["grow 13in",   [14.25, 7.6,   330,    0.5   ]];

// 16" 6000K full spectrum 15 W, 4 bars per cord, 240 LEDs, 5 dim levels, 6/12/16 h timer
// https://a.co/d/09IYjYsa
grow_16in           = ["grow 16in",   [14.30, 7.6,   400,    0.5   ]];

// 8.6" 3500K full spectrum, 4 bars per cord, 208 LEDs, 10 dim levels, 3/9/12 h timer
// https://a.co/d/05kAUpe1
grow_8p6in          = ["grow 8.6in",  [14.15, 7.6,   217,    0.5   ]];

strip_lights = [rwntao_13in, grow_13in, grow_16in, grow_8p6in];

use <strip_light.scad>

// example usage - keep commented, this file is include'd and would emit the lights into
// every consumer
// strip_light(rwntao_13in);                                             // registered set
// translate([30, 0, 0]) strip_light(["custom", [14.1, 7.6, 200, 0.5]]); // direct (inline type)
