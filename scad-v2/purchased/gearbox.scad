/**
 * @file gearbox.scad
 * @brief Gearbox model that mounts to the face of a dc_motor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 */

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

medium_grey = [0.5, 0.5, 0.5];
grey = [0.4, 0.4, 0.4];
dark_grey = [0.3, 0.3, 0.3];

function gearbox_diameter(type) = type[1][0]; // diameter of the gearbox body
function gearbox_length(type) = type[1][1]; // length of the gearbox body
function gearbox_output_shaft_dia(type) = type[2][0]; // diameter of the output shaft
function gearbox_output_shaft_length(type) = type[2][1]; // length of the output shaft
function gearbox_input_shaft_dia(type) = type[3][0]; // diameter of the input shaft bore, optional
function gearbox_input_shaft_length(type) = type[3][1]; // depth of the input shaft bore, optional
function gearbox_faceplate_screws_cdist(type) = type[4]; // centre distance of the faceplate screws
function gearbox_screw_diameter(type) = type[5]; // diameter of the faceplate screws
function gearbox_out_boss(type) = type[6]; // [boss_d, boss_l] pilot boss on the output face, optional
function gearbox_in_boss(type) = type[7]; // [boss_d, boss_l] recess in the input face, optional

// The input pockets are registered at the motor's own boss and shaft dimensions, because that
// is what they receive, so a motor seats in them face to face and CGAL will not call the union
// 2-manifold. Opening them by a hair keeps the mesh clean. This is a render allowance, not a
// fit, which is why it lives here instead of in the registry.
gearbox_input_render_allowance = 0.2;

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
  out_boss = gearbox_out_boss(type);
  in_boss = gearbox_in_boss(type);

  // Neither boss counts toward `length`, which stays the body length, the same way dc_motor
  // keeps the motor's own boss out of its length. The output boss stands the shaft off the
  // face instead of eating into it, so output_shaft_length remains free length past the boss;
  // the input boss is a recess, so the input bore has to start below it to reach as deep.
  out_boss_length = is_undef(out_boss) ? 0 : out_boss[1];
  in_boss_depth = is_undef(in_boss) ? 0 : in_boss[1];

  cut_dim = screw_diameter * 1.1;

  difference() {
    // gearbox body
    union() {
      color(dark_grey)
        cylinder(d=diameter, h=length);

      // pilot boss standing off the output face
      if (!is_undef(out_boss))
        color(dark_grey)
          translate([0, 0, length])
            cylinder(d=out_boss[0], h=out_boss[1]);

      color(medium_grey)
        translate([0, 0, length + out_boss_length])
          cylinder(d=output_shaft_diameter, h=output_shaft_length);
    }

    // recess in the input face that receives the motor's boss
    if (!is_undef(in_boss))
      translate([0, 0, -z_fight])
        cylinder(
          d=in_boss[0] + gearbox_input_render_allowance,
          h=in_boss[1] + gearbox_input_render_allowance + z_fight
        );

    // remove pocket for input shaft, sunk past the input boss recess
    if (!is_undef(input_shaft_diameter) && !is_undef(input_shaft_length))
      translate([0, 0, -z_fight])
        cylinder(
          d=input_shaft_diameter + gearbox_input_render_allowance,
          h=in_boss_depth + input_shaft_length + gearbox_input_render_allowance + z_fight
        );

    // remove spot where gearbox screws sit
    for (i = [0:3]) {
      rotate([0, 0, i * 90 + 45])
        translate([diameter / 2 - cut_dim / 2, 0, length - cut_dim / 2 + z_fight])
          cube([cut_dim, cut_dim, cut_dim], center=true);
    }

    // remove spot where faceplate screw holes
    for (i = [0:3]) {
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
