use <bayonet_port.scad>
use <cylindrical_flex_tab.scad>

zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// ----- port params -----

// What style of lock to produce, with the pin pointed inward ou outward?
bayonet_lock_pin_direction = "outer"; // ["inner", "outer"]

// What to render
bayonet_lock_part_render = "pin"; // ["pin", "lock"]
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

// height of the added neck to create a flange
bayonet_lock_neck_height = 5;

bayonet_lock_inner_radius_fill = 3;

bayonet_lock_oring_height = 1.6;

bayonet_lock_oring_height_interference = 0.1;

bayonet_lock_oring_neck_cut_height = bayonet_lock_oring_height - bayonet_lock_oring_height_interference;

// ----- pinch params -----
// hardware params

probe_body_lenth = 35.6;

probe_body_diameter = 15.9; // 15.9 on soft backed probe, 16.3 on hard backed probe

tail_major_diameter = 8.7;

tail_minor_diameter = 4.3;

tail_length = 24.5;

connector_part_diameter = 10;

// design parameters

wall_thickness = 1.2;

internal_allowance = 0.6; // general allowance to compensate for printer/material tolerance

flex_tab_gap = 1.0; // gap separating flex_tab from shell body

flex_tab_offset = 0.5;

animate_flex_tab = false;

// Extra length
extra_length = 5;

// The tilt of the probe to avoid bubbles getting trapped on face of the sensor
tilt_degrees = 7;

bayonet_probe_port();

// ----- build -----
module bayonet_probe_port() {

  bayonet_diameter = bayonet_lock_outer_radius + bayonet_lock_inner_radius - 0.2;

  // animate from -wall_thickness (fully open) to zero (fully pinched)
  // use $t to control the animation frame (0 to 1)
  // use sine wave to create a smooth open-close-open animation loop
  // if animate_flex_tab is false, flex_tab_offset_anim will be zero and 
  // the flex_tab will be fully closed for rendering to 3D print
  flex_tab_offset_anim = animate_flex_tab ? -(sin($t * 360) + 1) / 2 * wall_thickness + flex_tab_offset : flex_tab_offset;

  union() {
    // Render the bayonet lock
    difference() {

      rotate([0, 180, 0])
        translate([0, 0, -bayonet_lock_height - bayonet_lock_neck_height])
          bayonet_port(
            part_to_render=bayonet_lock_part_render,
            pin_direction=bayonet_lock_pin_direction,
            number_of_pins=bayonet_lock_number_of_pins,
            path_sweep_angle=bayonet_lock_path_sweep_angle,
            turn_direction=bayonet_lock_turn_direction,
            inner_radius=bayonet_lock_inner_radius,
            outer_radius=bayonet_lock_outer_radius,
            pin_radius=bayonet_lock_pin_radius,
            allowance=bayonet_lock_allowance,
            part_height=bayonet_lock_height,
            neck_height=bayonet_lock_neck_height,
            inner_radius_fill=bayonet_lock_inner_radius_fill,
            oring_height=bayonet_lock_oring_height,
            oring_neck_cut_height=bayonet_lock_oring_neck_cut_height
          );

      // Cut the hexagonal hole for the connector
      cylinder(h=1000, d=connector_part_diameter + internal_allowance, center=true, $fn=6);
    }

    difference() {

      // Wedge to fill the missing slice created by the tilt
      rotate([-90, 0, 0]) {
        rotate_extrude(angle=tilt_degrees, convexity=10)
          difference() {
            circle(d=bayonet_diameter);
            translate([-bayonet_diameter / 2, 0, 0])
              square([bayonet_diameter, bayonet_diameter * 2], center=true);
          }
      }
      // Cut the hexagonal hole for the connector
      cylinder(h=1000, d=connector_part_diameter + internal_allowance, center=true, $fn=6);
    }

    rotate([0, tilt_degrees, 0]) {
      difference() {
        union() {

          // Draft between the two for a smooth transition
          translate([0, 0, -tail_length - extra_length])
            cylinder(h=tail_length + extra_length, d1=probe_body_diameter + wall_thickness * 2, d2=bayonet_diameter);

          // Render the pinch     
          translate([0, 0, -tail_length - extra_length])
            cylindrical_flex_tab(
              body_length=probe_body_lenth,
              body_diameter=probe_body_diameter,
              tail_diameter_start=tail_major_diameter,
              tail_diameter_end=tail_minor_diameter,
              tail_len=tail_length,
              end_diameter=connector_part_diameter,
              shell_wall=wall_thickness,
              allowance=internal_allowance,
              flex_tab_clearance=flex_tab_gap,
              flex_tab_offset=flex_tab_offset_anim
            );
        }

        // Cut the hexagonal hole for the connector
        cylinder(h=1000, d=connector_part_diameter + internal_allowance, center=true, $fn=6);
      }
    }
  }
}
