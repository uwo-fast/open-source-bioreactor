/**
 * @file sheet_gasket.scad
 * @brief Flat ring gasket, cut from sheet stock
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Not a catalogue part, which is why it has no registry: only the sheet is bought, and the ring's
 * diameters come from whatever it seals - here the flat land on top of the jar's rim. So the
 * caller passes the cut, and the consumer that knows the vessel derives it.
 *
 * Drawn at its free thickness, like the o-rings: installed it is squeezed into a shallower
 * recess, and the difference standing proud is the compression.
 */

$fn = $preview ? 64 : 128;

sheet_gasket(inner_diameter=145, outer_diameter=151, thickness=1.5);

/**
 * @brief A flat annular gasket.
 * @param inner_diameter Cut inside diameter
 * @param outer_diameter Cut outside diameter
 * @param thickness      Thickness of the stock it is cut from
 * @param colour         As supplied
 */
module sheet_gasket(inner_diameter, outer_diameter, thickness, colour = "Black") {
  assert(
    outer_diameter > inner_diameter,
    str("sheet_gasket: outer_diameter (", outer_diameter, ") must exceed inner_diameter (", inner_diameter, ")")
  );

  color(colour)
    linear_extrude(thickness)
      difference() {
        circle(d=outer_diameter);
        circle(d=inner_diameter);
      }
}
