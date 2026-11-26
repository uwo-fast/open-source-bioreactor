/**
 * @file facets.scad
 * @brief The project tessellation policy.
 *
 * Tessellate by feature size, not by a fixed segment count. The parts combine a 12.5 mm shell with
 * 1.2 mm locking pins, and a fixed $fn uses the same number of segments on both. That gives the
 * pins a 0.06 mm chord, far finer than anything printable, and those spheres dominate the cost of
 * a CGAL render. $fs fixes the chord length instead, so the shell keeps its resolution and small
 * features get only the segments they need.
 *
 * A file using this policy must also set $fn = 0, or $fn takes precedence over $fa/$fs, including
 * a value inherited from a caller.
 */

function facet_angle() = $preview ? 6 : 2;
function facet_size() = $preview ? 1.2 : 0.6;

/**
 * @brief Fragment count this policy gives a circle of radius r (OpenSCAD's built-in rule).
 *
 * Coaxial cylinders of different radii get different counts and therefore different vertex
 * angles, so a bore and the lead-in above it have misaligned facets. Where coaxial shapes must
 * meet cleanly, take the count from the widest one and pass the same $fn to all. Equal counts
 * start at the same angle, so the edges line up.
 */
function facet_count(r) = ceil(max(min(360 / facet_angle(), r * 2 * PI / facet_size()), 5));
