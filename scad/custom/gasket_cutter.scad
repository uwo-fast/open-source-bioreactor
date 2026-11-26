/**
 * @file gasket_cutter.scad
 * @brief Printed templates for cutting a flat ring gasket from sheet stock
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A tool, not a reactor part. It takes the same three values as custom/sheet_gasket.scad (the cut
 * diameters and the stock thickness) and needs nothing else about the joint the ring seals.
 *
 * There are two stages, because a template as narrow as the ring is too flexible to guide a blade
 * along a line:
 *   1. "outer" is a plain disc at the outer diameter of the ring. Pin it and cut around it to make
 *      a blank.
 *   2. "inner" is a plate bored at the inner diameter, with a counterbore underneath at the outer
 *      diameter. The blank drops in concentric and the bore guides the second cut.
 *
 * Both stages work against "base", the third part and the only one that is not reprinted when the
 * gasket changes. It is the cutting surface: the counterbore has no floor, so the blade goes
 * through the rubber into the base. It also holds the nuts, and both stages screw to it, so
 * neither has to be aligned on a board by eye. For this reason the clamp circle is at a fixed
 * radius instead of following the gasket size. A slot at a varying radius would fall under the cut
 * line at some size, and a void under the cut leaves the rubber unsupported.
 * All three parts print flat without support.
 */

$fn = $preview ? 64 : 128;

// Clamp positions on the base for every stage. They are fixed, not derived from the gasket, so one
// base serves every size. A slot must never lie under a cut. The cuts of the registered vessels
// fall in two groups: r 43.75 to 51.9 for the small jars and r 69.5 to 82.5 for the large ones. So
// there are two clamp circles. One lies in the gap between the groups and is used by the small
// gaskets, which keeps their plates small. The other lies outside all cuts and is used by the
// large gaskets.
gasket_cutter_clamp_radius = 92;
gasket_cutter_clamp_travel = 5;
gasket_cutter_clamp_inner_radius = 61;
gasket_cutter_clamp_inner_travel = 3;

gasket_cutter(inner_diameter=145, outer_diameter=151, thickness=1.5875);

/**
 * @brief Templates for cutting a flat ring gasket.
 * @param inner_diameter Cut inside diameter, as sheet_gasket() takes it
 * @param outer_diameter Cut outside diameter
 * @param thickness      Thickness of the stock being cut
 * @param part           "all", "outer", "inner" or "base"
 * @param height         Guide face height, which holds the blade upright through the cut
 * @param rim            Material outside the guide bore on the inner plate, for grip and screws
 * @param grip           Amount by which the blank is thicker than the counterbore depth, so the
 *                       inner plate squeezes it
 * @param pin_diameter   Clearance hole for the screw that pins a template to the backing board
 * @param seat_clearance Added to the counterbore so a cut blank drops in
 * @param chamfer        Relief at the bed edge of the disc, so a squashed first layer cannot stand
 *                       proud of the guide face. Also the lead-in at the mouth of the bore
 * @param seat_lead      Flare at the mouth of the counterbore. It lets the plate be lowered onto a
 *                       blank lying on the base, instead of loading the blank into an upturned
 *                       plate and turning both over
 * @param clamp_radius   Outer clamp circle, outside the cuts of every registered vessel. Gaskets
 *                       too large for the inner circle use this one
 * @param clamp_travel   Half the slot length in the base for those screws
 * @param clamp_inner_radius Inner clamp circle, in the gap between the cuts of the small jars and
 *                       the large ones. A gasket whose outer cut clears it clamps here instead,
 *                       which keeps the plate for a small gasket small
 * @param clamp_inner_travel Half the slot length on that circle. It is shorter than the outer one
 *                       because the gap it sits in is only 17.6 mm wide
 * @param platen_height  Base thickness; the blade goes through the rubber into it
 * @param platen_bore    Hole through the middle of the base. Nothing is cut inside the smallest
 *                       inner diameter, so the platen only has to be continuous under the two cut
 *                       circles, and the middle is carried on spokes. The default clears the
 *                       smallest ring of any registered vessel, which is cut at r 43.75. A base
 *                       for a single jar can use a much larger bore
 * @param hub_radius     Material around the central nut of the base, where stage 1 screws down
 * @param spoke_width    Width of the three ribs that carry that hub
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
  clamp_inner_radius = gasket_cutter_clamp_inner_radius,
  clamp_inner_travel = gasket_cutter_clamp_inner_travel,
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
  // A slot under a cut leaves the rubber over a void, so BOTH circles must miss the band this
  // gasket is cut in, including the circle it does not clamp on.
  assert(
    _inner_slot_hi < inner_diameter / 2 || _inner_slot_lo > outer_diameter / 2,
    str(
      "gasket_cutter: the inner clamp slots span r ", _inner_slot_lo, " to ", _inner_slot_hi,
      " mm and this ring is cut from r ", inner_diameter / 2, " to ", outer_diameter / 2,
      " mm; move gasket_cutter_clamp_inner_radius out of that band."
    )
  );
  assert(
    _outer_slot_lo > outer_diameter / 2,
    str(
      "gasket_cutter: the outer clamp slots reach r ", _outer_slot_lo,
      " mm and the blank is cut at r ", outer_diameter / 2, " mm; raise gasket_cutter_clamp_radius."
    )
  );
  assert(
    platen_height > nut_height + nut_clearance,
    str("gasket_cutter: a ", platen_height, " mm platen cannot bury a ", nut_height, " mm nut.")
  );
  // The inner cut must fall on the platen, not over its bore.
  assert(
    inner_diameter / 2 > platen_bore + rim / 2,
    str(
      "gasket_cutter: the platen's bore reaches r ", platen_bore, " mm and the ring is cut at r ",
      inner_diameter / 2, " mm; lower platen_bore."
    )
  );

  _seat_depth = thickness - grip; // the blank stands proud by grip, so the plate bears on rubber
  // The full length of each slot must miss the cuts of this gasket, and the plate needs full
  // thickness where the screw passes through, outside the counterbore. The inner circle is used
  // when the blank clears it, because that keeps the plate for a small gasket small.
  _inner_slot_lo = clamp_inner_radius - clamp_inner_travel - pin_diameter / 2;
  _inner_slot_hi = clamp_inner_radius + clamp_inner_travel + pin_diameter / 2;
  _outer_slot_lo = clamp_radius - clamp_travel - pin_diameter / 2;
  _uses_inner = outer_diameter / 2 < _inner_slot_lo;
  _screw_r = _uses_inner ? clamp_inner_radius : clamp_radius;
  _plate_d = max(outer_diameter + 2 * rim, 2 * (_screw_r + rim));
  _platen_d = 2 * (clamp_radius + clamp_travel + rim);
  _nut_w = nut_across_flats + nut_clearance;
  _nut_h = nut_height + nut_clearance;

  // Stage 1. Cut around the outside of this part. It is a solid disc instead of a ring because
  // nothing needs to reach its centre, and the solid disc is stiff enough to cut against.
  //
  // The bed edge is drawn UNDERSIZE and flared out to the guide diameter, instead of being
  // chamfered from it. Otherwise a first layer that squashes outward would stand proud of the face
  // that guides the blade, and every blank would be oversize by that amount.
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
        // The flared mouth of the counterbore makes the plate self-centring as it is lowered onto
        // a blank lying on the base. Without it, the blank can only be seated by loading it into
        // an upturned plate and turning both over.
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

  // Stage 3, the only part that is not reprinted for each gasket. It is solid under every cut,
  // because the blade goes through the rubber and must meet a continuous surface; the counterbore
  // in the inner plate has no floor. Outside that, three slots hold the clamp screws at a fixed
  // radius for any gasket. Each slot sits over a channel that stops its nut turning and lets it
  // slide. The centre takes the single screw for stage 1. A short screw left in place there also
  // centres the blank for stage 2. The hole it makes is inside the bore, so it is cut away with
  // the waste.
  module _base() {
    module _slot(r, travel, w, h) {
      hull()
        for (x = [r - travel, r + travel])
          translate([x, 0, 0]) cylinder(d=w, h=h);
    }
    // Only the material the blade meets: the ring between the two cut circles, the rim that holds
    // the clamp slots, a hub for the stage 1 screw, and three spokes that carry the hub.
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
          rotate([0, 0, i * 120])
            for (c = [[clamp_radius, clamp_travel], [clamp_inner_radius, clamp_inner_travel]]) {
              translate([0, 0, -1]) _slot(c[0], c[1], pin_diameter, platen_height + 2);
              translate([0, 0, -1]) _slot(c[0], c[1], _nut_w, _nut_h + 1);
            }
        translate([0, 0, -1]) cylinder(d=pin_diameter, h=platen_height + 2);
        translate([0, 0, -1]) cylinder(d=_nut_w / cos(30), h=_nut_h + 1, $fn=6);
      }
  }

  // Lead-in at the mouth of the bore, so the blade meets the guide face instead of the top corner.
  // Only the mouth needs it: the other end of the bore stops at the counterbore roof and never
  // meets the bed, so there is no first layer there to relieve.
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
