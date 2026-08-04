/**
 * @file bayonet_thermocouple_port.scad
 * @brief Thermocouple port with bayonet lock and NPT thread mount
 * @author Cameron K. Brooks
 * @copyright 2026
 */

use <bayonet_port.scad>
use <threads-scad/threads.scad>
include <bayonet_interfaces.scad>

$fn = $preview ? 32 : 128;

_bt_center_bore_radius = 3; // Radius of the center bore
_bt_panel_thickness = 18; // Lid thickness at the port, for standalone preview

// ----- Thermocouple-specific parameters -----
_bt_mount_height = 20; // Height of NPT thread mount

bayonet_thermocouple_port(
  type=bayonet_std,
  panel_thickness=_bt_panel_thickness,
  center_bore_radius=_bt_center_bore_radius,
  mount_height=_bt_mount_height
);

/**
 * Thermocouple port with bayonet connector and NPT thread mount.
 *
 * This is a pin half by definition - the lock half is the same for every port, so the
 * lid takes it straight from bayonet_port(). Shares bayonet_port's datum: the mount
 * stands on the flange, outside the vessel, and the thermocouple passes down the bore.
 *
 * @param type            Registered bayonet interface (see bayonet_interfaces.scad)
 * @param panel_thickness Thickness of the lid the port passes through
 * @param mount_height    Height of NPT thread mount
 */
module bayonet_thermocouple_port(
  type,
  panel_thickness,
  center_bore_radius,
  mount_height
) {
  // Bayonet connector
  bayonet_port(
    type=type,
    part="pin",
    panel_thickness=panel_thickness,
    center_bore_radius=center_bore_radius
  );

  // NPT thread mount the thermocouple screws into, standing on the flange's outer face
  translate([0, 0, bayonet_flange_height(type)])
    npt_thread_mount(
      height=mount_height,
      lower_diameter=bayonet_flange_radius(type) * 2 - bayonet_allowance(type)
    );
}

module npt_thread_mount(height, wall_thickness = 2, lower_diameter = undef) {
  half_npt_diameter = 21.34;
  allowance = 0.6;
  diameter = half_npt_diameter + wall_thickness * 2;
  lower_diameter_eff = is_undef(lower_diameter) ? diameter : lower_diameter;

  ScrewHole(
    outer_diam=half_npt_diameter - allowance, // Major diameter of 1/2" NPT
    height=height * 1.1, // Depth of threading
    position=[0, 0, 0], // Center of hole
    rotation=[0, 0, 0], // Orientation
    pitch=1.814, // Pitch based on 14 TPI
    tooth_angle=60, // NPT standard thread angle
    tolerance=0.4, // Small clearance for fitting
    tooth_height=1.0 // Adjust as needed for proper fit
  ) cylinder(d1=lower_diameter_eff, d2=diameter, h=height);
}
