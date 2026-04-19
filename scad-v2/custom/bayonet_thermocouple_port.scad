/**
 * @file bayonet_thermocouple_port.scad
 * @brief Thermocouple port with bayonet lock and NPT thread mount
 * @author Cameron K. Brooks
 * @copyright 2026
 */

use <bayonet_port.scad>
use <threads-scad/threads.scad>

zFite = $preview ? 0.01 : 0;
$fn = $preview ? 32 : 128;

// ----- Bayonet parameters -----
_bt_part = "pin"; // Part type: "pin" or "lock"
_bt_inner_radius = 7; // Inner radius of the bayonet
_bt_shell_thickness = 2.5; // Thickness of the bayonet shell
_bt_part_height = 10; // Height of the bayonet part
_bt_neck_height = 5; // Height of the neck
_bt_pin_radius = 1.5; // Radius of the locking pins
_bt_center_bore_radius = 3; // Radius of the center bore
_bt_oring_height = 1.6; // Height of the o-ring
_bt_oring_interference = 0.1; // Compression of the o-ring

// ----- Thermocouple-specific parameters -----
_bt_mount_height = 20; // Height of NPT thread mount

bayonet_thermocouple_port();

/**
 * Thermocouple port with bayonet connector and NPT thread mount
 *
 * @param part                 "pin" or "lock"
 * @param mount_height         Height of NPT thread mount
 * @param oring_height         O-ring height (mm)
 * @param oring_interference   O-ring compression (mm)
 */
module bayonet_thermocouple_port(
  part = _bt_part,
  inner_radius = _bt_inner_radius,
  shell_thickness = _bt_shell_thickness,
  part_height = _bt_part_height,
  neck_height = _bt_neck_height,
  pin_radius = _bt_pin_radius,
  center_bore_radius = _bt_center_bore_radius,
  mount_height = _bt_mount_height,
  oring_height = _bt_oring_height,
  oring_interference = _bt_oring_interference
) {
  // Bayonet connector
  bayonet_port(
    part=part,
    inner_radius=inner_radius,
    shell_thickness=shell_thickness,
    part_height=part_height,
    neck_height=neck_height,
    pin_radius=pin_radius,
    center_bore_radius=center_bore_radius,
    oring_height=oring_height,
    oring_interference=oring_interference
  );

  // Add NPT thread mount for thermocouple (pin part only)
  if (part == "pin") {
    allowance = 0.2; // Default from bayonet_port

    rotate([0, 180, 0])
      npt_thread_mount(
        height=mount_height,
        lower_diameter=(inner_radius + 2 * shell_thickness - allowance) * 2
      );
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
