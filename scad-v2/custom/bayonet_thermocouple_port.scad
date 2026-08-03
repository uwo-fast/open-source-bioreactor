/**
 * @file bayonet_thermocouple_port.scad
 * @brief Thermocouple port with bayonet lock and NPT thread mount
 * @author Cameron K. Brooks
 * @copyright 2026
 */

use <bayonet_port.scad>
use <threads-scad/threads.scad>

z_fight = $preview ? 0.01 : 0;
$fn = $preview ? 32 : 128;

// ----- Bayonet parameters -----
//              ["name" [iface_r, shell_t, pin_r], [part_h, neck_h, neck_r], [oring_cs, oring_intf], allow]
_bt_bayonet = ["std", [9.5,    2.5,     1.5],   [10,     5,      15],      [1.6,      0.1],       0.2];
_bt_center_bore_radius = 3; // Radius of the center bore

// ----- Thermocouple-specific parameters -----
_bt_mount_height = 20; // Height of NPT thread mount

bayonet_thermocouple_port(
  bayonet=_bt_bayonet,
  center_bore_radius=_bt_center_bore_radius,
  mount_height=_bt_mount_height
);

/**
 * Thermocouple port with bayonet connector and NPT thread mount.
 *
 * This is a pin half by definition - the lock half is the same for every port, so the
 * lid takes it straight from bayonet_port().
 *
 * @param bayonet      Bayonet interface vector (see bayonet_port.scad)
 * @param mount_height Height of NPT thread mount
 */
module bayonet_thermocouple_port(
  bayonet,
  center_bore_radius,
  mount_height
) {
  // Interface scalars this adapter needs for the mount taper.
  interface_radius = bayonet_interface_radius(bayonet);
  shell_thickness = bayonet_shell_thickness(bayonet);
  allowance = bayonet_allowance(bayonet);

  // Bayonet connector
  bayonet_port(
    bayonet=bayonet,
    part="pin",
    center_bore_radius=center_bore_radius
  );

  // NPT thread mount the thermocouple screws into
  rotate([0, 180, 0])
    npt_thread_mount(
      height=mount_height,
      lower_diameter=(interface_radius + shell_thickness - allowance) * 2
    );
}

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
