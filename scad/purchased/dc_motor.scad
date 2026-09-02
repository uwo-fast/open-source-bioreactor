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

function dc_motor_name(type) = type[0]; // the row's identity, and the key a build designates it by
function dc_motor_part_number(type) = type[9]; // what to order it by; undef where nothing is sold
function dc_motor_diameter(type) = type[1][0]; // diameter of the motor
function dc_motor_length(type) = type[1][1]; // length of the motor
function dc_motor_shaft(type) = type[2]; // [shaft_d, shaft_l] of the bare shaft, optional
function dc_motor_gearbox(type) = type[3]; // gearbox type mounted to the face, optional
function dc_motor_boss(type) = type[4]; // [boss_d, boss_l] raised boss around the shaft exit, optional
function dc_motor_face_screws(type) = type[5]; // [cdist, screw_d] of the motor's own face screws, optional
function dc_motor_output_speeds(type) = type[6]; // [no_load_rpm, rated_rpm] at the output, optional

// Split out so a caller asks for the one it means. Either half can be undef on its own - the 36GP
// publishes a no-load speed and no rated one - so callers check the half they use, not the pair.
function dc_motor_no_load_output_rpm(type) = is_undef(type[6]) ? undef : type[6][0];
function dc_motor_rated_output_rpm(type) = is_undef(type[6]) ? undef : type[6][1];

// The torque rated speed is quoted at. Stored in N m; this family's sheets publish kg.cm.
function dc_motor_rated_output_torque(type) = type[7];

function dc_motor_encoder(type) = type[8]; // [ppr, channels] of a fitted encoder, optional

// Counts per turn of the OUTPUT shaft, decoding every edge of every channel and taken through the
// reduction - which is where most of the resolution comes from, the encoder itself sitting on the
// motor shaft ahead of the gearbox.
function dc_motor_encoder_counts_per_output_rev(type) =
  let (e = dc_motor_encoder(type), g = dc_motor_gearbox(type))
    is_undef(e) || is_undef(g) ? undef : e[0] * 2 * e[1] * gearbox_ratio(g);

/**
 * @brief Create a DC motor from a registered type
 * @param type Registered parameter set (see dc_motors.scad)
 *
 * A bare shaft (type[2]), a gearbox (type[3]) and a shaft boss (type[4]) are drawn when
 * present. The gearbox seats on the motor face; any shaft is left in place and covered.
 * Shaft length is free length past the boss, not from the motor face.
 */
module dc_motor(type) {
  diameter = dc_motor_diameter(type);
  length = dc_motor_length(type);
  shaft = dc_motor_shaft(type);
  gearbox_type = dc_motor_gearbox(type);
  boss = dc_motor_boss(type);

  boss_length = is_undef(boss) ? 0 : boss[1];

  union() {
    color(light_grey)
      cylinder(d=diameter, h=length);

    if (!is_undef(boss))
      color(light_grey)
        translate([0, 0, length])
          cylinder(d=boss[0], h=boss[1]);

    if (!is_undef(shaft))
      color(medium_grey)
        translate([0, 0, length + boss_length])
          cylinder(d=shaft[0], h=shaft[1]);

    if (!is_undef(gearbox_type))
      translate([0, 0, length])
        gearbox(gearbox_type);
  }
}
