/**
 * @file dovetail.scad
 * @brief Dovetail cross section and prism, for keying parts together
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description A dovetail is a trapezium stood on its narrow end: the root is narrow and the
 * crown splays out, so a tail slid into a matching socket cannot be pulled straight out. The
 * two crown corners are acute and are swept into a quasi arc rather than left as sharp points.
 *
 * The socket is the same profile grown by an allowance, so the tail and socket cannot drift
 * apart.
 */

use <trapezium.scad>;

// Unit vector from a towards b.
function _unit(a, b) = let (v = b - a, l = norm(v)) l == 0 ? [0, 0] : v / l;

// Quadratic bezier, with the sharp corner itself as the control point.
function _qbez(p0, p1, p2, t) =
  (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;

// Replace corner c, whose neighbours along the path are a then b, with fn+1 points sweeping a
// quasi arc. The curve starts and ends setback away from c along each edge, so it is tangent
// to both, the neighbouring points do not move, and the arc only ever cuts into the corner.
function _round_corner(a, c, b, setback, fn) =
  let (
    p0 = c + _unit(c, a) * setback,
    p2 = c + _unit(c, b) * setback
  ) [for (i = [0:fn]) _qbez(p0, c, p2, i / fn)];

/**
 * @brief Points of a dovetail cross section, counter-clockwise from the root.
 * @param width          Width across the crown (the widest part)
 * @param height         Root-to-crown height
 * @param corner_setback How far back along each edge the crown arcs start; defaults to height/3
 * @param corner_fn      Segments per crown arc
 */
function dovetail_pts(width, height, corner_setback = undef, corner_fn = 6) =
  let (
    pts = trapezium_pts(bottom_width=width * 2 / 3, top_width=width, height=height),
    // pts is [root left, root right, crown right, crown left], counter-clockwise
    setback = is_undef(corner_setback) ? height / 3 : corner_setback
  ) concat(
    [pts[0], pts[1]],
    _round_corner(pts[1], pts[2], pts[3], setback, corner_fn), // crown right
    _round_corner(pts[2], pts[3], pts[0], setback, corner_fn) // crown left
  );

/**
 * @brief A dovetail prism, extruded along z from the origin.
 * @param length    Extrusion length
 * @param allowance Grows the profile all round; 0 for the tail, the fit clearance for the socket
 */
module dovetail(width, height, length, allowance = 0, corner_setback = undef, corner_fn = 6) {
  linear_extrude(height=length)
    offset(delta=allowance)
      polygon(dovetail_pts(width, height, corner_setback, corner_fn));
}
