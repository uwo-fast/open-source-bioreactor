/**
 * @file head.scad
 * @brief Head subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

use <custom/lid.scad>;
use <custom/motor_mount.scad>;
use <custom/bayonet_port.scad>;
use <custom/impeller.scad>;

include <purchased/dc_motors.scad>;
include <purchased/gearboxes.scad>;

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// -----

// Overrides all other render flags
render_all = true; // render all components
render_lid = false;

render_motor = false;
render_motor_mount = false;
render_shaft_coupler = false;
render_ext_shaft = false;
render_impeller = false;

render_probes = false;
render_bayonet_lock = false;
render_tube_pinlock = false;
render_thermocouple_pinlock = false;

// -----

// these will constitute the mandatory input parameters for the head, which are cross-coupled
// to the vessel and frame, and therefore must be set from the top-level assembly

temp_lid_flange_height = 8;
temp_vessel_opening_diameter = 143;
temp_vessel_outer_diameter = 220;
temp_vessel_internal_height = 295;

vessel_outer_diameter = temp_vessel_outer_diameter;
vessel_opening_diameter = temp_vessel_opening_diameter;
lid_flange_height = temp_lid_flange_height;
vessel_internal_height = temp_vessel_internal_height;

// -----

/* [Lid Parameters] */

// the height of the lids plug (inner diameter part)
lid_plug_height = 10;
// allowance for the lid to fit on the jar
lid_radial_allowance = 0.4;
// height allowance for the lid to fit on the jar
lid_vertical_allowance = 0.2;
// number of holes for the first holes set
lid_holes_n = 12;
// allowance for the bearing and shaft holes
bearing_hole_allowance = 0.2;

/* [Bearing Parameters] */

// diameter of the bearing (outer casing)
bearing_diameter = 22.6;
// height of the bearing
bearing_height = 7.5;

/* [Motor & Gearbox Parameters] */

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

/* [Shaft Parameters] */

// The distance between the bottom of the jar (punt) and the bottom of the shaft
shaft_jar_punt_clearance = 5;
// length of the shaft for the impeller
shaft_length = 400;
// diameter of the shaft
shaft_diameter = 8.0;
// adjust distance between the motor and the shaft coupling
shaft_shaft_coupling_offset = 0; // can be positive or negative
// reference, length, diameter, input diameter, output diameter, flex?
shaft_coupler_8x8_rigid = ["SC_8x8_rigid", 25, 12.5, 8, 8, false];

/* [Motor Mount Parameters] */

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

/* [Impeller Parameters] */

/** Design guidelines for impeller:
 * - The impeller radius (radius) should be 1/3 to 1/2 of the tank radius for bioreactors
 * - The number of fins (fins) and their twist angle (twist) influence mixing efficiency, flow patterns, and shear
 *   forces.
 *   - More fins generally increase turbulence and mixing but may require higher power input.
 *   - Twist angle adjusts the direction and intensity of flow, with higher angles promoting axial flow and lower angles
 *     favoring radial flow. Choose values based on the viscosity of the fluid, required mixing intensity, and sensitivity
 *     of the culture to shear forces.
 */

// impeller diameter to tank diameter ratio
impeller_impeller_vessel_diameter_factor = 0.45;
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
impeller_shaft_allow = 0.4;
// the amount the radius decreases from top to bottom to create a draft for the shaft hole
impeller_shaft_radius_interference = 0.2;

/* [Thermocouple Mount Parameters] */

// height of the thermocouple mount
thermocouple_mount_height = 20;

/* [Bayonet Lock Parameters] */

// Interface radius of the bayonet
bayonet_interface_radius = 10;
// Radius of the locking pins
bayonet_pin_radius = 1.2;
// Height of the bayonet part
bayonet_part_height = 10;
// Height of the neck (0 for no neck)
bayonet_neck_height = 5;
// Radius of the neck (only relevant if neck_height > 0)
bayonet_neck_radius = 15;
// Radius of the center bore (0 for no bore)
bayonet_center_bore_radius = 3;
// Oring cross section, set to undef to disable o-ring groove
bayonet_oring_cs_diameter = 1.6;
// Allowance for the bayonet lock to fit properly (applied to lid cutouts)
bayonet_allowance = 0.2;

// bayonet_port(
//   part="pin",
//   interface_radius=bayonet_interface_radius,
//   pin_radius=bayonet_pin_radius,
//   part_height=bayonet_part_height,
//   neck_height=bayonet_neck_height,
//   neck_radius=bayonet_neck_radius,
//   center_bore_radius=bayonet_center_bore_radius,
//   oring_cs_diameter=bayonet_oring_cs_diameter,
//   text_labels=true
// );

/* [Color Parameters] */

// first color for 3D prints
prints1_color = "DarkSlateGray";
// second color for 3D prints
prints2_color = "SlateBlue";

module dummy() {
  // stop the customizer detection from here onwards
}

// Impeller Driven Parameters
// diameter of the impeller
impeller_diameter = vessel_outer_diameter * impeller_impeller_vessel_diameter_factor;
// radius of the impeller
impeller_radius = impeller_diameter / 2;
// radius of the shaft hole in the impeller
impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_allow) / 2;

// Motor and shaft driven parameters
shaft_protrusion = shaft_length - (vessel_internal_height - shaft_jar_punt_clearance);
// the height that the motor coupling assembly requires
motor_mount_height = gearbox_shaft_length + shaft_protrusion + shaft_shaft_coupling_offset;
echo("motor mount height: ", motor_mount_height / 10, " cm");

module lid_pocketed() {
  color(prints2_color) {
    union() {
      difference() {
        // create the lid
        lid(
          outer_diameter=vessel_outer_diameter,
          inner_diameter=vessel_opening_diameter,
          height_od=lid_flange_height,
          height_id=lid_plug_height,
          allowance=lid_radial_allowance
        );

        // cut out the bearing and shaft hole
        translate([0, 0, -z_fight / 2])
          union() {
            // shaft hole
            cylinder(d=shaft_diameter + bearing_hole_allowance, h=lid_flange_height + lid_plug_height + z_fight);

            // bearing pocket
            rotate([0, 0, 30])
              cylinder(d=bearing_diameter + bearing_hole_allowance, h=bearing_height + z_fight);
          }

        // cut out the entry holes for the probes and tubes
        for (hole_rot = [0:360 / lid_holes_n:360]) {
          rotate([0, 0, hole_rot])
            translate([vessel_outer_diameter / 4, 0, (lid_flange_height + lid_plug_height) / 2]) {
              cylinder(r=bayonet_interface_radius + bayonet_pin_radius * 1.5, h=lid_flange_height + lid_plug_height + z_fight, center=true);
            }
        }
      }
      // cut out the entry holes for the probes and tubes
      for (hole_rot = [0:360 / lid_holes_n:360]) {
        rotate([0, 0, hole_rot])
          translate([vessel_outer_diameter / 4, 0, bayonet_part_height + bayonet_oring_cs_diameter])
            rotate([180, 0, 0]) {
              // add the bayonet locks
              bayonet_port(
                part="lock",
                interface_radius=bayonet_interface_radius,
                pin_radius=bayonet_pin_radius,
                part_height=bayonet_part_height,
                neck_height=bayonet_neck_height,
                neck_radius=bayonet_neck_radius
              );
            }
      }
    }
  }
}

module head() {

  // Render the lid with pockets for the bearing and shaft, and holes for the bayonet locks
  if (render_lid || render_all) {
    lid_pocketed();
  }

  // motor and shaft
  if (render_motor || render_all) {

    // motor
    translate([0, 0, motor_mount_height + motor_length + gearbox_length])
      rotate([0, 180, 0])
        union() {
          dc_motor(generic_dc_motor);
          translate([0, 0, motor_length])
            gearbox(generic_gearbox);
        }
  }

  // motor mount
  if (render_motor_mount || render_all) {
    color(prints1_color)
      motor_mount(
        height=motor_mount_height,
        width=motor_mount_width,
        wall_thickness=motor_mount_thickness,
        floor_thickness=motor_mount_floor_thickness,
        inner_dia=motor_mount_inner_diameter,
        pillar_width=motor_mount_pillar_width,
        base_screws_diameter=motor_mount_base_screws_diameter,
        base_screws_cdist=motor_mount_base_screws_cdist,
        face_screws_diameter=motor_mount_face_screws_diameter,
        face_screws_cdist=motor_face_screws_separation,
        draft_scale=motor_mount_draft_scale,
        cross_bars=motor_mount_cross_bars
      );
  }

  // shaft coupling
  if (render_shaft_coupler || render_all) {

    translate(
      [0, 0, shaft_protrusion + shaft_shaft_coupling_offset / 2]
    )

      shaft_coupling(type=shaft_coupler_8x8_rigid, colour="MediumBlue");
  }

  // external shaft
  if (render_ext_shaft || render_all) {

    color("grey")
      translate([0, 0, jar_floor_height + shaft_jar_punt_clearance])
        cylinder(h=shaft_length, d=shaft_diameter, center=false);
  }

  // impeller
  if (render_impeller || render_all) {
    translate([0, 0, -shaft_length + shaft_protrusion + impeller_height / 2])
      color(prints2_color)
        union() {
          // main impeller body
          impeller(
            radius=impeller_radius,
            height=impeller_height,
            fins=impeller_n_fins,
            twist=impeller_twist_ang,
            fin_width=impeller_fin_width,
            center_hub_radius=impeller_hub_radius,
            center_hole_radius=impeller_shaft_hole_radius,
            center_hole_radius_lower=impeller_shaft_hole_radius - impeller_shaft_radius_interference
          );
          // top ring to connect the fin tops for mechanical stability
          translate([0, 0, impeller_height / 2 - impeller_fin_width / 2])
            linear_extrude(impeller_fin_width, center=true)
              difference() {
                circle(r=impeller_radius + impeller_fin_width, $fn=64);
                circle(r=impeller_radius, $fn=64);
              }
        }
  }
}

head();

// if (render_tube_pinlock || render_all)
//   tube_lock(
//     part_to_render="pin",
//     pin_direction=bayonet_lock_pin_direction,
//     number_of_pins=bayonet_lock_number_of_pins,
//     path_sweep_angle=bayonet_lock_path_sweep_angle,
//     turn_direction=bayonet_lock_turn_direction,
//     inner_radius=bayonet_lock_inner_radius,
//     outer_radius=bayonet_lock_outer_radius,
//     pin_radius=bayonet_lock_pin_radius,
//     allowance=bayonet_lock_allowance,
//     part_height=bayonet_lock_height,
//     neck_height=bayonet_lock_neck_height,
//     inner_radius_fill=bayonet_lock_inner_radius_fill,
//     oring_height=bayonet_lock_oring_height,
//     oring_neck_cut_height=bayonet_lock_oring_neck_cut_height
//   );

// if (render_thermocouple_pinlock || render_all)
//   thermocouple_lock(
//     part_to_render="pin",
//     pin_direction=bayonet_lock_pin_direction,
//     number_of_pins=bayonet_lock_number_of_pins,
//     path_sweep_angle=bayonet_lock_path_sweep_angle,
//     turn_direction=bayonet_lock_turn_direction,
//     inner_radius=bayonet_lock_inner_radius,
//     outer_radius=bayonet_lock_outer_radius,
//     pin_radius=bayonet_lock_pin_radius,
//     allowance=bayonet_lock_allowance,
//     part_height=bayonet_lock_height,
//     neck_height=bayonet_lock_neck_height,
//     inner_radius_fill=thermocouple_probe_tip_diameter / 2,
//     oring_height=bayonet_lock_oring_height,
//     oring_neck_cut_height=bayonet_lock_oring_neck_cut_height,
//     thermocouple_mount_height=thermocouple_mount_height
//   );

// READD PROBES USING NEW REGISTERED PARAMETERS
