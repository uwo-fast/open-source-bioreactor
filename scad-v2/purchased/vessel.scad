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
 */

use <FunctionalOpenSCAD/functional.scad>;

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
  height = vessel_height(type);
  diameter = vessel_diameter(type);
  thickness = vessel_thickness(type);
  opening_diameter = vessel_opening_diameter(type);
  neck = vessel_neck_height(type);
  corner_radius = vessel_corner_radius(type);
  corner_radius_base = vessel_corner_radius_base(type);
  punt_height = vessel_punt_height(type);
  punt_width = vessel_punt_width(type);
  rim_rad = vessel_rim_radius(type);

  neck_corner_radius = vessel_neck_corner_radius(type);

  assert(
    neck_corner_radius >= 0,
    str(
      "vessel(): ", type[0], " has no room for a neck corner — its opening_diameter is too ",
      "large for the given diameter and corner_radius"
    )
  );

  // the inner profile is offset inward by the wall, so a corner tighter than the wall
  // is thickness would invert its arc
  assert(
    corner_radius > thickness && corner_radius_base > thickness,
    str("vessel(): ", type[0], " has a corner radius smaller than its wall thickness")
  );

  // Local 2D corner-rounding helper. Defined at module scope (function definitions
  // are not permitted inside the let() block below, where it is called from).
  function corners(outline, corner_rad, corner_rad_base = undef) =
    [
      for (i = [0:1]) let (
        xfactor = outline[0][i][0] / abs(outline[0][i][0]),
        yfactor = outline[0][i][1] / abs(outline[0][i][1]),
        radius = is_undef(corner_rad_base) ? corner_rad : (i == 1 || i == 2 ? corner_rad_base : corner_rad),
        c_pt = [outline[0][i][0] - (radius * xfactor), outline[0][i][1] - (radius * yfactor)],
        corner = arc(
          r=radius, angle=90, offsetAngle=180 + (i * -90), c=c_pt, center=false,
          internal=false, $fn=arcFn
        )
      ) ([reverse(corner)]),
    ];

  body_height = height - neck - neck_corner_radius / 2 - rim_rad;

  outerline = square([diameter, body_height], center=true);
  innerline = square([diameter - (2 * thickness), body_height - (2 * thickness)], center=true);

  if (show_pts)
    showPoints(outerline, r=pts_r, $fn=16);
  // show the points of the resulting poly

  // Fun fact: A pontil mark or punt mark is the scar where the
  // pontil, punty or punt was broken from a work of blown glass
  outer_punt = [[-punt_width / 2, outerline[0][1][1] - punt_height], [0, outerline[0][1][1] - punt_height]];
  inner_punt = [[0, innerline[0][1][1] - punt_height], [-punt_width / 2, innerline[0][1][1] - punt_height]];

  if (show_pts) {
    color("orange") showPoints(inner_punt, r=pts_r, $fn=16);
    color("orange") showPoints(outer_punt, r=pts_r, $fn=16);
  }

  outerCornersPoly = corners(outerline, corner_rad=corner_radius, corner_rad_base=corner_radius_base);

  outerCorner_nxny = flatten(outerCornersPoly)[0];
  outerCorner_nxpy = flatten(outerCornersPoly)[1];

  if (show_pts)
    color("red") showPoints(outerCornersPoly, r=pts_r, $fn=16);
  // show the points of the resulting poly

  innerCornersPoly = corners(innerline, corner_radius - thickness, corner_radius_base - thickness);

  innerCorner_nxny = reverse(flatten(innerCornersPoly)[0]);
  innerCorner_nxpy = reverse(flatten(innerCornersPoly)[1]);

  if (show_pts)
    color("blue") showPoints(innerCornersPoly, r=pts_r, $fn=16);
  // show the points of the resulting poly

  // neck corner
  neck_outer_corner_nx =
  arc(
    r=neck_corner_radius - thickness, angle=90, offsetAngle=0,
    c=[outerline[0][0][0] + corner_radius, outerline[0][0][1] - neck_corner_radius + thickness],
    center=false, internal=false, $fn=arcFn
  );

  neck_inner_corner_nx = arc(
    r=neck_corner_radius, angle=90, offsetAngle=0,
    c=[outerline[0][0][0] + corner_radius, innerline[0][0][1] - neck_corner_radius],
    center=false, internal=false, $fn=arcFn
  );

  if (show_pts) {
    color("green") showPoints(neck_outer_corner_nx, r=pts_r, $fn=16);
    color("orange") showPoints(neck_inner_corner_nx, r=pts_r, $fn=16);
  }

  // neck flat
  neck_flat_nx = translate(
    [
      outerline[0][0][0] + corner_radius + neck_corner_radius - thickness,
      innerline[0][0][1] - neck - neck_corner_radius,
    ],
    [[0, 0], [thickness, 0]]
  );

  // guard: the registered opening must be reproduced by the neck geometry it drives
  assert(
    abs(opening_diameter - abs(neck_flat_nx[1][0]) * 2) < 1e-6,
    str("vessel(): ", type[0], " registered opening_diameter disagrees with the neck geometry")
  );

  if (show_pts) {
    color("purple") showPoints(neck_flat_nx, r=pts_r, $fn=16);
  }

  // rim
  rim_nx = arc(
    r=rim_rad, angle=180, offsetAngle=90,
    c=[
      outerline[0][0][0] + corner_radius + neck_corner_radius - thickness,
      innerline[0][0][1] - neck - neck_corner_radius + rim_rad,
    ],
    center=false, internal=false, $fn=arcFn
  );

  if (show_pts) {
    color("teal") {
      showPoints(rim_nx, r=pts_r, $fn=16);
    }
  }

  result = concat(
    neck_outer_corner_nx, outerCorner_nxny, outerCorner_nxpy, outer_punt, inner_punt, innerCorner_nxpy,
    innerCorner_nxny, reverse(neck_inner_corner_nx), reverse(neck_flat_nx), reverse(rim_nx)
  );

  // show the first and last point in pink and yellow
  if (show_pts) {
    color("pink") showPoints([result[0]], r=pts_r, $fn=16);
    color("yellow") showPoints([result[len(result) - 1]], r=pts_r, $fn=16);
  }

  if (show_2d)
    color("Aqua") poly2d(result);

  transformed_result = translate([0, body_height / 2], rotate(a=180, v=[0, 1, 0], poly=result));

  result3d = rotate_extrude(angle=angle, poly=transformed_result, $fn=rotExtFn);
  if (show_3d)
    color("Azure", 0.5) poly3d(result3d);
}
