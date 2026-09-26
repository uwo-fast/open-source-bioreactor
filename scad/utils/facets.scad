/**
 * @file facets.scad
 * @brief This project's tessellation policy, in one place.
 *
 * Tessellate by feature size, not by a flat segment count. The parts here mix a 12.5 mm shell with
 * 1.2 mm locking pins, and a flat $fn spends the same segments on both - a 0.06 mm chord on the
 * pins, far finer than anything printable, and the cost of those spheres dominates a CGAL render.
 * $fs holds the chord length instead, so a shell keeps its resolution and small features get what
 * they need.
 *
 * A file adopting this must set $fn = 0 alongside, or $fn takes precedence over $fa/$fs - including
 * a value inherited from a caller.
 */

function facet_angle() = $preview ? 6 : 2;
function facet_size() = $preview ? 1.2 : 0.6;

/**
 * @brief The fragment count this policy gives a circle of radius r - OpenSCAD's own rule, named.
 *
 * Coaxial cylinders of different radii get different counts, and so different vertex angles: a
 * bore and the lead-in above it come out of the same axis with their facets crossing. Where
 * shapes share an axis and have to meet cleanly, take the count from the widest of them and hand
 * the same $fn to all - equal counts start at the same angle, so the edges line up.
 */
function facet_count(r) = ceil(max(min(360 / facet_angle(), r * 2 * PI / facet_size()), 5));
