/**
 * @file vessel.scad
 * @brief A generic model of a glass blown, open mouth vessel with a neck and optional punt.
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

use <FunctionalOpenSCAD/functional.scad>;

/**
 * @brief Returns the inner opening (mouth bore) diameter of the vessel.
 *
 * Closed form derived from the neck profile: the opening sits inboard of the outer
 * wall by the shoulder (upper) corner radius plus the neck corner radius on each
 * side. Wall thickness cancels out of the neck-flat point, so it is intentionally
 * absent here. This is the value cross-coupled to the head (lid plug diameter).
 *
 * @param diameter            Outer diameter of the vessel body.
 * @param corner_radius       Shoulder-to-body (upper) corner radius.
 * @param neck_corner_radius  Shoulder-to-neck corner radius.
 */
function vessel_opening_diameter(diameter, corner_radius, neck_corner_radius) =
  diameter - 2 * (corner_radius + neck_corner_radius);

/**
 * @brief Resolves the (shoulder, neck) corner-radius pair from whichever driving
 *        mode the caller used, asserting that exactly one valid mode is given.
 *
 *   Mode A: corner_radius AND neck_corner_radius     -> opening is derived downstream.
 *   Mode B: opening_diameter AND exactly one radius  -> the missing radius is solved.
 *
 * Every two-element subset of { corner_radius, neck_corner_radius, opening_diameter }
 * is a legal mode, so "exactly one mode" reduces to "exactly two inputs supplied".
 * The solve is the inverse of vessel_opening_diameter():
 *   corner_radius + neck_corner_radius = (diameter - opening_diameter) / 2.
 *
 * @returns [corner_radius, neck_corner_radius]
 */
function vessel_resolve_corners(diameter, corner_radius, neck_corner_radius, opening_diameter) =
  let (
    given = (is_undef(corner_radius) ? 0 : 1) + (is_undef(neck_corner_radius) ? 0 : 1) + (is_undef(opening_diameter) ? 0 : 1)
  ) assert(
    given == 2,
    "vessel(): supply exactly two of { corner_radius, neck_corner_radius, opening_diameter } (mode A = both radii; mode B = opening_diameter + one radius)"
  )
  let (
    sum = is_undef(opening_diameter) ? corner_radius + neck_corner_radius : (diameter - opening_diameter) / 2,
    cr = is_undef(corner_radius) ? sum - neck_corner_radius : corner_radius,
    ncr = is_undef(neck_corner_radius) ? sum - corner_radius : neck_corner_radius
  ) assert(
    cr >= 0 && ncr >= 0,
    "vessel(): a resolved corner radius is negative — opening_diameter is too large for the given diameter and radius"
  )
  [cr, ncr];

// Example usage
vessel(
  height=100,
  diameter=50,
  thickness=2,
  corner_radius=5,
  corner_radius_base=5,
  neck=20,
  neck_corner_radius=5,
  punt_height=5,
  punt_width=10,
  rim_rad=2,
  show_pts=false,
  show_2d=true,
  show_3d=false
);

module vessel(
  height,
  diameter,
  thickness,
  corner_radius = undef,
  corner_radius_base,
  neck,
  neck_corner_radius = undef,
  opening_diameter = undef,
  rim_rad,
  punt_height,
  punt_width,
  arcFn = 64,
  rotExtFn = 64,
  show_pts = false,
  show_2d = false,
  show_3d = true,
  pts_r = 1,
  angle = 360
) {
  // Resolve the shoulder/neck corner radii from the caller's driving mode (A or B).
  _resolved = vessel_resolve_corners(diameter, corner_radius, neck_corner_radius, opening_diameter);

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

  // Bind the resolved radii onto the names the geometry below uses. This is a
  // child-scope shadow (not a same-scope reassignment of the parameters), so it
  // leaves the body verbatim and avoids the redefinition warning.
  let (corner_radius = _resolved[0], neck_corner_radius = _resolved[1]) {

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

    opening_diameter = vessel_opening_diameter(diameter, corner_radius, neck_corner_radius);
    // guard: the closed-form function must match the geometric neck point that builds the profile
    assert(
      abs(opening_diameter - abs(neck_flat_nx[1][0]) * 2) < 1e-6,
      "vessel_opening_diameter() disagrees with the neck geometry"
    );
    echo("vessel opening_diameter: ", opening_diameter);

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
    // translate([ 0, body_height/2, 0])
    // rotate([ 90, 0, 0 ])
    color("Azure", 0.5) poly3d(result3d);
  }
}
