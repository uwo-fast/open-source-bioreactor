/**
 * @file dovetail.scad
 * @brief Dovetail cross section and prism, for keying parts together
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description A dovetail is a trapezium stood on its narrow end: the root is narrow and the
 * crown splays out, so a tail slid into a matching socket cannot be pulled straight out. The
 * corners are swept into arcs rather than left as sharp points.
 *
 * The socket is the same profile grown by an allowance, so the tail and socket cannot drift
 * apart.
 *
 * The flare is set by root_width. Its default of two thirds of the crown gives a steep flare
 * (~52 degrees off vertical at the bottle holder's proportions) suited to a coarse stacking key;
 * a joint wanting the usual 7-15 degrees needs a root much closer to the crown width.
 */

/**
 * @brief Points of a dovetail cross section, counter-clockwise from the root.
 * @param width      Width across the crown (the widest part)
 * @param height     Root-to-crown height
 * @param root_width Width across the root; defaults to two thirds of the crown
 */
function dovetail_pts(width, height, root_width = undef) =
  let (root = is_undef(root_width) ? width * 2 / 3 : root_width) [
      [-root / 2, 0], // root left
      [root / 2, 0], // root right
      [width / 2, height], // crown right
      [-width / 2, height], // crown left
  ];

/**
 * @brief A dovetail prism, extruded along z from the origin.
 * @param length       Extrusion length
 * @param allowance    Grows the profile all round; 0 for the tail, the fit clearance for the socket
 * @param crown_radius Corner arc radius; defaults to height/4
 */
module dovetail(width, height, length, allowance = 0, root_width = undef, crown_radius = undef) {
  r = is_undef(crown_radius) ? height / 4 : crown_radius;

  linear_extrude(height=length)
    offset(delta=allowance)
      // shrink then grow: every sharp corner comes back as an arc tangent to both edges
      offset(r=r) offset(r=-r)
        polygon(dovetail_pts(width, height, root_width));
}
