/**
 * @file frame.scad
 * @brief Frame subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

include <purchased/strip_lights.scad>;

include <NopSCADlib/core.scad>; // core utils (also silences the inch() warning)
include <NopSCADlib/vitamins/nuts.scad>; // M8_nut type + nut()
use <NopSCADlib/vitamins/rod.scad>; // studding()

use <custom/base.scad>;

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

temp_jar_height = 305;
temp_jar_diameter = 220;
jar_x_sec = false;

frame(temp_jar_height, temp_jar_diameter);

// -------

render_all = true; // render all components
render_base = false;
render_upper_base = false;
render_ribs = false;
render_rods = false;
render_rodspacers = false;
render_lights = false;

/* [Light Parameters] */

// which quadrants to place lights in, 1-4 starting from positive x and going CCW
light_quadrants = [1, 3];
// number of lights to place in each quadrant
lights_per_quadrant = 3;
// angle that the lights occupy
occupy_angle = 60; // of the 90 degree quadrant
// allowance for the light to fit in the base
light_allow = 0.2;

/* [Nut & Rod Parameters] */

// nut irl is size 6  (d=14.5mm)
// diameter of the nut
nut_diameter = 15.4;
// height of the nut
nut_height = 6.4;
// diameter of the threaded rod
threaded_rod_diameter = 8.0;
// allowance for the hole for the threaded rod
threaded_rod_hole_allowance = 1.2;

/*********************************************/
/*         Custom-Design Constraints         */
/*********************************************/

/* [Base Parameters] */

// allowance for the jar to fit in the base
base_jar_fit_allow = 0.4;
// height of the floor of the base
base_floor_height = 3;
// height of the bottom base (holding jar)
lower_base_height = 25;
// height of the top base (holding lid)
upper_base_height = 10;
// height of the rib base
rib_base_height = 10;

/* [Rod Spacer Parameters] */

// thickness of the rod spacer
rod_spacer_thickness = 2;
// allowance for the rod spacer to fit on the rod
spacer_dia_allow = 0.2;
// allowance for the rod spacer to fit on the rod
spacer_z_allow = 0.4;

/* [Color Parameters] */

// first color for 3D prints
prints1_color = "DarkSlateGray";
// second color for 3D prints
prints2_color = "SlateBlue";

module dummy() {
  // stop the customizer detection from here onwards
}

// total height of the assembly
total_height = temp_jar_height + base_floor_height + upper_base_height;
// distance from the center of the jar to the threaded rod
base_wall_thickness = (strip_light_depth(generic) * 1.5) * 2; // thinnest part is 50% thicker than the light depth
// diameter of the cutout for the jar
base_jar_cut_diameter = temp_jar_diameter + base_jar_fit_allow;

// diameter of the hole for the threaded rod
threaded_rod_hole_diameter = threaded_rod_diameter + threaded_rod_hole_allowance;

// distance from the center of the jar to the threaded rod
rod_shift = base_jar_cut_diameter / 2 + threaded_rod_hole_diameter;
// height of the rod spacer
rod_length = total_height + nut_height;
echo("rod length: ", rod_length / 10, " cm");

module lights(quadrants, jar_diameter, lights_per_quadrant, occupy_angle) {
  for (q = quadrants) {
    rotate([0, 0, (q - 1) * 90]) {
      for (i = [0:lights_per_quadrant - 1]) {

        angle_offset = (90 - occupy_angle) / 2;
        light_angle =
          lights_per_quadrant == 1 ? 45
          : i * (occupy_angle / (lights_per_quadrant - 1)) + angle_offset;

        rotate([0, 0, light_angle])
          translate([0, jar_diameter / 2, 0])
            strip_light(generic);
      }
    }
  }
}

module frame(jar_height, jar_diameter) {

  module frame_lights(local_quadrants = light_quadrants) {
    lights(local_quadrants, jar_diameter, lights_per_quadrant, occupy_angle);
  }

  module frame_lights_cutout(local_quadrants = [1, 2, 3, 4]) {
    difference() {
      children();
      frame_lights(local_quadrants);
    }
  }

  frame_lights();

  // rods and nuts
  if (render_rods || render_all) {
    for (i = [0:3]) {
      rotate([0, 0, i * 90])
        translate([rod_shift, 0, 0]) {
          // M8 threaded rod, full height (base at z = 0)
          studding(d=threaded_rod_diameter, l=rod_length, center=false);

          // M8 nuts at three heights
          // bottom
          translate([0, 0, 0])
            rotate([0, 0, 30])
              nut(M8_nut);

          // top of base
          translate([0, 0, lower_base_height - nut_thickness(M8_nut)])
            rotate([0, 0, 30])
              nut(M8_nut);

          // top of lid
          translate([0, 0, total_height])
            rotate([0, 0, 30])
              nut(M8_nut);
        }
    }
  }

  // base
  if (render_base || render_all) {
    frame_lights_cutout()
      color(prints1_color)
        // create the base
        base(
          inner_diameter=base_jar_cut_diameter, height=lower_base_height, wall_thickness=base_wall_thickness,
          floor_height=base_floor_height, rod_hole_diameter=threaded_rod_hole_diameter, nut_dia=nut_diameter,
          nut_h=nut_height
        );
  }

  // top base
  if (render_upper_base || render_all) {
    frame_lights_cutout()
      color(prints1_color)
        translate([0, 0, total_height])
          rotate([0, 180, 0])
            base(
              inner_diameter=base_jar_cut_diameter, height=upper_base_height, wall_thickness=base_wall_thickness,
              floor_height=base_floor_height, rod_hole_diameter=threaded_rod_hole_diameter
            );
  }

  // ribs
  if (render_ribs || render_all) {
    // Number of rods holders on the ribs
    n_rods_ribs = 2;

    // TODO: this should be parameterized based on the desired number of ribs
    // right now its hardcoded to 2 ribs i.e. divides into 3 sections
    z_shift_factor = 1 / 3;

    // create the ribs
    for (i = [1:2]) {

      spacers_total_height =
      total_height - upper_base_height - lower_base_height - rib_base_height * 2;

      z_shift = spacers_total_height * i * z_shift_factor;

      rib_pos = lower_base_height + z_shift - spacer_z_allow / 2 + rib_base_height * i - rib_base_height;

      f_height = 0 - z_fight;

      frame_lights_cutout()

      for (j = [1:2]) {
        rotate([0, 0, j * 180])
          rotate([0, 0, i * 90])
            translate([0, 0, rib_pos])
              color(prints1_color)
                base(
                  inner_diameter=base_jar_cut_diameter, height=rib_base_height,
                  wall_thickness=base_wall_thickness, floor_height=f_height,
                  rod_hole_diameter=threaded_rod_hole_diameter, rods=n_rods_ribs
                );
      }
    }
  }

  // rod rib spacers
  if (render_rodspacers || render_all) {
    rod_spacer_diameter = threaded_rod_diameter + 2 * rod_spacer_thickness;

    // See the TODO in section above about the z_shift_factor
    z_shift_factor = 1 / 3;

    color(prints2_color)for (i = [0:2]) {
      for (j = [0:3]) {

        spacers_total_height =
        total_height - upper_base_height - lower_base_height - rib_base_height * 2;

        z_shift = spacers_total_height * i * z_shift_factor;

        spacer_pos = lower_base_height + z_shift + spacer_z_allow / 2 + rib_base_height * i;

        spacer_height = spacers_total_height * z_shift_factor - spacer_z_allow * 2;

        rotate([0, 0, j * 90])
          translate([rod_shift, 0, spacer_pos])
            difference() {
              cylinder(d=rod_spacer_diameter, h=spacer_height);
              cylinder(d=threaded_rod_diameter + spacer_dia_allow, h=spacer_height + z_fight);
            }
      }
    }
  }
}
