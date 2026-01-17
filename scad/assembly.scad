/**
 * @file assembly.scad
 * @brief Assembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains the assembly for the open-source-bioreactor project.
 *
 */

// project libs
use <base.scad>;
use <dc_motor.scad>;
use <impeller.scad>;
use <jar.scad>;
use <lid.scad>;
use <motor_mount.scad>;
use <probe_atlas.scad>;
use <probe_clamp.scad>;
use <probe_thermocouple.scad>;
use <strip_light.scad>;
use <tube_lock.scad>;
use <tube_mount.scad>;
use <thermocouple_lock.scad>;
use <peri_pump_side_mount.scad>;

// internal libs
use <lib/arc_points.scad>;

// external libs
include <NopSCADlib/core.scad>
use <NopSCADlib/vitamins/shaft_coupling.scad>
use <threads-scad/threads.scad>; // only if you want to visualize threads

// config for zFite, preview fn,
include <_config.scad>;

/* [Visulization Modifiers] */

// Cuts the jar in half for a cross section view
jar_x_sec = false;
// Visualize threads on the rods (slower to render)
show_threads = false;
// Animate the probe clamp opening and closing
animate_probe_clamp = false;
// Whether to shut the probe clamp
shut_probe_clamp = true;

/* [Render Control] */

// Overrides all other render flags
render_all = false; // render all components
render_jar = false;
render_base = false;
render_upper_base = false;
render_lid = false;
render_bayonet_lock = false;
render_ribs = false;
render_rods = false;
render_rodspacers = false;
render_lights = false;
render_probes = false;
render_motor = false;
render_motor_mount = false;
render_shaft_coupler = false;
render_ext_shaft = false;
render_impeller = false;
render_tube_pinlock = false;
render_thermocouple_pinlock = false;
render_peri_side_mount = true;

// ------------------------------------
// Commercial-off-the-shelf Constraints
// ------------------------------------

/* [Jar Parameters] */

// height of the jar
jar_height = 305;
// diameter of the jar
jar_diameter = 220;
// thickness of the jar
jar_thickness = 5;
// radius of the shoulder-to-body transition
jar_upper_corner_radius = 25;
// radius of the body-to-base transition
jar_lower_corner_radius = 12.5;
// height of the neck
jar_neck_height = 25;
// radius of the shoulder-to-neck transition
jar_neck_corner_radius = 13.5;
// height of the punt from the bottom of the jar
jar_punt_height = 5;
// width/diameter of the punt
jar_punt_width = 30;
// radius of the rim
jar_rim_rad = 2;
// number of fragments for the corners
jar_corner_Fn = 64;
// number of fragments for the extrusion
rot_Extrude_Fn = 64;

// Opening diameter of the jar, confirm correct and copy from ECHO: "jar opening_diameter: ", X
opening_diameter = 143;
// Real life the opening diameter is 143mm
// Note that for a given jar_diameter, currently the opening_diameter
// is a function of jar_upper_corner_radius and jar_neck_corner_radius
// these vars can be tweaked to get the desired opening_diameter

/* [Light Parameters] */

// length of the light
light_length = 336;
// width of the light
light_width = 14.1;
// depth of the light
light_depth = 7.6;
// radius of the light window
light_window_radius = 0.5;
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

/* [Motor & Shaft Parameters] */

// diameter of the motor
motor_diameter = 34;
// length of the motor
motor_length = 30;
// diameter of the gearbox
gearbox_diameter = 36;
// length of the gearbox
gearbox_length = 26;
// diameter of the shaft for the gearbox
gearbox_shaft_diameter = 8;
// length of the shaft for the gearbox
gearbox_shaft_length = 20;

// The distance between the bottom of the jar (punt) and the bottom of the shaft
shaft_jar_punt_clearance = 5;
// length of the shaft for the impeller
shaft_length = 400;
// diameter of the shaft
shaft_diameter = 8.0;
// adjust distance between the motor and the shaft coupling
shaft_shaft_coupling_offset = 0; // 

// reference, length, diameter, input diameter, output diameter, flex?
shaft_coupler_8x8_rigid = ["SC_8x8_rigid", 25, 12.5, 8, 8, false];

// width of the motor mount
motor_mount_width = 42;
// wall_thickness of the motor mount, must be at least 1.5x the dia of the screws
motor_mount_thickness = 10;
// thickness of the floor of the motor mount
motor_mount_floor_thickness = 4;
// inner diameter of the motor mount, set based on diameter of motor mounting boss
motor_mount_inner_diameter = 22;
// diameter of the screws that fix the motor mount down at by base
motor_mount_base_screws_diameter = 3.5;
// diameter of the screws that connect the motor faceplate to the mount
motor_mount_face_screws_diameter = 4;
// distance between the base screws
motor_mount_base_screws_cdist = 32;
// distance between the face screws
motor_face_screws_separation = 27.6;
// width of the pillars that support the motor mount
motor_mount_pillar_width = 7;
// draft scale for the motor mount
motor_mount_draft_scale = 1.5;
// number of cross bars for the motor mount
motor_mount_cross_bars = 1;

shaft_protrusion = shaft_length - (jar_height - (jar_punt_height + shaft_jar_punt_clearance));

// the height that the motor coupling assembly requires
motor_mount_height = gearbox_shaft_length + shaft_protrusion + shaft_shaft_coupling_offset;

/* [pH Probe Parameters] */

// Diameter of the neck
ph_probe_neck_diameter = 10;
// Height of the neck
ph_probe_neck_height = 26;
// Tapered diameter of the neck
ph_probe_neck_taper_diameter = 5;
// Diameter of the body
ph_probe_body_diameter = 15.6;
// Height of the body
ph_probe_body_height = 35;
// Diameter of the sensing tip
ph_probe_tip_diameter = 12;
// Height of the sensing tip
ph_probe_tip_height = 115;
// Diameter of the wire
ph_probe_wire_diameter = 3;
// Height of the wire
ph_probe_wire_height = 10;
// Colors of the probe
ph_probe_colors = ["Black", "Red", "Black", "Yellow"];
// Whether to orient the probe to the base
ph_probe_orient_base = true;

/* [pH Probe Clamp Parameters] */

// Controls the current angular position of the probe clamp
ph_probe_clamp_static_angle_factor = shut_probe_clamp ? 0 : 0.5; // [0:0.1:1]
// Difference between the nominal diameter and the expanded diameter
ph_probe_clamp_dia_diff = 1;
// Height of the probe clamp
ph_probe_clamp_height = 15;
// Thickness of the collar
ph_probe_clamp_collar_thickness = 2;
// Thickness of the mount
ph_probe_clamp_mount_thickness = 3;
// Width of the mount
ph_probe_clamp_mount_width = 6;
// Diameter of the hole
ph_probe_clamp_hole_diameter = 3.2;
// Diameter of the rod suspending the clamp
ph_probe_clamp_rod_diameter = 4.6;
// Height of the rod suspending the clamp
ph_probe_clamp_rod_height = 90;
// Height of the rod protruding from the lid
ph_probe_clamp_rod_height_lid = 10;

// Driven Parameters
// Diameter of the probe clamp, set to the body diameter of the probe
ph_probe_clamp_diameter = ph_probe_body_diameter;
// Expanded diameter of the probe clamp
ph_probe_clamp_diameter_expanded = ph_probe_clamp_diameter + ph_probe_clamp_dia_diff;
// Taper difference of the rod
ph_probe_clamp_rod_taper_diff = ph_probe_clamp_rod_diameter * 0.1;
// Diameter of the rod after taper
ph_probe_clamp_rod_diameter_taper = ph_probe_clamp_rod_diameter - ph_probe_clamp_rod_taper_diff;
// Width of the rod mount
ph_probe_clamp_rod_mount_width = ph_probe_clamp_rod_diameter * 2.5;

/* [DO Probe Parameters] */

// Diameter of the neck
do_probe_neck_diameter = 10;
// Height of the neck
do_probe_neck_height = 26;
// Tapered diameter of the neck
do_probe_neck_taper_diameter = 5;
// Diameter of the body
do_probe_body_diameter = 16;
// Height of the body
do_probe_body_height = 35;
// Diameter of the sensing tip
do_probe_tip_diameter = 12;
// Height of the sensing tip
do_probe_tip_height = 115;
// Diameter of the wire
do_probe_wire_diameter = 3;
// Height of the wire
do_probe_wire_height = 10;
// Colors of the probe
do_probe_colors = ["Black", "Goldenrod", "Black", "Yellow"];

/* [DO Probe Clamp Parameters] */

// Controls the current angular position of the probe clamp
do_probe_clamp_static_angle_factor = shut_probe_clamp ? 0 : 0.5; // [0:0.1:1]
// Difference between the nominal diameter and the expanded diameter
do_probe_clamp_dia_diff = 1;
// Height of the probe clamp
do_probe_clamp_height = 15;
// Thickness of the collar
do_probe_clamp_collar_thickness = 2;
// Thickness of the mount
do_probe_clamp_mount_thickness = 3;
// Width of the mount
do_probe_clamp_mount_width = 6;
// Diameter of the hole
do_probe_clamp_hole_diameter = 3.2;
// Diameter of the rod penetrating the clamp
do_probe_clamp_rod_diameter = 4.6;
// Height of the rod penetrating the clamp
do_probe_clamp_rod_height = 90;
// Height of the rod protruding from the lid
do_probe_clamp_rod_height_lid = 10;

// Driven Parameters
// Diameter of the probe clamp, set to the body diameter of the probe
do_probe_clamp_diameter = do_probe_body_diameter;
// Expanded diameter of the probe clamp
do_probe_clamp_diameter_expanded = do_probe_clamp_diameter + do_probe_clamp_dia_diff;
// Taper difference of the rod
do_probe_clamp_rod_taper_diff = do_probe_clamp_rod_diameter * 0.1;
// Diameter of the rod after taper
do_probe_clamp_rod_diameter_taper = do_probe_clamp_rod_diameter - do_probe_clamp_rod_taper_diff;
// Width of the rod mount
do_probe_clamp_rod_mount_width = do_probe_clamp_rod_diameter * 2.5;

/* [Temperature Probe Parameters] */

// Whether to orient the probe to the base
do_probe_orient_base = true;
// Diameter of the neck
thermocouple_probe_neck_diameter = 10;
// Height of the neck
thermocouple_probe_neck_height = 12;
// Diameter of the flats
thermocouple_probe_flats_diameter = 26;
// Height of the flats
thermocouple_probe_flats_height = 5;
// Diameter of the body
thermocouple_probe_body_diameter = 21;
// Height of the body
thermocouple_probe_body_height = 20;
// Diameter of the sensing tip
thermocouple_probe_tip_diameter = 3.5;
// Height of the sensing tip
thermocouple_probe_tip_height = 115;
// Diameter of the wire
thermocouple_probe_wire_diameter = 3;
// Height of the wire
thermocouple_probe_wire_height = 10;
// Whether to orient the probe to the base
thermocouple_probe_orient_base = true;

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

// Driven Parameters
// total height of the assembly
total_height = jar_height + base_floor_height + upper_base_height;
// distance from the center of the jar to the threaded rod
base_wall_thickness = (light_depth * 1.5) * 2; // thinnest part is 50% thicker than the light depth
// diameter of the cutout for the jar
base_jar_cut_diameter = jar_diameter + base_jar_fit_allow;

/* [Lid Parameters] */

// allowance for the lid to fit on the jar
lid_rad_allow = 0.4;
// height allowance for the lid to fit on the jar
lid_h_allow = 0.2;
// height of the lid
bearing_diameter = 22.6;
// height of the bearing
bearing_height = 7.5;

// Driven Parameters
// height of the lid
lid_height = upper_base_height - base_floor_height - lid_h_allow;
// diameter of the cuts on the lid
lid_cuts = jar_diameter / 5;
// height of the cuts on the lid
lid_z_pos = jar_height + base_floor_height + lid_height;

/* [Rod Spacer Parameters] */

// thickness of the rod spacer
rod_spacer_thickness = 2;
// allowance for the rod spacer to fit on the rod
spacer_dia_allow = 0.2;
// allowance for the rod spacer to fit on the rod
spacer_z_allow = 0.4;

// Driven Parameters
// distance from the center of the jar to the threaded rod
rod_shift = base_jar_cut_diameter / 2 + threaded_rod_hole_diameter;
// height of the rod spacer
rod_length = total_height + nut_height;
echo("rod length: ", rod_length / 10, " cm");

/* [Impeller Parameters] */

/** Design guidelines for impeller:
 * - The impeller radius (radius) should be 1/3 to 1/2 of the tank radius for bioreactors
 * - The number of fins (fins) and their twist angle (twist) influence mixing efficiency, flow patterns, and shear
 * forces.
 *   More fins generally increase turbulence and mixing but may require higher power input.
 *   Twist angle adjusts the direction and intensity of flow, with higher angles promoting axial flow and lower angles
 *   favoring radial flow. Choose values based on the viscosity of the fluid, required mixing intensity, and sensitivity
 *   of the culture to shear forces.
 */

// impeller diameter to tank diameter ratio
impeller_DT_factor = 0.45;
// impeller height
impeller_height = 60;
// number of fins
impeller_n_fins = 4;
// twist angle of each fin
impeller_twist_ang = 55;
// width of each fin blade
impeller_fin_width = 4;
// size of the center hub
impeller_hub_radius = 7.5;
// allowance for the shaft hole
impeller_shaft_allow = 0.1;
// the amount the radius decreases from top to bottom to create a draft for the shaft hole
impeller_shaft_radius_interference = 0.2;

// Driven Parameters
// diameter of the impeller
impeller_diameter = jar_diameter * impeller_DT_factor;
// radius of the impeller
impeller_radius = impeller_diameter / 2;
// radius of the shaft hole in the impeller
impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_allow) / 2;

/* [Thermocouple Mount Parameters] */
// height of the thermocouple mount
thermocouple_mount_height = 20;

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

/* [Color Parameters] */
// first color for 3D prints
prints1_color = "DarkSlateGray";
// second color for 3D prints
prints2_color = "SlateBlue";

module dummy() {
  // stop the customizer detection from here onwards
}

/* [Derived Parameters] */

jar_floor_height = jar_punt_height + jar_thickness + base_floor_height;

/*********************************************/
/*              START ASSEMBLY               */
/*********************************************/

// jar
if (render_jar || render_all) {
  rotate([0, 0, 45]) translate([0, 0, base_floor_height])
      jar(
        height=jar_height, diameter=jar_diameter, thickness=jar_thickness,
        corner_radius=jar_upper_corner_radius, corner_radius_base=jar_lower_corner_radius,
        neck=jar_neck_height, neck_corner_radius=jar_neck_corner_radius, punt_height=jar_punt_height,
        punt_width=jar_punt_width, rim_rad=jar_rim_rad, arcFn=jar_corner_Fn, rotExtFn=rot_Extrude_Fn,
        show_pts=false, show_2d=false, show_3d=true, pts_r=1, angle=(jar_x_sec ? 180 : 360)
      );
}

// threaded rods
if (render_rods || render_all) {
  threads_allow = 0.15;
  for (i = [0:3]) {
    rotate([0, 0, i * 90]) {
      translate([rod_shift, 0, -zFite]) {
        if (show_threads) {
          color("Grey") ScrewThread(outer_diam=threaded_rod_diameter, height=rod_length);
        } else {
          color("Grey") cylinder(d=threaded_rod_diameter, h=rod_length);
        }

        // Nuts bottom base
        translate([0, 0, -zFite]) color("DimGray") difference() {
              rotate([0, 0, 30]) translate([0, 0, 0])
                  cylinder(d=nut_diameter - threads_allow, h=nut_height, $fn=6);
              rotate([0, 0, 30]) translate([0, 0, -zFite / 2])
                  cylinder(d=threaded_rod_diameter + threads_allow, h=nut_height + zFite);
            }

        // Nuts top of base
        translate([0, 0, lower_base_height + zFite * 2]) color("DimGray") difference() {
              rotate([0, 0, 30]) translate([0, 0, 0])
                  cylinder(d=nut_diameter - threads_allow, h=nut_height, $fn=6);
              rotate([0, 0, 30]) translate([0, 0, -zFite / 2])
                  cylinder(d=threaded_rod_diameter + threads_allow, h=nut_height + zFite);
            }

        // Nuts on the lid
        translate([0, 0, lid_z_pos + base_floor_height]) color("DimGray") difference() {
              rotate([0, 0, 30]) translate([0, 0, 0])
                  cylinder(d=nut_diameter - threads_allow, h=nut_height, $fn=6);
              rotate([0, 0, 30]) translate([0, 0, -zFite / 2])
                  cylinder(d=threaded_rod_diameter + threads_allow, h=nut_height + zFite);
            }
      }
    }
  }
}

// motor and shaft
if (render_motor || render_all) {

  // motor
  translate([0, 0, lid_z_pos + motor_mount_height + motor_length + gearbox_length]) rotate([0, 180, 0]) union() {
        dcmotor(diameter=motor_diameter, length=motor_length);
        translate([0, 0, motor_length]) gearbox(
            diameter=gearbox_diameter, length=gearbox_length, output_shaft_diameter=gearbox_shaft_diameter,
            output_shaft_length=gearbox_shaft_length, faceplate_screws_cdist=motor_face_screws_separation
          );
      }
}

// motor mount
if (render_motor_mount || render_all) {
  color(prints1_color) translate([0, 0, lid_z_pos]) motor_mount(
        height=motor_mount_height, width=motor_mount_width, wall_thickness=motor_mount_thickness,
        floor_thickness=motor_mount_floor_thickness, inner_dia=motor_mount_inner_diameter, pillar_width=motor_mount_pillar_width,
        base_screws_diameter=motor_mount_base_screws_diameter, base_screws_cdist=motor_mount_base_screws_cdist,
        face_screws_diameter=motor_mount_face_screws_diameter, face_screws_cdist=motor_face_screws_separation,
        draft_scale=motor_mount_draft_scale, cross_bars=motor_mount_cross_bars
      );
}

// shaft coupling
if (render_shaft_coupler || render_all) {

  translate(
    [0, 0, lid_z_pos + shaft_protrusion + shaft_shaft_coupling_offset / 2]
  )

    shaft_coupling(type=shaft_coupler_8x8_rigid, colour="MediumBlue");
}

// external shaft
if (render_ext_shaft || render_all) {

  color("grey")
    translate(
      [0, 0, jar_floor_height + shaft_jar_punt_clearance]
    )
      cylinder(h=shaft_length, d=shaft_diameter, center=false);
}

// impeller
if (render_impeller || render_all) {
  translate([0, 0, lid_z_pos - shaft_length + shaft_protrusion + impeller_height / 2]) color(prints2_color) union() {
        impeller(
          radius=impeller_radius, height=impeller_height, fins=impeller_n_fins, twist=impeller_twist_ang,
          fin_width=impeller_fin_width, center_hub_radius=impeller_hub_radius,
          center_hole_radius=impeller_shaft_hole_radius, center_hole_radius_lower=impeller_shaft_hole_radius - impeller_shaft_radius_interference
        );
        translate([0, 0, impeller_height / 2 - impeller_fin_width / 2])
          linear_extrude(impeller_fin_width, center=true) difference() {
              circle(r=impeller_radius + impeller_fin_width, $fn=64);
              circle(r=impeller_radius, $fn=64);
            }
      }
}

if (render_probes || render_all) {

  // ph probe

  translate([jar_diameter / 4, 0, lid_z_pos - ph_probe_clamp_rod_height + ph_probe_clamp_rod_height_lid])
    rotate([0, 0, 0]) {
      // suspension rod
      color("DimGray") cylinder(d=ph_probe_clamp_rod_diameter, h=ph_probe_clamp_rod_height);

      ph_probe_x_shift = ph_probe_clamp_rod_mount_width + ph_probe_clamp_rod_diameter / 2;
      ph_probe_z_shift = ph_probe_body_height / 2 - ph_probe_clamp_height / 2;

      // pinch collar for ph probe
      translate([ph_probe_x_shift, 0, 0]) color(prints1_color) probe_pinch_collar(
            nominal_diameter=ph_probe_clamp_diameter, expanded_diameter=ph_probe_clamp_diameter_expanded,
            height=ph_probe_clamp_height, collar_thickness=ph_probe_clamp_collar_thickness,
            mount_thickness=ph_probe_clamp_mount_thickness, mount_width=ph_probe_clamp_mount_width,
            hole_diameter=ph_probe_clamp_hole_diameter, rod_diameter=ph_probe_clamp_rod_diameter,
            rod_diameter_taper=ph_probe_clamp_rod_diameter_taper, rod_mount_width=ph_probe_clamp_rod_mount_width,
            animate=animate_probe_clamp, static_angle_factor=ph_probe_clamp_static_angle_factor
          );

      // atlas probe for ph probe
      translate([ph_probe_x_shift, 0, -ph_probe_z_shift]) atlas_probe(
          neck_d=ph_probe_neck_diameter, neck_h=ph_probe_neck_height, neck_taper_d=ph_probe_neck_taper_diameter,
          body_d=ph_probe_body_diameter, body_h=ph_probe_body_height, tip_d=ph_probe_tip_diameter,
          tip_h=ph_probe_tip_height, wire_d=ph_probe_wire_diameter, wire_h=ph_probe_wire_height,
          colors=ph_probe_colors, position_base=ph_probe_orient_base
        );
    }

  // do probe
  translate([-jar_diameter / 4, 0, lid_z_pos - do_probe_clamp_rod_height + do_probe_clamp_rod_height_lid])
    rotate([0, 0, 180]) {
      // suspension rod
      color("DimGray") cylinder(d=do_probe_clamp_rod_diameter, h=do_probe_clamp_rod_height);

      do_probe_x_shift = do_probe_clamp_rod_mount_width + do_probe_clamp_rod_diameter / 2;
      do_probe_z_shift = do_probe_body_height / 2 - do_probe_clamp_height / 2;

      // pinch collar for do probe
      translate([do_probe_x_shift, 0, 0]) color(prints1_color) probe_pinch_collar(
            nominal_diameter=do_probe_clamp_diameter, expanded_diameter=do_probe_clamp_diameter_expanded,
            height=do_probe_clamp_height, collar_thickness=do_probe_clamp_collar_thickness,
            mount_thickness=do_probe_clamp_mount_thickness, mount_width=do_probe_clamp_mount_width,
            hole_diameter=do_probe_clamp_hole_diameter, rod_diameter=do_probe_clamp_rod_diameter,
            rod_diameter_taper=do_probe_clamp_rod_diameter_taper, rod_mount_width=do_probe_clamp_rod_mount_width,
            animate=animate_probe_clamp, static_angle_factor=do_probe_clamp_static_angle_factor
          );

      // atlas probe for do probe
      translate([do_probe_x_shift, 0, -do_probe_z_shift]) atlas_probe(
          neck_d=do_probe_neck_diameter, neck_h=do_probe_neck_height, neck_taper_d=do_probe_neck_taper_diameter,
          body_d=do_probe_body_diameter, body_h=do_probe_body_height, tip_d=do_probe_tip_diameter,
          tip_h=do_probe_tip_height, wire_d=do_probe_wire_diameter, wire_h=do_probe_wire_height,
          colors=do_probe_colors, position_base=do_probe_orient_base
        );
    }

  // thermocouple probe
  translate([0, -jar_diameter / 4, lid_z_pos])
    threaded_thermocouple(
      neck_d=thermocouple_probe_neck_diameter, neck_h=thermocouple_probe_neck_height,
      flats_d=thermocouple_probe_flats_diameter, flats_h=thermocouple_probe_flats_height,
      body_d=thermocouple_probe_body_diameter, body_h=thermocouple_probe_body_height,
      tip_d=thermocouple_probe_tip_diameter, tip_h=thermocouple_probe_tip_height,
      wire_d=thermocouple_probe_wire_diameter, wire_h=thermocouple_probe_wire_height,
      show_threads=show_threads, position_base=thermocouple_probe_orient_base
    );
}
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

    f_height = 0 - zFite;

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
                  peri_pump_side_mount(
                    flange_width=peri_mount_flange_width,
                    flange_height=peri_mount_flange_height,
                    flange_screw_distance=peri_mount_flange_screw_distance,
                    flange_insert_separation=peri_mount_flange_offset,
                    insert_height=peri_mount_insert_height,
                    insert_width=peri_mount_insert_width,
                    insert_depth=peri_mount_insert_depth,
                    motor_diameter=motor_diameter,
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
            cylinder(d=threaded_rod_diameter + spacer_dia_allow, h=spacer_height + zFite);
          }
    }
  }
}

// What style of lock to produce, with the pin pointed inward ou outward?
bayonet_lock_pin_direction = "outer"; // ["inner", "outer"]

// Render the mechanism with 2 to 6 locks / pins
bayonet_lock_number_of_pins = 3;

// The angle of the path that the pin will follow
bayonet_lock_path_sweep_angle = 30;

// Direction of the lock
bayonet_lock_turn_direction = "CW"; // ["CW", "CCW"]

// inner radius of the lock
bayonet_lock_inner_radius = 7;
// outer radius of the lock
bayonet_lock_outer_radius = 12;

// the allowance or "gap" between the pin and the lock
bayonet_lock_allowance = 0.2;

// manual pin radius, if not set, it will be calculated based on the inner and outer radius
bayonet_lock_manual_pin_radius = 1.5;

// radius of the locking pin
bayonet_lock_pin_radius =
  (bayonet_lock_manual_pin_radius == 0) ? (bayonet_lock_outer_radius - bayonet_lock_inner_radius) / 4
  : bayonet_lock_manual_pin_radius;

// Height of the connector part
bayonet_lock_height = 10;

// fragment count for arcs, 48 works best with FreeCAD
_fn = 32;

// height of the added neck to create a flange
bayonet_lock_neck_height = 5;

bayonet_lock_inner_radius_fill = 0;

bayonet_lock_oring_height = 1.6;
bayonet_lock_oring_height_interference = 0.1;

bayonet_lock_oring_neck_cut_height = bayonet_lock_oring_height - bayonet_lock_oring_height_interference;

// number of holes for the first holes set
lid_holes_n = 12;
// diameter of the holes for the first holes set
lid_holes_radius = bayonet_lock_outer_radius + 0.01;

// lid
if (render_lid || render_all) {
  cut_height = lid_height * 2 * 1.1;

  color(prints2_color) translate([0, 0, lid_z_pos]) rotate([0, 180, 0]) {
        union() {
          difference() {
            // create the lid
            lid(
              outer_diameter=jar_diameter, inner_diameter=opening_diameter, height=lid_height,
              allowance=lid_rad_allow, rod_hole_diameter=threaded_rod_diameter, nut_dia=nut_diameter,
              nut_h=nut_height
            );

            // cut out the bearing and shaft hole
            translate([0, 0, -zFite / 2]) union() {
                cylinder(d=threaded_rod_diameter, h=lid_height * 2 + zFite);
                rotate([0, 0, 30]) cylinder(d=bearing_diameter, h=bearing_height + zFite);
              }

            // cut off corners to reduce material and allow space for lights
            translate([0, 0, lid_height]) rotate([0, 0, 45]) difference() {
                  cube([jar_diameter * 1.1, jar_diameter * 1.1, cut_height], center=true);
                  cube([jar_diameter - lid_cuts, jar_diameter - lid_cuts, cut_height * 1.1], center=true);
                }

            // cut out the entry holes for the probes and tubes
            for (hole_rot = [0:360 / lid_holes_n:360]) {
              rotate([0, 0, hole_rot]) translate([jar_diameter / 4, 0, lid_height]) {
                  cylinder(r=lid_holes_radius, h=cut_height, center=true);
                }
            }
          }

          // cut out the entry holes for the probes and tubes
          for (hole_rot = [0:360 / lid_holes_n:360]) {
            rotate([0, 0, hole_rot]) translate([jar_diameter / 4, 0, lid_height + bayonet_lock_height * 0.5])
                rotate([180, 0, 0]) {
                  // add the bayonet locks
                  if (render_bayonet_lock || render_all)
                    tube_lock(
                      part_to_render="lock", pin_direction=bayonet_lock_pin_direction,
                      number_of_pins=bayonet_lock_number_of_pins, path_sweep_angle=bayonet_lock_path_sweep_angle,
                      turn_direction=bayonet_lock_turn_direction, inner_radius=bayonet_lock_inner_radius,
                      outer_radius=bayonet_lock_outer_radius, pin_radius=bayonet_lock_pin_radius,
                      allowance=bayonet_lock_allowance, part_height=bayonet_lock_height,
                      neck_height=bayonet_lock_neck_height, inner_radius_fill=bayonet_lock_inner_radius_fill,
                      oring_height=bayonet_lock_oring_height,
                      oring_neck_cut_height=bayonet_lock_oring_neck_cut_height
                    );
                }
          }
        }
      }
}

if (render_tube_pinlock || render_all)
  tube_lock(
    part_to_render="pin", pin_direction=bayonet_lock_pin_direction,
    number_of_pins=bayonet_lock_number_of_pins, path_sweep_angle=bayonet_lock_path_sweep_angle,
    turn_direction=bayonet_lock_turn_direction, inner_radius=bayonet_lock_inner_radius,
    outer_radius=bayonet_lock_outer_radius, pin_radius=bayonet_lock_pin_radius,
    allowance=bayonet_lock_allowance, part_height=bayonet_lock_height,
    neck_height=bayonet_lock_neck_height, inner_radius_fill=bayonet_lock_inner_radius_fill,
    oring_height=bayonet_lock_oring_height, oring_neck_cut_height=bayonet_lock_oring_neck_cut_height
  );

if (render_thermocouple_pinlock || render_all)
  thermocouple_lock(
    part_to_render="pin", pin_direction=bayonet_lock_pin_direction,
    number_of_pins=bayonet_lock_number_of_pins, path_sweep_angle=bayonet_lock_path_sweep_angle,
    turn_direction=bayonet_lock_turn_direction, inner_radius=bayonet_lock_inner_radius,
    outer_radius=bayonet_lock_outer_radius, pin_radius=bayonet_lock_pin_radius,
    allowance=bayonet_lock_allowance, part_height=bayonet_lock_height,
    neck_height=bayonet_lock_neck_height, inner_radius_fill=thermocouple_probe_tip_diameter / 2,
    oring_height=bayonet_lock_oring_height,
    oring_neck_cut_height=bayonet_lock_oring_neck_cut_height,
    thermocouple_mount_height=thermocouple_mount_height
  );
