/**
 * @file head.scad
 * @brief Head subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
*/

// Overrides all other render flags
render_all = false; // render all components
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
impeller_shaft_allow = 0.4;
// the amount the radius decreases from top to bottom to create a draft for the shaft hole
impeller_shaft_radius_interference = 0.2;

// Driven Parameters
// diameter of the impeller
impeller_diameter = jar_diameter * impeller_DT_factor;
// radius of the impeller
impeller_radius = impeller_diameter / 2;
// radius of the shaft hole in the impeller
impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_allow) / 2;

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
echo("motor mount height: ", motor_mount_height / 10, " cm");

/* [Thermocouple Mount Parameters] */
// height of the thermocouple mount
thermocouple_mount_height = 20;




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

echo("lid_holes_radius: ", lid_holes_radius);

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
