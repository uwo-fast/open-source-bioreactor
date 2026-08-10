/**
 * @file frame.scad
 * @brief Frame subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

use <custom/base.scad>;

include <purchased/strip_lights.scad>;

include <NopSCADlib/core.scad>; // core utils (also silences the inch() warning)
include <NopSCADlib/vitamins/nuts.scad>; // M8_nut type + nut()
use <NopSCADlib/vitamins/rod.scad>; // studding()

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// -------

render_all = true; // render all components
render_base = false;
render_upper_base = false;
render_ribs = false;
render_rods = false;
render_rodspacers = false;
render_lights = false;

// -------

frame(vessel_height=305, vessel_outer_diameter=220, lights_length=330, wall_thickness=37, rod_length=313);

// -------

/* [Light Parameters] */

// the registered strip light the base is pocketed for; every light dimension is read back
// out of it via the accessor functions (see purchased/strip_light.scad)
frame_light = rwntao_13in; // [generic_strip_light, rwntao_13in, grow_13in, grow_16in, grow_8p6in]
// which quadrants to place lights in, 1-4 starting from positive x and going CCW
light_quadrants = [1, 3];
// number of lights to place in each quadrant
lights_per_quadrant = 3;
// angle that the lights occupy
occupy_angle = 60; // of the 90 degree quadrant
// allowance for the light to fit in the base
light_allow = 0.4;

/* [Nut & Rod Parameters] */

// diameter of the threaded rod
threaded_rod_diameter = 8.0; // M8
// allowance for the nut pocket to fit the nut
nut_pocket_allowance = 0.6;
// allowance for the hole for the threaded rod
threaded_rod_hole_allowance = 1.2;

// diameter of the nut
nut_pocket_diameter = 2 * nut_radius(M8_nut) + nut_pocket_allowance;
// height of the nut
nut_height = nut_thickness(M8_nut);

/* [Base Parameters] */

// allowance for the jar to fit in the base
base_jar_fit_allow = 0.4;

// height of the bottom base (holding jar)
lower_base_wall_height = 25;
// height of the top base (holding lid)
upper_base_height = 10;
// height of the rib base
rib_base_height = 10;
// stack a second rib at each level, rotated to close the arc the pair below leaves open
double_ribs = true;

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

module lights(quadrants, vessel_outer_diameter, lights_per_quadrant, occupy_angle, allowance_cutout = undef) {
  for (q = quadrants) {
    rotate([0, 0, (q - 1) * 90]) {
      for (i = [0:lights_per_quadrant - 1]) {

        angle_offset = (90 - occupy_angle) / 2;
        light_angle =
          lights_per_quadrant == 1 ? 45
          : i * (occupy_angle / (lights_per_quadrant - 1)) + angle_offset;

        rotate([0, 0, light_angle])
          translate([0, vessel_outer_diameter / 2, 0]) if (is_undef(allowance_cutout)) {
            strip_light(frame_light);
          } else {
            translate([0, strip_light_depth(frame_light) / 2, strip_light_length(frame_light) / 2])
              cube([strip_light_width(frame_light) + allowance_cutout, strip_light_depth(frame_light) + allowance_cutout, strip_light_length(frame_light)], center=true);

            // same profile on its side, cut radially thru the wall so the cord can escape
            translate([0, vessel_outer_diameter / 2, (strip_light_depth(frame_light) + allowance_cutout) / 2 - z_fight/2])
              cube([strip_light_width(frame_light) + allowance_cutout, vessel_outer_diameter, strip_light_depth(frame_light) + allowance_cutout], center=true);
          }
      }
    }
  }
}

module frame(vessel_height, vessel_outer_diameter, lights_length, wall_thickness, rod_length) {

  _base_floor_height_min = 2; // minimum height of the base floor

  height_delta = (lights_length + nut_height * 1.5 + upper_base_height) - vessel_height; // 150% nut thickness added so radial bolt heads have clearance
  base_floor_height = height_delta > _base_floor_height_min ? height_delta : _base_floor_height_min;

  // total height of the assembly
  total_height = vessel_height + base_floor_height;

  // diameter of the cutout for the jar
  base_jar_cut_diameter = vessel_outer_diameter + base_jar_fit_allow;

  // diameter of the hole for the threaded rod
  threaded_rod_hole_diameter = threaded_rod_diameter + threaded_rod_hole_allowance;

  // distance from the center of the jar to the threaded rod
  rod_shift = base_jar_cut_diameter / 2 + threaded_rod_hole_diameter;

  lower_base_height = base_floor_height + lower_base_wall_height;

  // ribs and spacers share one stack, so both read these rather than deriving them separately
  // TODO: n_rib_levels is still hardcoded to 2 by the loops below
  n_rib_levels = 2;
  ribs_per_level = double_ribs ? 2 : 1;
  rib_level_height = rib_base_height * ribs_per_level;
  spacers_total_height = total_height - upper_base_height - lower_base_height - rib_level_height * n_rib_levels;
  z_shift_factor = 1 / (n_rib_levels + 1);

  // distance from the center of the jar to the threaded rod
  base_wall_thickness_from_lights = (strip_light_depth(frame_light) * 1.5) * 2; // thinnest part is 50% thicker than the light depth

  base_wall_thickness_from_rod = threaded_rod_hole_diameter * 4; // thinnest part is 4x the rod diameter or approx x2 the nut diameter

  assert(
    wall_thickness >= max(base_wall_thickness_from_lights, base_wall_thickness_from_rod),
    str(
      "Base wall thickness is too thin. Must be at least ",
      max(base_wall_thickness_from_lights, base_wall_thickness_from_rod),
      " mm."
    )
  );

  _base_wall_thickness = wall_thickness;

  echo("base wall thickness: ", _base_wall_thickness / 10, " cm");

  module frame_lights(local_quadrants = light_quadrants) {
    lights(local_quadrants, vessel_outer_diameter, lights_per_quadrant, occupy_angle);
  }

  module frame_lights_cutout(local_quadrants = [1, 2, 3, 4]) {
    difference() {
      children();
      lights(local_quadrants, vessel_outer_diameter, lights_per_quadrant, occupy_angle, allowance_cutout=light_allow);
    }
  }

  // Translate entire frame down by the height of the base floor
  // Since design is located based on the bottom of the vessel
  translate([0, 0, -base_floor_height - z_fight]) {
    if (render_lights || render_all) {
      frame_lights();
    }

    // rods and nuts
    if (render_rods || render_all) {
      for (i = [0:3]) {
        rotate([0, 0, i * 90])
          translate([rod_shift, 0, 0]) {

            // M8 threaded rod, full height (base at z = 0)
            translate([0, 0, base_floor_height])
            studding(d=threaded_rod_diameter, l=rod_length, center=false);

            // within of base
            translate([0, 0, base_floor_height])
              rotate([0, 0, 30])
                nut(M8_nut);

            // top of lid
            translate([0, 0, total_height - nut_height - z_fight])
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
            inner_diameter=base_jar_cut_diameter, height=lower_base_height, wall_thickness=_base_wall_thickness,
            floor_height=base_floor_height, rod_hole_diameter=threaded_rod_hole_diameter, nut_dia=nut_pocket_diameter,
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
                inner_diameter=base_jar_cut_diameter, height=upper_base_height, wall_thickness=_base_wall_thickness,
                floor_height=base_floor_height, rod_hole_diameter=threaded_rod_hole_diameter
              );
    }

    // ribs
    if (render_ribs || render_all) {
      // Number of rods holders on the ribs
      n_rods_ribs = 2;

      // create the ribs
      for (i = [1:2]) {

        z_shift = spacers_total_height * i * z_shift_factor;

        rib_pos = lower_base_height + z_shift - spacer_z_allow / 2 + rib_level_height * (i - 1);

        f_height = 0 - z_fight;

        frame_lights_cutout()

        // a 2-rod base is a 90 degree arc, so the j pair leaves two gaps; k stacks a second
        // pair on the first pair's rod bosses, turned 90 to fill them
        for (j = [1:2], k = [0:ribs_per_level - 1]) {
          rotate([0, 0, j * 180 + k * 90])
            rotate([0, 0, i * 90])
              translate([0, 0, rib_pos + k * rib_base_height])
                color(prints1_color)
                  base(
                    inner_diameter=base_jar_cut_diameter, height=rib_base_height,
                    wall_thickness=_base_wall_thickness, floor_height=f_height,
                    rod_hole_diameter=threaded_rod_hole_diameter, rods=n_rods_ribs
                  );
        }
      }
    }

    // rod rib spacers
    if (render_rodspacers || render_all) {
      rod_spacer_diameter = threaded_rod_diameter + 2 * rod_spacer_thickness;

      color(prints2_color)for (i = [0:2]) {
        for (j = [0:3]) {

          z_shift = spacers_total_height * i * z_shift_factor;

          spacer_pos = lower_base_height + z_shift + spacer_z_allow / 2 + rib_level_height * i;

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
}
