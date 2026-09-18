/**
 * @file stir_bar.scad
 * @brief A magnetic stir bar, drawn lying along x with its axis at the origin
 * @author Cameron K. Brooks
 * @copyright 2026
 */

$fn = $preview ? 64 : 128;

function stir_bar_name(type) = type[0];
function stir_bar_part_number(type) = type[1];
function stir_bar_length(type) = type[2][0];
function stir_bar_diameter(type) = type[2][1];

/**
 * @brief Draws a registered stir bar (see stir_bars.scad): a cylinder with domed ends
 * @param type Registered parameter set
 */
module stir_bar(type) {
  length = stir_bar_length(type);
  diameter = stir_bar_diameter(type);

  color("white") {
    rotate([0, 90, 0])
      cylinder(d=diameter, h=length - diameter, center=true);
    for (s = [-1, 1])
      translate([s * (length - diameter) / 2, 0, 0])
        sphere(d=diameter);
  }
}
