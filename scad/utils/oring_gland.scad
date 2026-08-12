/**
 * @file oring_gland.scad
 * @brief Face-seal gland for a given o-ring: how wide, how deep, and where the groove sits
 * @author Cameron K. Brooks
 * @copyright 2026
 * @description An o-ring squeezed axially between two flat faces. The ring is the purchased
 * part, so it is the input: everything here is derived from its inside diameter and cross
 * section, and a groove that cannot hold the ring it was cut for is not expressible.
 *
 * Three numbers settle a static face gland, all from Apple Rubber's Table A (static seals,
 * axial column) and the notes above it:
 *
 *   depth   0.70 to 0.77 x cs, i.e. 19 to 33 percent squeeze; 0.75 is the middle of that
 *   width   1.5 x cs for every cross section at or below 0.070 in, which is this scale
 *   fill    60 to 85 percent of the groove volume, "never exceeding 85", hard limit 90
 *
 * https://www.applerubber.com/src/pdf/section4-seal-types-and-gland-design-tables.pdf
 *
 * The width is not a rounding of the cross section: compressed by a quarter, the ring's
 * section has to go somewhere sideways, and a groove only as wide as the cord is over-full
 * before it is even closed. Squeeze is what seals, but fill is what fits, and fill binds first.
 *
 * Under internal pressure the ring is driven against the groove's outer wall, so that wall is
 * the one dimensioned (Table B, diameter A). A bioreactor is sparged, so it is that case. The
 * table sets A about 0.13 mm under the ring's own outer diameter, toleranced +0.13/-0, to
 * guarantee the ring finds that wall; taken here as the ring's outer diameter outright, which
 * is the loose end of the same band and well inside what a printed groove holds anyway.
 *
 * Sets no $fn, so the resolution of the calling file carries through.
 */

// The groove's outer diameter, which is the ring's own: the wall internal pressure drives it
// against, and the only one of the two worth holding to size.
function oring_gland_od(id, cs) = id + 2 * cs;

function oring_gland_width(cs) = cs * 1.5;
function oring_gland_depth(cs, squeeze = 0.25) = cs * (1 - squeeze);

// Fraction of the groove the cord fills. Over 1 and the ring cannot be closed into it.
function oring_gland_fill(cs, width, depth) = (PI * pow(cs, 2) / 4) / (width * depth);
