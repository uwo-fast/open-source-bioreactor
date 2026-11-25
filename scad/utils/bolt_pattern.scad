/**
 * @file bolt_pattern.scad
 * @brief Bolt circle for a flanged joint: post positions, holes and bolts
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description Two flanges are clamped together by a ring of fasteners. Tie rods running the
 * length of the assembly already occupy some of the positions. The rods count as posts, so the
 * pattern must include their positions.
 *
 * The post count comes from the ASME VIII-1 Mandatory Appendix 2 maximum bolt spacing rule,
 * 2a + 6t/(m + 0.5). Above this spacing a gasket leaks between posts. The count is then rounded
 * up to a whole multiple of the rod count, so the rods sit on pattern positions and the bolts
 * fill the gaps between them.
 * https://codesignengg.com/wp-content/uploads/2025/05/LinkedIn-Article-Flange-Design-per-Appendix-2.pdf
 *
 * The rule has no lower bound. Minimum spacing is set by wrench clearance, not stress, so check
 * bolt_post_spacing against the fastener before using a count.
 *
 * Both flanges must use the same pattern or the holes will not line up. Compute the points once
 * and pass the list to each part rather than recomputing it.
 *
 * Sets no $fn, so the resolution of the calling file applies.
 */

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/screws.scad>;

/**
 * @brief Total number of posts around the joint, including the rods.
 * @param n_rods           Tie rods already on the circle; the count is rounded up to a multiple of this
 * @param bolt_diameter    Nominal fastener diameter, a in the spacing rule
 * @param pattern_diameter Diameter of the bolt circle
 * @param flange_thickness Thickness of the thinner of the two flanges, t in the rule
 * @param gasket_factor    Gasket factor m, ASME VIII-1 Table 2-5.1: 0 o-ring, 0.5 silicone under 75A, 1.0 over
 * @return Post count, a whole multiple of n_rods
 */
function bolt_post_count(n_rods, bolt_diameter, pattern_diameter, flange_thickness, gasket_factor) =
  let (max_spacing = 2 * bolt_diameter + 6 * flange_thickness / (gasket_factor + 0.5))
    n_rods * ceil(ceil(PI * pattern_diameter / max_spacing) / n_rods);

/**
 * @brief Arc length between adjacent post centres, for checking wrench clearance.
 * @param n_posts          Total posts on the circle
 * @param pattern_diameter Diameter of the bolt circle
 * @return Centre to centre spacing
 */
function bolt_post_spacing(n_posts, pattern_diameter) = PI * pattern_diameter / n_posts;

/**
 * @brief ISO 261 coarse thread pitch for a nominal diameter, mm. undef for a size not listed.
 *
 * NopSCADlib's screw rows have no pitch, and the angle-past-snug instruction needs one (see
 * utils/elastomer.scad). The pitch is looked up from the diameter rather than stored with the
 * bolt, because a pitch stored next to an M8 would stay 1.25 if the bolt were changed to an M6.
 */
function bolt_coarse_pitch(diameter) =
  let (_at = [
      for (r = [[3, 0.5], [4, 0.7], [5, 0.8], [6, 1.0], [8, 1.25], [10, 1.5], [12, 1.75]])
        if (r[0] == diameter) r[1],
    ])
    len(_at) == 1 ? _at[0] : undef;

/**
 * @brief Points of a bolt circle, counter-clockwise from positive x with a post on that axis.
 * @param n_posts          Total posts on the circle
 * @param pattern_diameter Diameter of the bolt circle
 * @param n_rods           Number of rods to omit (every (n_posts/n_rods)th post); 0 returns every post
 * @return A list of [x, y] points
 */
function bolt_pattern_pts(n_posts, pattern_diameter, n_rods = 0) =
  let (radius = pattern_diameter / 2, stride = n_rods == 0 ? 0 : n_posts / n_rods) [
      for (i = [0:n_posts - 1]) if (stride == 0 || i % stride != 0) [
          radius * cos(i * 360 / n_posts),
          radius * sin(i * 360 / n_posts),
        ],
  ];

/**
 * @brief Cut a clearance hole through the children at every point.
 * @param pts           Points from bolt_pattern_pts
 * @param hole_diameter Clearance hole diameter
 * @param depth         Hole depth
 * @param z             Starting height of the hole; pass the caller's z-fighting margin here
 */
module bolt_pattern_bores(pts, hole_diameter, depth, z = 0) {
  difference() {
    children();

    for (p = pts)
      translate([p[0], p[1], z])
        cylinder(d=hole_diameter, h=depth);
  }
}

/**
 * @brief A bolt at every point, with the head bearing on z = 0 and the shank pointing up.
 * @param pts    Points from bolt_pattern_pts
 * @param screw  NopSCADlib screw type, e.g. M8_hex_screw
 * @param length Shank length; screw_length() picks a stock size for a given grip
 */
module bolt_pattern_bolts(pts, screw, length) {
  for (p = pts)
    translate([p[0], p[1], 0])
      rotate([180, 0, 0])
        screw(screw, length);
}
