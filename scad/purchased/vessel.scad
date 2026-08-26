/**
 * @file vessel.scad
 * @brief A generic model of a glass blown, open mouth vessel with a neck and optional punt.
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The vessel is a purchased part (a commodity jar), so its physical dimensions are
 * registered in vessels.scad and read back through the accessors below. It is also the
 * datum the head and frame are dimensioned against; assembly.scad selects a registered
 * vessel and passes the coupling scalars (diameter, opening diameter, height, internal
 * height) on to the other subassemblies via these accessors.
 *
 * The cross-section is built by the functions below rather than inside vessel(), so the wetted
 * shape can be READ as well as drawn: utils/stirred_tank.scad integrates the same points this
 * module revolves. A culture volume that disagreed with the jar holding it would otherwise be
 * invisible, which is what a cylinder standing in for the profile had been.
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
function vessel_rim_radius(type) = type[5]; // radius of the rim roll

/**
 * @brief Internal height available to the shaft and impeller: rim down to the top of the punt.
 *
 * Derived, not registered — the head needs it to position the impeller and to size the
 * motor mount, and deriving it here keeps that arithmetic out of assembly.scad.
 */
function vessel_internal_height(type) =
  vessel_height(type) - vessel_punt_height(type) - vessel_thickness(type);

/**
 * @brief Shoulder-to-neck corner radius, solved from the registered mouth bore.
 *
 * The neck profile places the mouth inboard of the outer wall by the shoulder corner
 * radius plus the neck corner radius on each side, so the neck radius is whatever is
 * left over. Wall thickness cancels out of the neck-flat point and is intentionally
 * absent. Registering the measured opening and solving this radius (rather than the
 * reverse) keeps the registry holding facts and derives the eyeballed value.
 */
function vessel_neck_corner_radius(type) =
  (vessel_diameter(type) - vessel_opening_diameter(type)) / 2 - vessel_corner_radius(type);

// ----- the cross-section -----
//
// UPRIGHT AND BOTTOM-UP. x is radius and y is height above the outside of the base, which is the
// frame rotate_extrude() works in and the only frame a volume can be integrated in. The section
// used to be authored MOUTH-DOWN on the -x side and flipped at the end by a 180 degree rotation,
// so every coordinate carried the sign of that flip and the neck was hung off a rectangle that
// then had to give back the height it added. That correction - body_height - is gone: the heights
// below are measured DOWN FROM THE RIM, which is how a jar is dimensioned in the first place.
//
// Each corner is ONE centre with two radii, R outside and R - t inside, because the wall is a
// constant offset. The previous version rounded two rectangles independently and recovered each
// corner's direction by dividing a coordinate by its own absolute value - undefined on a
// coordinate of zero - and carried a branch for corners 2 and 3 that its own loop never reached.

// Where the straight neck starts, and where the shoulder's inner face tops out under it.
function vessel_neck_bottom(type) = vessel_height(type) - vessel_neck_height(type);
function vessel_shoulder_top(type) = vessel_neck_bottom(type) - vessel_neck_corner_radius(type);

// The three corner centres, each shared by the inside and the outside. The neck is the one that
// curves the other way, so it is the only one whose OUTER radius is the smaller of the pair.
function vessel_base_centre(type) =
  [vessel_diameter(type) / 2 - vessel_corner_radius_base(type), vessel_corner_radius_base(type)];
function vessel_shoulder_centre(type) =
  [
    vessel_diameter(type) / 2 - vessel_corner_radius(type),
    vessel_shoulder_top(type) + vessel_thickness(type) - vessel_corner_radius(type),
  ];
function vessel_neck_centre(type) =
  [vessel_diameter(type) / 2 - vessel_corner_radius(type), vessel_neck_bottom(type)];

/**
 * @brief The wetted boundary: axis outward across the floor, up the wall, and out at the rim.
 *
 * Straight runs carry no points of their own, because two consecutive points already are one -
 * the dished floor from the punt out to the base corner, the barrel wall, and the neck bore are
 * all implicit. What is left is the punt plateau and three arcs.
 */
function vessel_inner_profile(type, arcFn = 64) =
  let (_t = vessel_thickness(type), _floor = _t + vessel_punt_height(type))
    concat(
      [[0, _floor], [vessel_punt_width(type) / 2, _floor]],
      arc(r=vessel_corner_radius_base(type) - _t, angle=90, offsetAngle=270, c=vessel_base_centre(type), $fn=arcFn),
      arc(r=vessel_corner_radius(type) - _t, angle=90, offsetAngle=0, c=vessel_shoulder_centre(type), $fn=arcFn),
      arc(r=vessel_neck_corner_radius(type), angle=-90, offsetAngle=270, c=vessel_neck_centre(type), $fn=arcFn),
      [[vessel_opening_diameter(type) / 2, vessel_height(type)]]
    );

/**
 * @brief The outside, the same way up, ending on the rim.
 *
 * The rim bead is a half round centred on the neck's outer wall and tangent to the rim plane, so
 * it bulges outward without adding height. A registered rim_radius of 0 collapses it to a point,
 * which is what the two jars with a ground rim want.
 */
function vessel_outer_profile(type, arcFn = 64) =
  let (
    _t = vessel_thickness(type),
    _rim = vessel_rim_radius(type),
    _neck_r = vessel_opening_diameter(type) / 2 + _t
  )
    concat(
      [[0, vessel_punt_height(type)], [vessel_punt_width(type) / 2, vessel_punt_height(type)]],
      arc(r=vessel_corner_radius_base(type), angle=90, offsetAngle=270, c=vessel_base_centre(type), $fn=arcFn),
      arc(r=vessel_corner_radius(type), angle=90, offsetAngle=0, c=vessel_shoulder_centre(type), $fn=arcFn),
      arc(r=vessel_neck_corner_radius(type) - _t, angle=-90, offsetAngle=270, c=vessel_neck_centre(type), $fn=arcFn),
      arc(r=_rim, angle=180, offsetAngle=270, c=[_neck_r, vessel_height(type) - _rim], $fn=arcFn)
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

// The volume a profile sweeps about the axis, mm3.
//
// A LINE INTEGRAL round the boundary, not discs stacked up the axis, because the profile is not
// single valued in height: the floor dishes DOWN from the punt plateau to the base corner, so two
// radii share a height down there and no r(y) exists. Each segment contributes
// pi/3 * dy * (r1^2 + r1 r2 + r2^2); the free surface adds nothing because dy is zero along it and
// the axis nothing because r is, which is why summing the wetted run alone closes the region.
//
// Exact for the revolve, where a rendered mesh is a 64-gon inscribed in it and so reads 0.16 % low.
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

/**
 * @brief Create a vessel from a registered type
 * @param type  Registered parameter set (see vessels.scad)
 * @param angle Sweep of the revolve; < 360 gives a cross section
 *
 * The remaining parameters are rendering preferences, not physical facts, so they stay
 * out of the registered type.
 */
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

  // the inner profile is offset inward by the wall, so a corner tighter than the wall
  // is thickness would invert its arc
  assert(
    vessel_corner_radius(type) > vessel_thickness(type)
      && vessel_corner_radius_base(type) > vessel_thickness(type),
    str("vessel(): ", vessel_name(type), " has a corner radius smaller than its wall thickness")
  );

  // The NECK corner is the one that assert does not cover, and it is different in kind: a neck
  // corner tighter than the wall does not invert an arc, it puts the shoulder's outer face above
  // the neck's bottom, so the outside has to come back down to meet it and the jar carries a notch
  // round the neck root. Expressible, so reported rather than asserted - and it is an
  // inconsistency between three measured numbers rather than a part that cannot exist.
  if (vessel_neck_corner_radius(type) < vessel_thickness(type))
    echo(str(
      "WARNING vessel: ", vessel_name(type), " has a ", vessel_neck_corner_radius(type),
      " mm neck corner inside a ", vessel_thickness(type), " mm wall, so the shoulder's outer face ",
      "tops out ", vessel_thickness(type) - vessel_neck_corner_radius(type),
      " mm above the neck and the outside doubles back to reach it. corner_radius at or under ",
      (vessel_diameter(type) - vessel_opening_diameter(type)) / 2 - vessel_thickness(type),
      " mm clears it; it is registered at ", vessel_corner_radius(type),
      ". Which of the three is wrong is a caliper question - see TODO.md."
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
