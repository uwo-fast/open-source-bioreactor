// DC axial fans, the rows NopSCADlib carries (fan17x8 to fan120x25): width, depth, hole pitch,
// screw, hub and frame thickness. The library draws them and places the screws; this file only
// names the rows and picks one for a bore, because the library's rows have no name string.
// Nothing here has a part number: any fan of the size fits, so the purchase list names none.
include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/fans.scad>;

function fan_name(type) = str("fan", fan_width(type), "x", fan_depth(type));
function fan_by_name(name) =
  let (_m = [for (f = fans) if (fan_name(f) == name) f]) len(_m) == 1 ? _m[0] : undef;

// The circle the frame's rounded corners sweep: the square less its corner radius, on the
// diagonal, plus the radius back. What a round pocket has to clear, and larger than the
// library's fan_outer_diameter(), which is the blade shroud.
function fan_corner_diameter(type) =
  let (_r = fan_width(type) / 2 - fan_hole_pitch(type))
    2 * sqrt(2) * fan_hole_pitch(type) + 2 * _r;

// The registered fan with the widest hub whose corners clear a bore, whose depth fits, and whose
// hub is at least min_hub across; the thinnest of that hub, or undef if none does. The hub is the
// sort key rather than the frame, because the hub is the face anything mounts to and a wider frame
// around a smaller hub offers none of it. Leave depth undef to ask only what the bore admits.
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
