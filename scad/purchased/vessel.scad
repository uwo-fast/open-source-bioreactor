/**
 * @file vessel.scad
 * @brief A generic model of a glass blown, open mouth vessel with a neck and optional punt.
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A commodity jar, registered in vessels.scad and read through the accessors below. It is the
 * datum the head and frame are dimensioned against. The cross-section is built by functions so
 * the wetted shape can be read as well as drawn: the culture volume integrates the same points.
 */

use <FunctionalOpenSCAD/functional.scad>;

function vessel_name(type) = type[0]; // the row's own name, unique within the registry
function vessel_height(type) = type[1][0]; // overall height, base to rim
function vessel_diameter(type) = type[1][1]; // outer diameter of the body
function vessel_thickness(type) = type[1][2]; // wall thickness
function vessel_opening_diameter(type) = type[2][0]; // bore of the mouth
function vessel_neck_height(type) = type[2][1]; // height of the straight neck
function vessel_corner_radius(type) = type[3][0]; // shoulder-to-body (upper) corner radius
function vessel_corner_radius_base(type) = type[3][1]; // body-to-base (lower) corner radius
function vessel_punt_height(type) = type[4][0]; // height the punt rises from the base
function vessel_punt_width(type) = type[4][1]; // width/diameter of the punt
// How the glass finishes at the lip:
//   undef  a ground flat lip - the rim is a flat annulus the full width of the wall
//   0      rounded in line with the wall - the glass rolls over and reaches no further out
//   r > 0  a rolled bead standing r proud of the wall's outer face
// Only jar_6p5gal_305x470 is ground; the commodity jars are fire-polished.
function vessel_rim_radius(type) = type[5];

// The rim's arc, one construction for both curved cases: a circle tangent to the bore at the lip,
// topping out at the rim plane, whose diameter is the wall plus the bead. A ground lip returns 0.
function vessel_rim_arc_radius(type) =
  is_undef(vessel_rim_radius(type))
    ? 0
    : (vessel_thickness(type) + vessel_rim_radius(type)) / 2;

// Where the bore's wall stops and the lip's curve takes over. A ground lip runs to the rim plane;
// a curved one stops an arc radius below it, and everything above is the roll.
function vessel_lip_tangent_height(type) =
  vessel_height(type) - vessel_rim_arc_radius(type);

// Where the lip's arc crosses the outer wall plane, which is below its widest point once a bead
// stands proud; the sweep starts there so the neck does not flare to meet it.
// cos = (neck_r - centre_x) / arc_r = (t - rim) / (t + rim).
function vessel_rim_arc_start_angle(type) =
  let (_rim = vessel_rim_radius(type), _t = vessel_thickness(type))
    is_undef(_rim) ? 0 : -acos((_t - _rim) / (_t + _rim));

// True when a generated point of the outer profile lies on both the lip's circle and the wall
// plane - the roll starts where the neck ends. Vacuously true for a ground lip.
function vessel_lip_arc_meets_wall(type) =
  is_undef(vessel_rim_radius(type))
    ? true
    : let (
        _r = vessel_rim_arc_radius(type),
        _c = [vessel_opening_diameter(type) / 2 + _r, vessel_lip_tangent_height(type)],
        _nk = vessel_opening_diameter(type) / 2 + vessel_thickness(type)
      )
        len([
          for (q = vessel_outer_profile(type))
            if (abs(norm(q - _c) - _r) < 1e-4 && abs(q[0] - _nk) < 1e-4) 1
        ]) > 0;

// Internal height available to the shaft and impeller: rim down to the top of the punt.
function vessel_internal_height(type) =
  vessel_height(type) - vessel_punt_height(type) - vessel_thickness(type);

// Shoulder-to-neck corner radius, solved from the registered mouth bore: the mouth sits inboard
// of the outer wall by the shoulder radius plus this, so this is what is left over.
function vessel_neck_corner_radius(type) =
  (vessel_diameter(type) - vessel_opening_diameter(type)) / 2 - vessel_corner_radius(type);

// ----- the cross-section -----
//
// Upright and bottom-up: x is radius, y is height above the outside of the base, the frame
// rotate_extrude() works in. Heights are measured down from the rim, as a jar is dimensioned.
// Each corner is one centre with two radii, R outside and R - t inside.

// Where the straight neck starts, and where the shoulder's inner face tops out under it.
function vessel_neck_bottom(type) = vessel_height(type) - vessel_neck_height(type);
function vessel_shoulder_top(type) = vessel_neck_bottom(type) - vessel_neck_corner_radius(type);

// The three corner centres, shared by inside and outside. The neck curves the other way, so its
// outer radius is the smaller of the pair.
function vessel_base_centre(type) =
  [vessel_diameter(type) / 2 - vessel_corner_radius_base(type), vessel_corner_radius_base(type)];
function vessel_shoulder_centre(type) =
  [
    vessel_diameter(type) / 2 - vessel_corner_radius(type),
    vessel_shoulder_top(type) + vessel_thickness(type) - vessel_corner_radius(type),
  ];
function vessel_neck_centre(type) =
  [vessel_diameter(type) / 2 - vessel_corner_radius(type), vessel_neck_bottom(type)];

// The wetted boundary: axis outward across the floor, up the wall, out at the rim. Straight runs
// are implicit between consecutive points; what is listed is the punt plateau and three arcs.
function vessel_inner_profile(type, arcFn = 64) =
  let (_t = vessel_thickness(type), _floor = _t + vessel_punt_height(type))
    concat(
      [[0, _floor], [vessel_punt_width(type) / 2, _floor]],
      arc(r=vessel_corner_radius_base(type) - _t, angle=90, offsetAngle=270, c=vessel_base_centre(type), $fn=arcFn),
      arc(r=vessel_corner_radius(type) - _t, angle=90, offsetAngle=0, c=vessel_shoulder_centre(type), $fn=arcFn),
      arc(r=vessel_neck_corner_radius(type), angle=-90, offsetAngle=270, c=vessel_neck_centre(type), $fn=arcFn),
      [[vessel_opening_diameter(type) / 2, vessel_lip_tangent_height(type)]]
    );

// The outside, the same way up, ending on the rim. The lip is a half round tangent to the bore
// (see vessel_rim_arc_radius()); a ground lip omits the arc and closes flat across the wall.
function vessel_outer_profile(type, arcFn = 64) =
  let (
    _t = vessel_thickness(type),
    _rim = vessel_rim_radius(type),
    _rim_r = vessel_rim_arc_radius(type),
    _neck_r = vessel_opening_diameter(type) / 2 + _t
  )
    concat(
      [[0, vessel_punt_height(type)], [vessel_punt_width(type) / 2, vessel_punt_height(type)]],
      arc(r=vessel_corner_radius_base(type), angle=90, offsetAngle=270, c=vessel_base_centre(type), $fn=arcFn),
      arc(r=vessel_corner_radius(type), angle=90, offsetAngle=0, c=vessel_shoulder_centre(type), $fn=arcFn),
      arc(r=vessel_neck_corner_radius(type) - _t, angle=-90, offsetAngle=270, c=vessel_neck_centre(type), $fn=arcFn),
      is_undef(_rim)
        ? [[_neck_r, vessel_height(type)]]
        : let (_a0 = vessel_rim_arc_start_angle(type))
            arc(
              r=_rim_r, angle=180 - _a0, offsetAngle=_a0,
              c=[vessel_opening_diameter(type) / 2 + _rim_r, vessel_lip_tangent_height(type)],
              $fn=arcFn
            )
    );

// The closed glass section: up the outside, across the rim, down the inside, home along the axis.
function vessel_section(type, arcFn = 64) =
  concat(vessel_outer_profile(type, arcFn), reverse(vessel_inner_profile(type, arcFn)));

// ----- what the jar holds -----

// The run of a profile below a height, with the crossing point interpolated in rather than the
// segment dropped - a free surface between two points still has to land on the wall.
function vessel_profile_below(profile, y) =
  [
    for (i = [0:len(profile) - 1])
      let (_p = profile[i], _q = profile[i + 1])
        each concat(
          _p[1] <= y ? [_p] : [],
          is_undef(_q) || (_p[1] - y) * (_q[1] - y) >= 0
            ? []
            : [[_p[0] + (_q[0] - _p[0]) * (y - _p[1]) / (_q[1] - _p[1]), y]]
        )
  ];

// The volume a profile sweeps about the axis, mm3. A line integral round the boundary, because
// the floor dishes down from the punt so r(y) is not single valued: each segment contributes
// pi/3 * dy * (r1^2 + r1 r2 + r2^2), and the free surface and the axis contribute nothing.
function vessel_swept_volume(profile) =
  len(profile) < 2
    ? 0
    : let (
      _terms = [
        for (i = [0:len(profile) - 2])
          (profile[i + 1][1] - profile[i][1])
          * (pow(profile[i][0], 2) + profile[i][0] * profile[i + 1][0] + pow(profile[i + 1][0], 2))
      ]
    )
      PI / 3 * (_terms * [for (_t = _terms) 1]);

// Litres held below a height, which is the one place the unit conversion happens.
function vessel_profile_litres(profile, y) =
  vessel_swept_volume(vessel_profile_below(profile, y)) / 1e6;

// A vessel from a registered type; angle < 360 gives a cross section. The rest are rendering
// preferences.
module vessel(
  type,
  angle = 360,
  arcFn = 64,
  rotExtFn = 64,
  show_pts = false,
  show_2d = false,
  show_3d = true,
  pts_r = 1
) {
  assert(
    vessel_neck_corner_radius(type) >= 0,
    str(
      "vessel(): ", vessel_name(type), " has no room for a neck corner — its opening_diameter is too ",
      "large for the given diameter and corner_radius"
    )
  );

  // Asked of the points the profile generates, not of the formula.
  assert(
    vessel_lip_arc_meets_wall(type),
    str("vessel(): ", vessel_name(type), "'s lip arc leaves the wall, flaring the neck to reach it")
  );

  // the inner profile is offset inward by the wall, so a corner tighter than the wall
  // is thickness would invert its arc
  assert(
    vessel_corner_radius(type) > vessel_thickness(type)
      && vessel_corner_radius_base(type) > vessel_thickness(type),
    str("vessel(): ", vessel_name(type), " has a corner radius smaller than its wall thickness")
  );

  // A neck corner tighter than the wall puts the shoulder's outer face above the neck's bottom and
  // the jar carries a notch round the neck root. Expressible, so reported: it is an inconsistency
  // between three measured numbers.
  if (vessel_neck_corner_radius(type) < vessel_thickness(type))
    echo(str(
      "WARNING vessel: ", vessel_name(type), " has a ", vessel_neck_corner_radius(type),
      " mm neck corner inside a ", vessel_thickness(type), " mm wall, so the shoulder's outer face ",
      "tops out ", vessel_thickness(type) - vessel_neck_corner_radius(type),
      " mm above the neck and the outside doubles back to reach it; corner_radius at or under ",
      (vessel_diameter(type) - vessel_opening_diameter(type)) / 2 - vessel_thickness(type),
      " mm clears it (registered ", vessel_corner_radius(type), ")"
    ));

  if (show_pts) {
    color("blue") showPoints(vessel_outer_profile(type, arcFn), r=pts_r, $fn=16);
    color("orange") showPoints(vessel_inner_profile(type, arcFn), r=pts_r, $fn=16);
  }

  if (show_2d)
    color("Aqua") poly2d(vessel_section(type, arcFn));

  if (show_3d)
    color("Azure", 0.5)
      poly3d(rotate_extrude(angle=angle, poly=vessel_section(type, arcFn), $fn=rotExtFn));
}
