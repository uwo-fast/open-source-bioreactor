/**
 * @file lid.scad
 * @brief Lid for holding to cap a jar or other cylindrical object
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * This file contains the lid for holding to cap a jar or other cylindrical object.
 *
 */

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

/**
 * @brief Generates a lid for holding to cap a jar or other cylindrical object.
 *
 * @param outer_diameter The outer diameter of the lid.
 * @param inner_diameter The inner diameter of the lid.
 * @param height_od The height of the outer diameter part of the lid.
 * @param height_id The height of the inner diameter part of the lid.
 * @param allowance The allowance between the outer and inner diameters.
 */
module lid(outer_diameter, inner_diameter, height_od, height_id, allowance) {
  union() {
    // flange of the lid
    cylinder(d=outer_diameter, h=height_od);

    // center closure extrusion
    translate([0, 0, height_od]) {
      cylinder(d=inner_diameter - allowance, h=height_id);
    }
  }
}
