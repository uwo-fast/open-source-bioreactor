/**
 * @file frame.scad
 * @brief Frame subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

use <purchased/strip_light.scad>;
use <custom/base.scad>;
use <custom/peri_pump_frame_mount.scad>;

temp_jar_height = 305;
temp_jar_diameter = 220;
jar_x_sec = false;

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

frame(temp_jar_height, temp_jar_diameter);

// -------

render_all = true; // render all components
render_base = false;
render_upper_base = false;
render_lid = false;
render_bayonet_lock = false;
render_ribs = false;
render_rods = false;
render_rodspacers = false;
render_lights = false;
render_peri_side_mount = false;

/* [Light Parameters] */


// MOVED TO strip_lights.scad
// // length of the light
// light_length = 336;
// // width of the light
// light_width = 14.1;
// // depth of the light
// light_depth = 7.6;
// // radius of the light window
// light_window_radius = 0.5;

// allowance for the light to fit in the base
light_allow = 0.2;
// number of lights
number_of_lights = 6;
// angle that the lights occupy
occupy_angle = 90 * 3 / 4;

/* [Nut & Rod Parameters] */

// nut irl is size 6  (d=14.5mm)
// diameter of the nut
nut_diameter = 15.4;
// height of the nut
nut_height = 6.4;
// diameter of the threaded rod
threaded_rod_diameter = 8.5;
// allowance for the hole for the threaded rod
threaded_rod_hole_allowance = 0.6;
// diameter of the hole for the threaded rod
threaded_rod_hole_diameter = threaded_rod_diameter + threaded_rod_hole_allowance;

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

/* [Peristaltic Pump Side Mount Parameters] */

// width of the motor mount flange
peri_mount_flange_width = 5;
// height of the motor mount flange
peri_mount_flange_height = 2.4;
// distance between the screw holes on the motor mount flange
peri_mount_flange_screw_distance = 48.0;
// separation offset between the motor mount flange and the insert
peri_mount_flange_offset = 2;
// height of the motor mount insert
peri_mount_insert_height = 15;
// width of the motor mount insert
peri_mount_insert_width = 14.1;
// depth of the motor mount insert
peri_mount_insert_depth = 7.6;
// diameter of the screws that fix the motor mount to the motor
peri_screw_diameter = 4;
// diameter of the motor for the motor mount
peri_pump_motor_diameter = 30;

/* [Color Parameters] */

// first color for 3D prints
prints1_color = "DarkSlateGray";
// second color for 3D prints
prints2_color = "SlateBlue";

module dummy() {
  // stop the customizer detection from here onwards
}

// Driven Parameters
// total height of the assembly
total_height = temp_jar_height + base_floor_height + upper_base_height;
// distance from the center of the jar to the threaded rod
base_wall_thickness = (light_depth * 1.5) * 2; // thinnest part is 50% thicker than the light depth
// diameter of the cutout for the jar
base_jar_cut_diameter = temp_jar_diameter + base_jar_fit_allow;

// Driven Parameters
// distance from the center of the jar to the threaded rod
rod_shift = base_jar_cut_diameter / 2 + threaded_rod_hole_diameter;
// height of the rod spacer
rod_length = total_height + nut_height;
echo("rod length: ", rod_length / 10, " cm");

module frame(jar_height, jar_diameter) {

  // lights
  if (render_lights || render_all) {
    lights(light_allow=light_allow);
  }

  // put into a module so we can call it to remove from 3DP supporting components
  // light_allow is the allowance between base_jar_cut_diameter and the light front face to create a small gap
  // diff_allow is the allowance applied to the light dimensions to create a allowanced pocket
  module lights(light_allow = 0, diff_allow = 0, rad_cut = false) {
    // Add extra cut depth to prevent material between jar and light when creating pockets with lights
    radial_cut_ext = rad_cut ? light_depth * 0.1 : 0;

    placement_rad = base_jar_cut_diameter / 2 + light_allow - diff_allow / 2 - radial_cut_ext;

    // [width, depth, length, window_radius]
    dims = [
      light_width + diff_allow,
      light_depth + diff_allow + radial_cut_ext,
      light_length + diff_allow,
      light_window_radius,
    ];

    translate([0, 0, base_floor_height]) rotate([0, 0, 45]) {
        surround_lights(
          light_dims=dims, angle=occupy_angle, n=number_of_lights / 2, r=placement_rad,
          offset=0, center=true
        );

        if (!jar_x_sec)
          surround_lights(
            light_dims=dims, angle=occupy_angle, n=number_of_lights / 2, r=placement_rad,
            offset=180, center=true
          );
      }
  }

  // base
  if (render_base || render_all) {
    color(prints1_color) difference() {
        // create the base
        base(
          inner_diameter=base_jar_cut_diameter, height=lower_base_height, wall_thickness=base_wall_thickness,
          floor_height=base_floor_height, rod_hole_diameter=threaded_rod_hole_diameter, nut_dia=nut_diameter,
          nut_h=nut_height
        );

        // cut out the lights, rad_cut is true to extend the cut inwards to remove material between jar and light
        lights(light_allow=light_allow, diff_allow=light_allow, rad_cut=true);

        // cut out a second time shifted by 180 for symmetry and to allow more alternative config of the lights
        // this should be handled more elegantly in the future once the first iteration has been printed
        rotate([0, 0, 90]) lights(light_allow=light_allow, diff_allow=light_allow, rad_cut=true);
      }
  }

  // top base
  if (render_upper_base || render_all) {
    difference() {
      translate([0, 0, total_height]) rotate([0, 180, 0]) color(prints1_color) base(
              inner_diameter=base_jar_cut_diameter, height=upper_base_height, wall_thickness=base_wall_thickness,
              floor_height=base_floor_height, rod_hole_diameter=threaded_rod_hole_diameter
            );

      // cut out the lights
      lights(light_allow=light_allow, diff_allow=light_allow, rad_cut=false);

      // cut out a second time shifted by 180 for symmetry and to allow more alternative config of the lights
      // this should be handled more elegantly in the future once the first iteration has been printed
      rotate([0, 0, 90]) lights(light_allow=light_allow, diff_allow=light_allow, rad_cut=true);
    }
  }

  // ribs
  if (render_ribs || render_all) {
    // Number of rods holders on the ribs
    n_rods_ribs = 2;

    spacer_dia_allow = 0.2;
    spacer_z_allow = 0.4;
    z_shift_factor = 1 / 3;

    // create the ribs
    for (i = [1:2]) {

      spacers_total_height =
      total_height - base_floor_height * 2 - upper_base_height - lower_base_height - rib_base_height * 2;

      z_shift = spacers_total_height * i * z_shift_factor;

      spacer_pos = lower_base_height + nut_height + z_shift + rib_base_height * (i - 1);

      f_height = 0 - z_fight;

      for (j = [1:2]) {
        rotate([0, 0, j * 180]) rotate([0, 0, i * 90]) difference() {
              translate([0, 0, spacer_pos]) color(prints1_color)
                  base(
                    inner_diameter=base_jar_cut_diameter, height=rib_base_height,
                    wall_thickness=base_wall_thickness, floor_height=f_height,
                    rod_hole_diameter=threaded_rod_hole_diameter, rods=n_rods_ribs
                  );

              // cut out the lights, rad_cut is true to extend the cut inwards to remove material between jar and
              // light this is done for all ribs to allow flexibility, again this should be handled more elegantly in
              // the future
              rotate([0, 0, 90]) lights(light_allow=light_allow, diff_allow=light_allow, rad_cut=true);
            }

        // Place peri pump mount on the upper ribs in the middle light insert gap
        if (render_peri_side_mount || render_all) {
          if (i == 2) {
            for (i = [1:2:3])
              rotate([0, 0, -360 / 16 * i + j * 180])
                translate([0, jar_diameter / 2 + peri_mount_insert_depth / 2, spacer_pos + rib_base_height / 2])
                  //rotate([0, 0, 90])
                  color(prints2_color)

                    // peristaltic pump side mount
                    peri_pump_frame_mount(
                      flange_width=peri_mount_flange_width,
                      flange_height=peri_mount_flange_height,
                      flange_screw_distance=peri_mount_flange_screw_distance,
                      flange_insert_separation=peri_mount_flange_offset,
                      insert_height=peri_mount_insert_height,
                      insert_width=peri_mount_insert_width,
                      insert_depth=peri_mount_insert_depth,
                      motor_diameter=peri_pump_motor_diameter,
                      screw_diameter=peri_screw_diameter
                    );
          }
        }
      }
    }
  }

  // rod rib spacers
  if (render_rodspacers || render_all) {
    rod_spacer_diameter = threaded_rod_diameter + 2 * rod_spacer_thickness;
    z_shift_factor = 1 / 3;

    color(prints2_color)for (i = [0:2]) {
      for (j = [0:3]) {

        spacers_total_height =
        total_height - base_floor_height * 2 - upper_base_height - lower_base_height - rib_base_height * 2;

        z_shift = spacers_total_height * i * z_shift_factor;

        spacer_pos = lower_base_height + nut_height + z_shift + spacer_z_allow / 2 + rib_base_height * i;

        spacer_height = spacers_total_height * z_shift_factor - spacer_z_allow * 2;

        rotate([0, 0, j * 90]) translate([rod_shift, 0, spacer_pos]) difference() {
              cylinder(d=rod_spacer_diameter, h=spacer_height);
              cylinder(d=threaded_rod_diameter + spacer_dia_allow, h=spacer_height + z_fight);
            }
      }
    }
  }
}
