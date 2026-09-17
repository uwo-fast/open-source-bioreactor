/**
 * @file sheet_gasket.scad
 * @brief Flat ring gasket, cut from sheet stock
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Only the sheet is bought; the ring's diameters come from what it seals, so the caller passes the
 * cut. Drawn at its free thickness, so what stands proud of the recess is the compression.
 */

use <../purchased/gasket_sheets.scad>;

$fn = $preview ? 64 : 128;

// example usage - head.scad passes its own numbers
sheet_gasket(inner_diameter=145, outer_diameter=151,
             thickness=gasket_sheet_thickness(gasket_sheet_by_name("EPDM 1/16 60A")));

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
