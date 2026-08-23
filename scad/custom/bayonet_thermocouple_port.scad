/**
 * @file bayonet_thermocouple_port.scad
 * @brief Thermocouple port with bayonet lock and NPT thread mount
 * @author Cameron K. Brooks
 * @copyright 2026
 */

use <bayonet_port.scad>
use <threads-scad/threads.scad>
include <bayonet_interfaces.scad>
include <../utils/npt_threads.scad>

$fn = $preview ? 32 : 128;

_bt_center_bore_radius = 3; // Radius of the center bore
_bt_panel_thickness = 18; // Lid thickness at the port, for standalone preview

// ----- Thermocouple-specific parameters -----
_bt_mount_height = 20; // Height of NPT thread mount
_bt_thread = npt_1_2; // which taper thread the mount cuts

bayonet_thermocouple_port(
  type=bayonet_std,
  panel_thickness=_bt_panel_thickness,
  center_bore_radius=_bt_center_bore_radius,
  mount_height=_bt_mount_height,
  thread=_bt_thread
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
 * @param thread          Registered NPT thread the mount cuts (see utils/npt_threads.scad)
 */
module bayonet_thermocouple_port(
  type,
  panel_thickness,
  center_bore_radius,
  mount_height,
  thread = npt_1_2
) {
  // Bayonet connector. text_labels stays off: the mount below lands on the flange's outer
  // face at very nearly the flange diameter, so anything engraved there would be buried.
  // This port's marks go on the mount wall instead.
  bayonet_port(
    type=type,
    part="pin",
    panel_thickness=panel_thickness,
    center_bore_radius=center_bore_radius
  );

  // NPT thread mount the thermocouple screws into, standing on the flange's outer face
  translate([0, 0, bayonet_flange_height(type)])
    npt_thread_mount(
      thread=thread,
      height=mount_height,
      lower_diameter=bayonet_flange_radius(type) * 2,
      marks=[
        npt_thread_name(thread), // what screws in
        str("Ø", center_bore_radius * 2), // bore the probe tip passes down
        str("B", bayonet_interface_radius(type) * 2, "-", bayonet_pin_radius(type)) // coupling
      ]
    );
}

/**
 * Text laid around a cylinder of the given radius, reading correctly from outside. Solid, so
 * difference() it out of the wall to engrave.
 */
module wrapped_text(s, radius, size, depth, angle = 0) {
  step = 2 * asin(size * 0.8 / (2 * radius)); // angular advance per character, ~0.8 em to avoid crowding

  for (i = [0:len(s) - 1])
    rotate([0, 0, angle - (len(s) - 1) * step / 2 + i * step])
      translate([radius - depth, 0, 0])
        rotate([90, 0, 90])
          linear_extrude(depth * 2) // overshoots the surface so the cut opens cleanly
            text(s[i], size=size, halign="center", valign="center", font="sans");
}

module npt_thread_mount(thread, height, wall_thickness = 2, lower_diameter = undef, marks = []) {
  major_diameter = npt_thread_major_diameter(thread);
  allowance = 0.6;
  diameter = major_diameter + wall_thickness * 2;
  lower_diameter_eff = is_undef(lower_diameter) ? diameter : lower_diameter;

  difference() {
    ScrewHole(
      outer_diam=major_diameter - allowance, // Major diameter at the hand-tight plane
      height=height * 1.1, // Depth of threading
      position=[0, 0, 0], // Center of hole
      rotation=[0, 0, 0], // Orientation
      pitch=npt_thread_pitch(thread), // from the row's TPI
      tooth_angle=60, // NPT standard thread angle
      tolerance=0.4, // Small clearance for fitting
      // Has to scale with the pitch, not sit at a constant: a tooth taller than the pitch is
      // self-intersecting, and on 1/8 NPT (0.94 mm pitch) a fixed 1.0 mm crashes CGAL outright.
      tooth_height=npt_thread_pitch(thread) * 0.55
    ) cylinder(d1=lower_diameter_eff, d2=diameter, h=height);

    // Marks spaced around the outer wall, set in its upper half where the taper has put the
    // most material between the surface and the thread.
    if (len(marks) > 0) {
      _mark_z = height * 0.65;
      _mark_r = (lower_diameter_eff + (diameter - lower_diameter_eff) * 0.65) / 2;

      for (i = [0:len(marks) - 1])
        translate([0, 0, _mark_z])
          wrapped_text(
            marks[i], radius=_mark_r, size=3.5, depth=0.8,
            angle=i * 360 / len(marks)
          );
    }
  }
}
