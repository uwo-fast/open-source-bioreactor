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

// Table A's groove width, stepped at the cords it tabulates. The ratio is 1.5 for everything at
// or under 0.070 in and tapers as the cord grows, because a fat cord spreads proportionally less
// than a thin one. Real cords are the tabulated ones; anything in between takes the ratio of the
// next size up, and oring_gland_fill is what catches a groove that cannot hold its ring.
function oring_gland_width(cs) =
  cs <= 1.78 ? cs * 1.500  // .020 through .070 in
  : cs <= 2.62 ? cs * 1.417 // .103 in
  : cs <= 3.53 ? cs * 1.403 // .139 in
  : cs <= 5.33 ? cs * 1.333 // .210 in
  : cs * 1.273; // .275 in

// Depth for a target squeeze, and the same arithmetic either way up: axial glands want 19-33%
// squeeze at this scale, radial ones 14-23%, so it is the caller that knows which it is cutting.
function oring_gland_depth(cs, squeeze = 0.25) = cs * (1 - squeeze);

// Fraction of the groove the cord fills. Over 1 and the ring cannot be closed into it.
function oring_gland_fill(cs, width, depth) = (PI * pow(cs, 2) / 4) / (width * depth);

/**
 * @brief Fraction of the cord's section sitting inside the groove.
 *
 * "No less than 75% of the seal cross-section should be contained within the groove to ensure
 * the seal does not roll or extrude out of the groove" - the same table's notes. Fill says
 * whether the cord has room; this says whether the groove is holding onto it, and a shallow
 * wide groove can pass the first and fail this one.
 *
 * The part standing out past the groove's mouth is a circular segment, so this is one minus its
 * share of the section. OpenSCAD's acos returns degrees, hence the conversion.
 *
 * @param cs           Cord diameter
 * @param groove_depth Depth of the groove cut into the part, mouth to floor
 */
function oring_containment(cs, groove_depth) =
  let (r = cs / 2, d = groove_depth - r) // d: how far the cord's centre sits inside the mouth
    d >= r ? 1
    : d <= -r ? 0
    : 1 - (r * r * acos(d / r) * PI / 180 - d * sqrt(r * r - d * d)) / (PI * r * r);

// How far a ring is stretched onto a groove of this diameter. A piston gland wants 0 to 5%:
// slack lets the ring sag out of its groove, and stretching thins the cord it seals with.
function oring_stretch(ring_id, groove_bottom_diameter) = (groove_bottom_diameter - ring_id) / ring_id;
