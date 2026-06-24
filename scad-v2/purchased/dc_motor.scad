/**
 * @file dc_motor.scad
 * @brief DC motor model, optionally fitted with a gearbox
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 */

use <gearbox.scad>

light_grey = [0.6, 0.6, 0.6];
medium_grey = [0.5, 0.5, 0.5];

function dc_motor_diameter(type) = type[1][0]; // diameter of the motor
function dc_motor_length(type) = type[1][1]; // length of the motor
function dc_motor_shaft(type) = type[2]; // [shaft_d, shaft_l] of the bare shaft, optional
function dc_motor_gearbox(type) = type[3]; // gearbox type mounted to the face, optional

/**
 * @brief Create a DC motor from a registered type
 * @param type Registered parameter set (see dc_motors.scad)
 *
 * A bare shaft (type[2]) and/or a gearbox (type[3]) are drawn when present.
 * The gearbox seats on the motor face; any shaft is left in place and covered.
 */
module dc_motor(type) {
  diameter = dc_motor_diameter(type);
  length = dc_motor_length(type);
  shaft = dc_motor_shaft(type);
  gearbox_type = dc_motor_gearbox(type);

  union() {
    color(light_grey)
      cylinder(d=diameter, h=length);

    if (!is_undef(shaft))
      color(medium_grey)
        translate([0, 0, length])
          cylinder(d=shaft[0], h=shaft[1]);

    if (!is_undef(gearbox_type))
      translate([0, 0, length])
        gearbox(gearbox_type);
  }
}
