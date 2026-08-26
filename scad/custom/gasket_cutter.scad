/**
 * @file gasket_cutter.scad
 * @brief Printed template pair for cutting a flat ring gasket from sheet stock
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A tool, not a part of the reactor. It takes the same three numbers custom/sheet_gasket.scad takes
 * - the cut and the stock it comes from - and knows nothing else about what the ring seals.
 *
 * TWO STAGES, because one template cannot guide both cuts. A template shaped like the gasket would
 * be a wall as wide as the ring - 3 mm on the lid's - standing at the ring's diameter, which is far
 * too slack in its own plane to hold a blade to a line; and bracing it needs material either inside
 * the bore or outside the rim, which is exactly where the blade has to be. So the cuts are taken one
 * at a time, and the second locates off the first:
 *
 *   1. "outer" is a plain disc at the ring's OUTER diameter. Lay it on the sheet, pin it, run a
 *      blade round it. That gives a blank disc and nothing stands outboard to foul the blade.
 *   2. "inner" is a plate bored at the ring's INNER diameter with a counterbore underneath at the
 *      OUTER. The blank drops into the counterbore, which holds it concentric, and the bore guides
 *      the second cut from above. The scrap centre is unheld and does not need to be - the guide is
 *      the bore wall and the rubber under it is clamped.
 *
 * Both parts are discs with a pocket, so both print flat with no bridge and no support, and the
 * concentricity of the finished ring is a printed counterbore rather than the operator's hand.
 */

$fn = $preview ? 64 : 128;

gasket_cutter(inner_diameter=145, outer_diameter=151, thickness=1.5875);

/**
 * @brief Templates for cutting a flat ring gasket.
 * @param inner_diameter Cut inside diameter, as sheet_gasket() takes it
 * @param outer_diameter Cut outside diameter
 * @param thickness      Thickness of the stock being cut
 * @param part           "all", "outer" or "inner"
 * @param height         Guide face height - what holds the blade upright through the cut
 * @param rim            Material outboard of the guide bore on the inner plate, for grip and screws
 * @param grip           How far the inner plate stands off its counterbore floor, squeezing the blank
 * @param pin_diameter   Clearance hole for the screw that pins a template to the backing board
 * @param seat_clearance Added to the counterbore so a cut blank drops in
 * @param chamfer        Relief at the disc's bed edge, so a squashed first layer cannot stand proud
 *                       of the guide face; and the lead-in at the bore's mouth
 * @param colour         As printed
 */
module gasket_cutter(
  inner_diameter,
  outer_diameter,
  thickness,
  part = "all",
  height = 8,
  rim = 12,
  grip = 0.4,
  pin_diameter = 4.5,
  seat_clearance = 0.2,
  chamfer = 0.4,
  colour = "DarkOrange"
) {
  assert(
    outer_diameter > inner_diameter,
    str("gasket_cutter: outer_diameter (", outer_diameter, ") must exceed inner_diameter (", inner_diameter, ")")
  );
  assert(
    thickness > grip,
    str("gasket_cutter: a ", thickness, " mm sheet cannot stand ", grip, " mm proud of its own seat.")
  );
  assert(
    inner_diameter > pin_diameter + 2 * rim,
    str("gasket_cutter: a ", inner_diameter, " mm bore has no room for a ", rim, " mm rim and a pin.")
  );

  _seat_depth = thickness - grip; // the blank stands proud by grip, so the plate lands on rubber
  _plate_d = outer_diameter + 2 * rim;
  _screw_r = (outer_diameter + rim) / 2;

  // Stage 1. Cut round the outside of this. It is solid rather than a ring because nothing has to
  // reach its centre, and solid is what makes it stiff enough to cut against.
  //
  // The bed edge is drawn UNDER size and flared up to the guide diameter, rather than chamfered off
  // it: a first layer that squashes outward would otherwise stand proud of the very face the blade
  // is being held to, and every blank would come out that much oversize.
  module _outer() {
    color(colour)
      difference() {
        union() {
          cylinder(d1=outer_diameter - 2 * chamfer, d2=outer_diameter, h=chamfer);
          translate([0, 0, chamfer])
            cylinder(d=outer_diameter, h=height - chamfer);
        }
        translate([0, 0, -1]) cylinder(d=pin_diameter, h=height + 2);
      }
  }

  // Stage 2. The blank sits in the counterbore below; the blade comes down the bore.
  module _inner() {
    color(colour)
      difference() {
        cylinder(d=_plate_d, h=height + _seat_depth);
        translate([0, 0, -height / 2]) cylinder(d=inner_diameter, h=height * 3);
        translate([0, 0, -1]) cylinder(d=outer_diameter + seat_clearance, h=_seat_depth + 1);
        for (i = [0:2])
          rotate([0, 0, i * 120])
            translate([_screw_r, 0, -1])
              cylinder(d=pin_diameter, h=height * 3);
        translate([0, 0, height + _seat_depth]) _chamfer_in(inner_diameter);
      }
  }

  // Lead-in at the mouth of the bore, so the blade finds the guide face instead of the top corner.
  // Only the mouth: the bore's other end stops on the counterbore roof and never meets the bed, so
  // there is no first layer down there to relieve.
  module _chamfer_in(d) {
    translate([0, 0, -chamfer + 0.001])
      cylinder(d1=d, d2=d + 2 * chamfer, h=chamfer);
  }

  if (part == "outer" || part == "all") _outer();
  if (part == "inner" || part == "all")
    translate([part == "all" ? _plate_d + 10 : 0, 0, 0]) _inner();
}
