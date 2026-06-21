/**
 * @file dc_motor.scad
 * @brief DC motor and gearbox model
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 */

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

function dc_motor_diameter(type) = type[1][0]; // diameter of the motor
function dc_motor_length(type) = type[1][1]; // length of the motor
function gearbox_diameter(type) = type[2][0]; // diameter of the gearbox
function gearbox_length(type) = type[2][1]; // length of the gearbox
function gearbox_shaft_diameter(type) = type[2][2]; // diameter of the
function gearbox_shaft_length(type) = type[2][3]; // length of the gearbox shaft

light_grey = [0.6, 0.6, 0.6];
medium_grey = [0.5, 0.5, 0.5];
grey = [0.4, 0.4, 0.4];
dark_grey = [0.3, 0.3, 0.3];

/**
 * @brief Create a basic DC motor model
 * @param diameter The diameter of the motor
 * @param length The length of the motor
 * @param shaft_diameter The diameter of the motor shaft, optional
 * @param shaft_length The length of the motor shaft, optional
 */
module dc_motor(diameter, length, shaft_diameter = undef, shaft_length = undef) {
  union() {
    color(light_grey)
      cylinder(d=diameter, h=length);

    if (!is_undef(shaft_diameter) && !is_undef(shaft_length))
      color(medium_grey)
        translate([0, 0, length])
          cylinder(d=shaft_diameter, h=shaft_length);
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

  difference() {
    // gearbox body
    union() {
      color(dark_grey)
        cylinder(d=diameter, h=length);
      color(medium_grey)
        translate([0, 0, length])
          cylinder(d=output_shaft_diameter, h=output_shaft_length);
    }

    // remove pocket for input shaft
    if (!is_undef(input_shaft_diameter) && !is_undef(input_shaft_length))
      translate([0, 0, -z_fight])
        cylinder(d=input_shaft_diameter, h=input_shaft_length);

    // remove spot where gearbox screws sit
    for (i = [0:3]) {
      color(grey)
        rotate([0, 0, i * 90 + 45])
          translate([diameter / 2 - cut_dim / 2, 0, length - cut_dim / 2 + z_fight])
            cube([cut_dim, cut_dim, cut_dim], center=true);
    }

    // remove spot where faceplate screw holes
    for (i = [0:3]) {
      color(grey)
        rotate([0, 0, i * 90])
          translate([faceplate_screws_cdist / 2, 0, length - screw_diameter / 2 + z_fight])
            cylinder(d=screw_diameter, h=screw_diameter * 2, center=true);
    }
  }
  // add the screws
  for (i = [0:3]) {
    rotate([0, 0, i * 90 + 45])
      translate([diameter / 2 - cut_dim / 2, 0, length - cut_dim + z_fight])
        color(grey)
          screwhead(screw_diameter);
  }
}

/**
 * @brief Create a basic screw head shape
 * @param diameter The diameter of the screw head
 */
module screwhead(diameter) {
  union() {
    cylinder(d=diameter, h=diameter / 2);
    translate([0, 0, diameter / 2])
      scale([1, 1, 0.5])
        sphere(d=diameter);
  }
}

gearbox(
  diameter=30,
  length=20,
  output_shaft_diameter=5,
  output_shaft_length=20,
  input_shaft_diameter=5,
  input_shaft_length=5,
  faceplate_screws_cdist=20,
  screw_diameter=3
);
