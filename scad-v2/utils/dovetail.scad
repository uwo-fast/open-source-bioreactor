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
 */

use <trapezium.scad>;

/**
 * @brief Points of a dovetail cross section, counter-clockwise from the root.
 * @param width  Width across the crown (the widest part)
 * @param height Root-to-crown height
 */
function dovetail_pts(width, height) =
  trapezium_pts(bottom_width=width * 2 / 3, top_width=width, height=height);

/**
 * @brief A dovetail prism, extruded along z from the origin.
 * @param length       Extrusion length
 * @param allowance    Grows the profile all round; 0 for the tail, the fit clearance for the socket
 * @param crown_radius Corner arc radius; defaults to height/4
 */
module dovetail(width, height, length, allowance = 0, crown_radius = undef) {
  r = is_undef(crown_radius) ? height / 4 : crown_radius;

  linear_extrude(height=length)
    offset(delta=allowance)
      // shrink then grow: every sharp corner comes back as an arc tangent to both edges
      offset(r=r) offset(r=-r)
        polygon(dovetail_pts(width, height));
}
