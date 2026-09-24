/**
 * @file gasket_cutter.scad
 * @brief Printed templates for cutting a flat ring gasket from sheet stock
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A tool, not a part of the reactor. It takes the same three numbers custom/sheet_gasket.scad takes
 * - the cut and the stock it comes from - and knows nothing else about what the ring seals.
 *
 * Two stages, because a template as narrow as the ring is too slack to hold a blade to a line:
 *   1. "outer" is a plain disc at the ring's outer diameter; pin it, cut round it for a blank.
 *   2. "inner" is a plate bored at the inner diameter with a counterbore underneath at the outer;
 *      the blank drops in concentric and the bore guides the second cut.
 *
 * Both stages work against "base", which is the third part and the only one that is not reprinted
 * when the gasket changes. It is the cutting surface - the counterbore has no floor of its own, so
 * the blade comes through the rubber into the base - it carries the nuts, and it is what both
 * stages screw to, so neither has to be lined up on a board by eye. The clamp circle is therefore
 * a fixed radius rather than one that follows the gasket: a slot at a radius that moved would sit
 * under the cut line at some size, and a void under the cut is rubber with nothing behind it.
 * All three print flat with no support.
 */

$fn = $preview ? 64 : 128;

// Where every stage clamps to the base. Fixed, not derived from the gasket, so one base serves
// every size; it has to clear the largest outer diameter the base is built for.
gasket_cutter_clamp_radius = 92;
// Half the travel the base's slots allow the clamp screws, either side of that radius.
gasket_cutter_clamp_travel = 5;

gasket_cutter(inner_diameter=145, outer_diameter=151, thickness=1.5875);

/**
 * @brief Templates for cutting a flat ring gasket.
 * @param inner_diameter Cut inside diameter, as sheet_gasket() takes it
 * @param outer_diameter Cut outside diameter
 * @param thickness      Thickness of the stock being cut
 * @param part           "all", "outer", "inner" or "base"
 * @param height         Guide face height - what holds the blade upright through the cut
 * @param rim            Material outboard of the guide bore on the inner plate, for grip and screws
 * @param grip           How far the inner plate stands off its counterbore floor, squeezing the blank
 * @param pin_diameter   Clearance hole for the screw that pins a template to the backing board
 * @param seat_clearance Added to the counterbore so a cut blank drops in
 * @param chamfer        Relief at the disc's bed edge, so a squashed first layer cannot stand proud
 *                       of the guide face; and the lead-in at the bore's mouth
 * @param seat_lead      Flare at the counterbore's mouth, which is what lets the plate be lowered
 *                       onto a blank lying on the base instead of the blank being loaded into an
 *                       upturned plate and the pair turned over
 * @param clamp_radius   Radius the clamp screws sit on, the same for every gasket. The default
 *                       clears the largest ring any registered vessel asks for, which is cut at
 *                       r 78, and it is what sets the inner plate's size; a base for one jar can
 *                       bring it in and take both plates down with it
 * @param clamp_travel   Half the slot length the base gives those screws
 * @param platen_height  Base thickness; the blade comes through the rubber into it
 * @param platen_bore    Hole through the middle of the base. Nothing is cut inboard of the
 *                       smallest inner diameter, so the platen only has to be continuous under
 *                       the two cut circles; the middle is carried on spokes instead. The default
 *                       clears the smallest ring any registered vessel asks for, which is cut at
 *                       r 43.75; a base for one jar can take a much larger bore
 * @param hub_radius     Material around the base's central nut, where stage 1 screws down
 * @param spoke_width    The three ribs that carry that hub
 * @param nut_across_flats Clamp nut, across the flats
 * @param nut_height     Clamp nut thickness
 * @param nut_clearance  Added to both, so a nut slides in its channel without turning
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
  seat_lead = 1.5,
  clamp_radius = gasket_cutter_clamp_radius,
  clamp_travel = gasket_cutter_clamp_travel,
  platen_height = 8,
  platen_bore = 36,
  hub_radius = 12,
  spoke_width = 14,
  nut_across_flats = 7,
  nut_height = 3.2,
  nut_clearance = 0.3,
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
  // A slot inboard of the cut is a void under the rubber, so the clamp circle has to clear the
  // whole blank, not just the finished ring.
  assert(
    clamp_radius - clamp_travel - pin_diameter / 2 > outer_diameter / 2,
    str(
      "gasket_cutter: the clamp slots reach r ", clamp_radius - clamp_travel - pin_diameter / 2,
      " mm and the blank is cut at r ", outer_diameter / 2, " mm; raise gasket_cutter_clamp_radius."
    )
  );
  assert(
    platen_height > nut_height + nut_clearance,
    str("gasket_cutter: a ", platen_height, " mm platen cannot bury a ", nut_height, " mm nut.")
  );
  // The inner cut has to land on the platen, not over its bore.
  assert(
    inner_diameter / 2 > platen_bore + rim / 2,
    str(
      "gasket_cutter: the platen's bore reaches r ", platen_bore, " mm and the ring is cut at r ",
      inner_diameter / 2, " mm; lower platen_bore."
    )
  );

  _seat_depth = thickness - grip; // the blank stands proud by grip, so the plate lands on rubber
  // The plate reaches the clamp circle whatever the gasket, so every size screws to the same base.
  _plate_d = max(outer_diameter + 2 * rim, 2 * (clamp_radius + rim));
  _screw_r = clamp_radius;
  _platen_d = 2 * (clamp_radius + clamp_travel + rim);
  _nut_w = nut_across_flats + nut_clearance;
  _nut_h = nut_height + nut_clearance;

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
        // The counterbore's mouth is flared, which is what makes the plate self-centring as it
        // comes down on a blank lying on the base. Without it the only way to get the blank into
        // the seat is to load it into an upturned plate and turn the pair over.
        cylinder(
          d1=outer_diameter + seat_clearance + 2 * seat_lead,
          d2=outer_diameter + seat_clearance,
          h=seat_lead
        );
        for (i = [0:2])
          rotate([0, 0, i * 120])
            translate([_screw_r, 0, -1])
              cylinder(d=pin_diameter, h=height * 3);
        translate([0, 0, height + _seat_depth]) _chamfer_in(inner_diameter);
      }
  }

  // Stage 3, and the only part that is not reprinted with the gasket. Solid under everything that
  // gets cut, because the blade comes through the rubber and has to land on something continuous:
  // the inner plate's counterbore has no floor of its own. Outboard of that, three slots let the
  // clamp screws sit at one radius whatever the gasket, each over a channel that holds its nut
  // against turning and lets it slide. The centre takes stage 1's single screw, and a short screw
  // left standing there also centres the blank for stage 2 - the hole it makes is inside the bore,
  // so it leaves with the waste.
  module _base() {
    module _slot(w, h) {
      hull()
        for (x = [clamp_radius - clamp_travel, clamp_radius + clamp_travel])
          translate([x, 0, 0]) cylinder(d=w, h=h);
    }
    // Everything the blade meets, and nothing else: the ring between the two cut circles, the rim
    // the clamp slots live in, a hub for stage 1's screw, and three spokes to carry it.
    module _spider() {
      difference() {
        cylinder(d=_platen_d, h=platen_height);
        translate([0, 0, -1])
          difference() {
            cylinder(r=platen_bore, h=platen_height + 2);
            cylinder(r=hub_radius, h=platen_height + 2);
            for (i = [0:2])
              rotate([0, 0, i * 120])
                translate([0, -spoke_width / 2, 0])
                  cube([platen_bore, spoke_width, platen_height + 2]);
          }
      }
    }
    color(colour)
      difference() {
        _spider();
        for (i = [0:2])
          rotate([0, 0, i * 120]) {
            translate([0, 0, -1]) _slot(pin_diameter, platen_height + 2);
            translate([0, 0, -1]) _slot(_nut_w, _nut_h + 1);
          }
        translate([0, 0, -1]) cylinder(d=pin_diameter, h=platen_height + 2);
        translate([0, 0, -1]) cylinder(d=_nut_w / cos(30), h=_nut_h + 1, $fn=6);
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
  if (part == "base" || part == "all")
    translate([part == "all" ? _plate_d + _platen_d + 20 : 0, 0, 0]) _base();
}
