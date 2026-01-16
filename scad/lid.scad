/**
 * @file lid.scad
 * @brief Lid for holding to cap a jar or other cylindrical object
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains the lid for holding to cap a jar or other cylindrical object.
 *
 */

include <_config.scad>;

/**
 * @brief Generates a lid for holding to cap a jar or other cylindrical object.
 *
 * @param outer_diameter The outer diameter of the lid.
 * @param inner_diameter The inner diameter of the lid.
 * @param height The height of the lid.
 * @param allowance The allowance between the outer and inner diameters.
 * @param rod_hole_diameter The diameter of the hole for rods.
 * @param nut_dia The diameter of the nuts.
 * @param nut_h The height of the nuts.
 */
module lid(outer_diameter, inner_diameter, height, allowance, rod_hole_diameter, nut_dia, nut_h) {
  union() {

    cylinder(d=outer_diameter, h=height);
    translate([0, 0, height]) {
      cylinder(d=inner_diameter - allowance, h=height);
    }
  }
}
