// parameters for physical realization of various strip lights
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// All four are USB grow light bars of the same extrusion - the primary difference is length,
// with widths varying by a couple of tenths. Depth and front radius are the RWNTAO caliper
// readings, reused across the rows because only length and width were measured on the others.

// PER CORD IS PACKAGING, NOT GEOMETRY, and it is registered because it decides what you buy. These
// are not sold as tubes: one cord and controller drives a fixed number of them, so a design wanting
// seven of a three-per-cord light buys nine and wires three controllers. Nothing else in this file
// is a purchasing fact, which is why it sits outside the dimension vector rather than inside it.
//
// It does NOT decide how many lights the frame carries, and the arrow only points one way. How much
// light the culture gets is an illumination question; how it is packaged is the shop's answer to a
// question nobody asked. frame() reports the cords a layout needs and leaves the layout alone.

//                    ["name"         [width, depth, length, radius], per_cord];
// One per cord, because a generic light is a single tube with no packaging behind it to record.
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

// The shortest registered light that still covers the culture, falling back to the longest if none
// does. Shortest-that-covers rather than longest-available because a light taller than the vessel
// is not free: frame_floor_depth() drops the base by whatever the light overhangs, and a 330 mm
// strip on a 197 mm jar bought 152 mm of empty base. Covering the LIQUID rather than the jar is the
// point - the light is what the reactor is for, so under-covering is the one thing not to trade.
//
// Lives here rather than with the accessors in strip_light.scad because a function resolves globals
// from its own file, and `strip_lights` is only in scope in this one.
function strip_light_for(liquid_height) =
  let (
    _covering = [for (l = strip_lights) if (strip_light_length(l) >= liquid_height) strip_light_length(l)],
    _target = len(_covering) > 0 ? min(_covering) : max([for (l = strip_lights) strip_light_length(l)]),
    _match = [for (l = strip_lights) if (strip_light_length(l) == _target) l]
  ) _match[0];

use <strip_light.scad>

use <../utils/registries.scad>;
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function strip_light_by_name(name) = registry_by_name(strip_lights, name);

// example usage - keep commented, this file is include'd and would emit the lights into
// every consumer
// strip_light(rwntao_13in);                                             // registered set
// translate([30, 0, 0]) strip_light(["custom", [14.1, 7.6, 200, 0.5]]); // direct (inline type)
