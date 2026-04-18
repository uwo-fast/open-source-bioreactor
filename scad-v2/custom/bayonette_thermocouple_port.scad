use <bayonet_port.scad>

zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 32 : 128;

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

bayonet_lock_thermocouple_mount_height = 20;

// Render the lock
bayonet_thermocouple_port(
  part_to_render=bayonet_lock_part_render, pin_direction=bayonet_lock_pin_direction,
  number_of_pins=bayonet_lock_number_of_pins, path_sweep_angle=bayonet_lock_path_sweep_angle,
  turn_direction=bayonet_lock_turn_direction, inner_radius=bayonet_lock_inner_radius,
  outer_radius=bayonet_lock_outer_radius, pin_radius=bayonet_lock_pin_radius,
  allowance=bayonet_lock_allowance, part_height=bayonet_lock_height,
  neck_height=bayonet_lock_neck_height, inner_radius_fill=bayonet_lock_inner_radius_fill,
  oring_height=bayonet_lock_oring_height, oring_neck_cut_height=bayonet_lock_oring_neck_cut_height,
  thermocouple_mount_height=bayonet_lock_thermocouple_mount_height
);

module bayonet_thermocouple_port(
  part_to_render,
  pin_direction,
  number_of_pins,
  path_sweep_angle,
  turn_direction,
  inner_radius,
  outer_radius,
  pin_radius,
  allowance,
  part_height,
  neck_height,
  oring_neck_cut_height,
  inner_radius_fill,
  oring_height,
  oring_neck_cut_height,
  thermocouple_mount_height
) {

  bayonet_port(
    part_to_render=part_to_render,
    pin_direction=pin_direction,
    number_of_pins=number_of_pins,
    path_sweep_angle=path_sweep_angle,
    turn_direction=turn_direction,
    inner_radius=inner_radius,
    outer_radius=outer_radius,
    pin_radius=pin_radius,
    allowance=allowance,
    part_height=part_height,
    neck_height=neck_height,
    inner_radius_fill=inner_radius_fill,
    oring_height=oring_height,
    oring_neck_cut_height=oring_neck_cut_height
  );

  if (part_to_render == "pin") {
    // Add NPT thread mount for the thermocouple
    rotate([0, 180, 0])
      npt_thread_mount(height=thermocouple_mount_height, lower_diameter=(outer_radius - allowance) * 2);
  }
}

use <threads-scad/threads.scad>; // import the threads library

module npt_thread_mount(height, wall_thickness = 2, lower_diameter = undef) {
  half_npt_diameter = 21.34;
  allowance = 0.6;
  diameter = half_npt_diameter + wall_thickness * 2;
  lower_diameter = (lower_diameter == undef) ? diameter : lower_diameter;

  ScrewHole(
    outer_diam=half_npt_diameter - allowance, // Major diameter of 1/2" NPT
    height=height * 1.1, // Depth of threading
    position=[0, 0, 0], // Center of hole
    rotation=[0, 0, 0], // Orientation
    pitch=1.814, // Pitch based on 14 TPI
    tooth_angle=60, // NPT standard thread angle
    tolerance=0.4, // Small clearance for fitting
    tooth_height=1.0 // Adjust as needed for proper fit
  ) cylinder(d1=lower_diameter, d2=diameter, h=height);
}
