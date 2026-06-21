/**
 * @file gearbox.scad
 * @brief Gearbox model that mounts to the face of a dc_motor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 */

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

medium_grey = [0.5, 0.5, 0.5];
grey = [0.4, 0.4, 0.4];
dark_grey = [0.3, 0.3, 0.3];

function gearbox_diameter(type) = type[1][0];             // diameter of the gearbox body
function gearbox_length(type) = type[1][1];               // length of the gearbox body
function gearbox_output_shaft_dia(type) = type[2][0];     // diameter of the output shaft
function gearbox_output_shaft_length(type) = type[2][1];  // length of the output shaft
function gearbox_input_shaft_dia(type) = type[3][0];      // diameter of the input shaft bore, optional
function gearbox_input_shaft_length(type) = type[3][1];   // depth of the input shaft bore, optional
function gearbox_faceplate_screws_cdist(type) = type[4];  // centre distance of the faceplate screws
function gearbox_screw_diameter(type) = type[5];          // diameter of the faceplate screws

/**
 * @brief Create a gearbox from a registered type
 * @param type Registered parameter set (see gearboxes.scad)
 */
module gearbox(type) {
  diameter = gearbox_diameter(type);
  length = gearbox_length(type);
  output_shaft_diameter = gearbox_output_shaft_dia(type);
  output_shaft_length = gearbox_output_shaft_length(type);
  input_shaft_diameter = gearbox_input_shaft_dia(type);
  input_shaft_length = gearbox_input_shaft_length(type);
  faceplate_screws_cdist = gearbox_faceplate_screws_cdist(type);
  screw_diameter = gearbox_screw_diameter(type);

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
