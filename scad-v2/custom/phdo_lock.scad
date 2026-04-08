use <generic_bayolock_port.scad>
use <phdo_pinch.scad>

zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview
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
probe_body_diameter = 16.3;

tail_major_diameter = 8.7;
tail_minor_diameter = 4.3;
tail_length = 24.5;

// design parameters

wall_thickness = 0.6 * 2; // 2 walls of 0.6mm each

height_ratio = 0.80; // the pinch height is 80% of the body length, centered on the body
width_ratio = 0.70; // the pinch width is 70% of the body outer diameter, centered on the body
pinch_gap = 1.0; // gap separating pinch tab from shell body

connector_part_diameter = 10;

// optional dev params

render_optional_supports = true;

// animate from -wall_thickness (fully open) to zero (fully pinched)
// use $t to control the animation frame (0 to 1)
// use sine wave to create a smooth open-close-open animation loop
// if animate_pinch is false, pinch_offset_anim will be zero and 
// the pinch will be fully closed for rendering to 3D print
animate_pinch = false;
pinch_offset_anim = animate_pinch ? -(sin($t * 360) + 1) / 2 * wall_thickness : 0;

// Extra length
extra_length = 5;

// ----- build -----

// Render the lock

difference() {
  union() {
    rotate([0, 180, 0])
      translate([0, 0, -bayonet_lock_height - bayonet_lock_neck_height])
        generic_lock(
          part_to_render=bayonet_lock_part_render, pin_direction=bayonet_lock_pin_direction,
          number_of_pins=bayonet_lock_number_of_pins, path_sweep_angle=bayonet_lock_path_sweep_angle,
          turn_direction=bayonet_lock_turn_direction, inner_radius=bayonet_lock_inner_radius,
          outer_radius=bayonet_lock_outer_radius, pin_radius=bayonet_lock_pin_radius,
          allowance=bayonet_lock_allowance, part_height=bayonet_lock_height,
          neck_height=bayonet_lock_neck_height, inner_radius_fill=bayonet_lock_inner_radius_fill,
          oring_height=bayonet_lock_oring_height, oring_neck_cut_height=bayonet_lock_oring_neck_cut_height
        );

    // Draft between the two for a smooth transition
    translate([0, 0, -tail_length - extra_length])
      cylinder(h=tail_length + extra_length, d1=probe_body_diameter + wall_thickness * 2, d2=bayonet_lock_outer_radius + bayonet_lock_inner_radius - 0.2);

    // Render the pinch     

    translate([0, 0, -tail_length - extra_length])
      phdo_pinch(
        body_length=probe_body_lenth,
        body_diameter=probe_body_diameter,
        tail_diameter_start=tail_major_diameter,
        tail_diameter_end=tail_minor_diameter,
        tail_len=tail_length,
        shell_wall=wall_thickness,
        height_pinch_ratio=height_ratio,
        width_pinch_ratio=width_ratio,
        pinch_clearance=pinch_gap,
        connector_diameter=connector_part_diameter,
        pinch_offset=pinch_offset_anim,
        render_supports=render_optional_supports
      );
  }

  // Cut the hexagonal hole for the connector
  cylinder(h=1000, d=connector_part_diameter, center=true, $fn=6);
}
