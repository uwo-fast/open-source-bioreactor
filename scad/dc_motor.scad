/**
 * @file dc_motor.scad
 * @brief DC motor and gearbox model
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 */

include <_config.scad>;

/**
 * @brief Create a basic DC motor model
 * @param diameter The diameter of the motor
 * @param length The length of the motor
 * @param shaft_diameter The diameter of the motor shaft, optional
 * @param shaft_length The length of the motor shaft, optional
 */
module dcmotor(diameter, length, shaft_diameter = undef, shaft_length = undef) {
  union() {
    color([0.6, 0.6, 0.6]) cylinder(d=diameter, h=length);
    if (!is_undef(shaft_diameter) && !is_undef(shaft_length))
      color([0.5, 0.5, 0.5]) translate([0, 0, length]) cylinder(d=shaft_diameter, h=shaft_length);
  }
}

/**
 * @brief Create a basic gearbox model
 * @param diameter The diameter of the gearbox
 * @param length The length of the gearbox
 * @param output_shaft_diameter The diameter of the output shaft
 * @param output_shaft_length The length of the output shaft
 * @param input_shaft_diameter The diameter of the input shaft, optional
 * @param input_shaft_length The length of the input shaft, optional
 * @param faceplate_screws_cdist The distance between the screws that attach the faceplate to the gearbox
 * @param screw_diameter The diameter of the screws that attach the gearbox to the base, optional
 */
module gearbox(
  diameter,
  length,
  output_shaft_diameter,
  output_shaft_length,
  input_shaft_diameter,
  input_shaft_length,
  faceplate_screws_cdist,
  screw_diameter = 5
) {
  cut_dim = screw_diameter * 1.1;

  union() {
    difference() {
      // gearbox body
      union() {
        color([0.3, 0.3, 0.3]) cylinder(d=diameter, h=length);
        color([0.5, 0.5, 0.5]) translate([0, 0, length])
            cylinder(d=output_shaft_diameter, h=output_shaft_length);
      }

      // remove pocket for input shaft
      if (!is_undef(input_shaft_diameter) && !is_undef(input_shaft_length))
        translate([0, 0, -zFite]) color([0.3, 0.4, 0.4])
            cylinder(d=input_shaft_diameter, h=input_shaft_length);

      // remove spot where gearbox screws sit
      for (i = [0:3]) {
        rotate([0, 0, i * 90 + 45]) translate([diameter / 2 - cut_dim / 2, 0, length - cut_dim / 2 + zFite])
            color([0.3, 0.4, 0.4]) cube([cut_dim, cut_dim, cut_dim], center=true);
      }

      // remove spot where faceplate screw holes
      for (i = [0:3]) {
        rotate([0, 0, i * 90])
          translate([faceplate_screws_cdist / 2, 0, length - screw_diameter / 2 + zFite])
            color([0.3, 0.4, 0.4]) cylinder(d=screw_diameter, h=screw_diameter * 2, center=true);
      }
    }
    // add the screws
    for (i = [0:3]) {
      rotate([0, 0, i * 90 + 45]) translate([diameter / 2 - cut_dim / 2, 0, length - cut_dim + zFite])
          color([0.4, 0.4, 0.4]) screwhead(screw_diameter);
    }
  }
}

/**
 * @brief Create a basic screw head shape
 * @param diameter The diameter of the screw head
 */
module screwhead(diameter) {
  union() {
    cylinder(d=diameter, h=diameter / 2);
    translate([0, 0, diameter / 2]) scale([1, 1, 0.5]) sphere(d=diameter);
  }
}
