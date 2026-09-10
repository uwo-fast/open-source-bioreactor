/**
 * @file oring_gland.scad
 * @brief The groove an o-ring needs, derived from the ring rather than the other way round.
 *
 * Apple Rubber Table A, static seals, axial column:
 * https://www.applerubber.com/src/pdf/section4-seal-types-and-gland-design-tables.pdf
 * Sets no $fn.
 */

// Table A's groove-width ratios by cord section, as the table rather than as a ladder. A fat cord
// spreads proportionally less than a thin one; anything between sizes takes the next size up.
function oring_gland_width_ratios() = [[1.78, 1.500], [2.62, 1.417], [3.53, 1.403], [5.33, 1.333]];

// Width is not a rounding of the cord: compressed by a quarter the section has to go somewhere
// sideways, so a groove only as wide as the cord is over-full before it closes. Fill binds first.
function oring_gland_width(cs, i = 0) =
  i >= len(oring_gland_width_ratios()) ? cs * 1.273
  : cs <= oring_gland_width_ratios()[i][0] ? cs * oring_gland_width_ratios()[i][1]
  : oring_gland_width(cs, i + 1);

function oring_gland_depth(cs, squeeze = 0.25) = cs * (1 - squeeze);

// Under internal pressure the ring is driven against the groove's OUTER wall, so that is the wall
// dimensioned (Table B, diameter A) - taken as the ring's own outer diameter, the loose end of the
// band the table allows.
function oring_gland_od(id, cs) = id + 2 * cs;

// Fraction of the groove the cord fills. Over 1 and the ring cannot be closed into it.
function oring_gland_fill(cs, width, depth) = (PI * pow(cs, 2) / 4) / (width * depth);

// Fraction of the cord's section inside the groove, by circular segment. Table A's notes want no
// less than 75% or the seal rolls or extrudes out.
function oring_containment(cs, groove_depth) =
  let (r = cs / 2, d = groove_depth - r)
    d >= r ? 1
    : d <= -r ? 0
    : 1 - (r * r * acos(d / r) * PI / 180 - d * sqrt(r * r - d * d)) / (PI * r * r);

// Radial glands, where the squeeze is bore minus groove rather than a face closing. The second is
// the same relation read backwards, off a groove that already exists.
function oring_rod_gland_diameter(rod_diameter, cs, squeeze = 0.18) =
  rod_diameter + 2 * oring_gland_depth(cs, squeeze);
function oring_rod_gland_squeeze(rod_diameter, groove_diameter, cs) =
  1 - (groove_diameter - rod_diameter) / 2 / cs;

function oring_stretch(ring_id, groove_bottom_diameter) = (groove_bottom_diameter - ring_id) / ring_id;
