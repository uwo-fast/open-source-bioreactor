// DC axial fans from the NopSCADlib rows (fan17x8 to fan120x25): width, depth, hole pitch, screw,
// hub and frame thickness. The library draws them and places the screws. This file names the rows,
// because the library rows have no name string, and selects one for a given bore. No part
// numbers: any fan of the right size fits, so the purchase list names none.
include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/fans.scad>;

function fan_name(type) = str("fan", fan_width(type), "x", fan_depth(type));
use <../utils/registries.scad>;
// the library rows have no name, so they are checked here and named by size
function fan_by_name(name) =
  let (_m = [for (f = registry_checked(fans, "nnnnlnnnnnN")) if (fan_name(f) == name) f]) len(_m) == 1 ? _m[0] : undef;

// Diameter of the circle swept by the rounded frame corners: twice the diagonal distance to a
// corner-arc centre, plus twice the corner radius. A round pocket has to clear this. It is larger
// than the library's fan_outer_diameter(), which is the blade shroud.
function fan_corner_diameter(type) =
  let (_r = fan_width(type) / 2 - fan_hole_pitch(type))
    2 * sqrt(2) * fan_hole_pitch(type) + 2 * _r;

// Returns a registered fan whose corners clear the bore, whose depth fits, and whose hub is at
// least min_hub across. Of those, it picks the widest hub, then the thinnest fan with that hub,
// or undef if none fits. The hub is the sort key rather than the frame because parts mount to the
// hub face, and a wider frame around a smaller hub adds no mounting face. Leave depth undef to
// limit the choice by the bore only.
function fan_for(bore_diameter, depth = undef, min_hub = 0) =
  let (
    _fits = [
      for (f = fans)
        if (fan_corner_diameter(f) <= bore_diameter
            && (is_undef(depth) || fan_depth(f) <= depth)
            && fan_hub(f) >= min_hub) f
    ],
    _widest = len(_fits) == 0 ? undef : max([for (f = _fits) fan_hub(f)]),
    _hubbed = [for (f = _fits) if (fan_hub(f) == _widest) f],
    _thinnest = len(_hubbed) == 0 ? undef : min([for (f = _hubbed) fan_depth(f)]),
    _match = [for (f = _hubbed) if (fan_depth(f) == _thinnest) f]
  ) len(_match) == 0 ? undef : _match[0];
