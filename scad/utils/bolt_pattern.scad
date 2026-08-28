/**
 * @file bolt_pattern.scad
 * @brief Bolt circle for a flanged joint: where the posts fall, the bores through them, and the bolts
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description Two flanges clamped together by a ring of fasteners, where tie rods running the
 * length of the assembly already occupy some of the positions. The rods are posts like any other,
 * so the pattern has to land on them rather than around them.
 *
 * The post count comes from the ASME VIII-1 Mandatory Appendix 2 maximum bolt spacing rule,
 * 2a + 6t/(m + 0.5), which is the spacing beyond which a gasket leaks between posts. It is then
 * rounded up to a whole multiple of the rods, so the rods sit on pattern positions and the bolts
 * fall in the gaps between them.
 * https://codesignengg.com/wp-content/uploads/2025/05/LinkedIn-Article-Flange-Design-per-Appendix-2.pdf
 *
 * There is no lower bound in the rule: minimum spacing is not a stress question but whether a
 * wrench fits, so check bolt_post_spacing against the fastener before trusting a count.
 *
 * Both flanges must be cut from the same pattern or the holes will not line up, so derive the
 * points once and pass the list to each side rather than recomputing it per part.
 *
 * Sets no $fn, so the resolution of the calling file carries through.
 */

include <NopSCADlib/core.scad>;
include <NopSCADlib/vitamins/screws.scad>;

/**
 * @brief Total posts around the joint, the rods included.
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
 * @brief Arc length between adjacent post centres, to check a wrench will fit.
 * @param n_posts          Total posts on the circle
 * @param pattern_diameter Diameter of the bolt circle
 * @return Centre to centre spacing
 */
function bolt_post_spacing(n_posts, pattern_diameter) = PI * pattern_diameter / n_posts;

/**
 * @brief ISO 261 coarse thread pitch for a nominal diameter, mm. undef for a size not listed.
 *
 * NopSCADlib's screw rows carry no pitch and a turn past snug needs one - see
 * utils/gasket_load.scad. Looked up from the diameter rather than registered beside the bolt,
 * because a pitch written down next to an M8 stays 1.25 after someone changes the bolt to an M6.
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
 * @param n_rods           Rods to leave out, every n_posts/n_rods'th post being one; 0 returns every post
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
 * @brief Bore a clearance hole through the children at every point.
 * @param pts           Points from bolt_pattern_pts
 * @param hole_diameter Clearance hole diameter
 * @param depth         Bore depth
 * @param z             Height the bore starts at; the caller's z fighting margin belongs here
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
 * @brief Bolts at every point, the head bearing on z = 0 and the shank running up from it.
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
