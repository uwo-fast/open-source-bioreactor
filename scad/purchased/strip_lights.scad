// parameters for physical realization of various strip lights
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// All four are USB grow light bars of the same extrusion, differing in length. Depth and front
// radius are the RWNTAO caliper readings, reused across the rows. per_cord is packaging - one cord
// and controller drives a fixed number - and decides what you buy, never how many the frame carries.

//                    ["name"         [width, depth, length, radius], per_cord];
generic_strip_light = ["generic",     [14.2,  7.6,   330,    0.5   ], 1       ];

// RWNTAO 13" 3000K full spectrum, 3 tubes per cord, 144 LEDs, dimmable + timer
// https://a.co/d/0b8s8zok
rwntao_13in         = ["RWNTAO 13in", [14.1,  7.6,   330,    0.5   ], 3       ];

// 13" 3000K full spectrum, 4 heads per cord, 192 LEDs, 10 dim levels, 3/9/12 h timer
// https://a.co/d/0gtCMpYn
grow_13in           = ["grow 13in",   [14.25, 7.6,   330,    0.5   ], 4       ];

// 16" 6000K full spectrum 15 W, 4 bars per cord, 240 LEDs, 5 dim levels, 6/12/16 h timer
// https://a.co/d/09IYjYsa
grow_16in           = ["grow 16in",   [14.30, 7.6,   400,    0.5   ], 4       ];

// 8.6" 3500K full spectrum, 4 bars per cord, 208 LEDs, 10 dim levels, 3/9/12 h timer
// https://a.co/d/05kAUpe1
grow_8p6in          = ["grow 8.6in",  [14.15, 7.6,   217,    0.5   ], 4       ];

strip_lights = [rwntao_13in, grow_13in, grow_16in, grow_8p6in];

// The shortest registered light that still covers the culture, or the longest if none does. A
// light taller than the vessel drops the frame's base by the overhang, so shortest-that-covers.
function strip_light_for(liquid_height) =
  let (
    _covering = [for (l = strip_lights) if (strip_light_length(l) >= liquid_height) strip_light_length(l)],
    _target = len(_covering) > 0 ? min(_covering) : max([for (l = strip_lights) strip_light_length(l)]),
    _match = [for (l = strip_lights) if (strip_light_length(l) == _target) l]
  ) _match[0];

use <strip_light.scad>

use <../utils/registries.scad>;
function strip_light_by_name(name) = registry_by_name(strip_lights, name);

// example usage - keep commented, this file is include'd
// strip_light(rwntao_13in);
