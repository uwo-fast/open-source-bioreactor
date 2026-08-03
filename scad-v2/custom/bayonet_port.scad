/**
 * @file bayonet_port.scad
 * @brief Bayonet port connector with o-ring groove and mounting features
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Uses the bayonet-lock-scad library for the core locking mechanism.
 * Adds bioreactor-specific features: o-ring grooves, catch pockets, text labels.
 *
 */

use <bayonet-lock-scad/bayonet_lock.scad>
include <bayonet_interfaces.scad>

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// Accessors for the registered bayonet interface (see bayonet_interfaces.scad).
//   ["name" [iface_r, shell_t, pin_r, part_h, allow], [neck_h, neck_r], [oring_cs, oring_intf]]
function bayonet_interface_radius(type)   = type[1][0]; // mating surface radius
function bayonet_shell_thickness(type)    = type[1][1]; // annulus thickness either side of the interface
function bayonet_pin_radius(type)         = type[1][2]; // locking pin radius
function bayonet_part_height(type)        = type[1][3]; // height of the bayonet band
function bayonet_allowance(type)          = type[1][4]; // fit clearance between mating halves
function bayonet_neck_height(type)        = type[2][0]; // height of the neck (0 for no neck)
function bayonet_neck_radius(type)        = type[2][1]; // neck flange radius
function bayonet_oring_cs_diameter(type)  = type[3][0]; // o-ring cross section (undef to disable groove)
function bayonet_oring_interference(type) = type[3][1]; // o-ring squeeze; groove depth is cs - this

// Example usage (open this file directly to preview)
bayonet_port(bayonet_std, part="pin", center_bore_radius=3, text_labels=true);

module bayonet_port(
  type,
  part,
  center_bore_radius = 0,
  number_of_pins = 3,
  sweep_angle = 30,
  pin_direction = "outer",
  turn_direction = "CW",
  entry_depth = undef,
  catch_pockets = true,
  text_labels = false
) {

  // Unpack the shared bayonet interface into the scalars the body works in.
  interface_radius = bayonet_interface_radius(type);
  shell_thickness = bayonet_shell_thickness(type);
  pin_radius = bayonet_pin_radius(type);
  part_height = bayonet_part_height(type);
  neck_height = bayonet_neck_height(type);
  neck_radius = bayonet_neck_radius(type);
  allowance = bayonet_allowance(type);
  oring_cs_diameter = bayonet_oring_cs_diameter(type);
  oring_interference = bayonet_oring_interference(type);

  // `part`, `entry_depth` and `shell_thickness` are validated and defaulted by the library.
  assert(
    oring_cs_diameter == undef || oring_interference < oring_cs_diameter,
    "bayonet_port: oring_interference must be < oring_cs_diameter (the groove would have no depth)"
  );

  // O-ring groove is cut into the top face of the neck, so it only exists on the pin half.
  // Its depth is the cross section less the interference, which is what compresses the o-ring
  // against the mating face.
  _oring_enabled = !is_undef(oring_cs_diameter);
  _oring_cut_height = _oring_enabled ? oring_cs_diameter - oring_interference : 0;

  // Conditional parameters based on part type
  _neck_h = (part == "lock") ? 0 : neck_height;
  _neck_cut_h = (part == "lock" || !_oring_enabled) ? 0 : _oring_cut_height;

  difference() {
    union() {

      // Core bayonet geometry
      translate([0, 0, _neck_h])
        bayonet(
          half=part,
          interface_radius=interface_radius,
          shell_thickness=shell_thickness,
          allowance=allowance,
          part_height=part_height,
          entry_depth=entry_depth,
          number_of_pins=number_of_pins,
          pin_radius=pin_radius,
          sweep_angle=sweep_angle,
          pin_direction=pin_direction,
          turn_direction=turn_direction
        );

      // Fill the middle, bored through for a tube or probe when a bore is set.
      // The bore is triple-height and centered so it clears both faces without z-fighting.
      if (part == "pin") {
        difference() {
          cylinder(h=part_height + _neck_h, r=interface_radius - pin_radius);
          if (center_bore_radius > 0)
            cylinder(h=(part_height + _neck_h) * 3, r=center_bore_radius, center=true);
        }
      }

      // neck cylinder
      if (_neck_h > 0)
        cylinder(h=_neck_h, r=neck_radius);
    }

    // O-ring groove: an annular recess in the top face of the neck, running from just inboard
    // of the interface radius out to the neck edge. The o-ring seats here and is squeezed
    // against the face the port lands on.
    if (_neck_cut_h > 0) {
      translate([0, 0, _neck_h - _neck_cut_h])
        difference() {
          cylinder(h=_neck_cut_h + z_fight, r=neck_radius + z_fight);
          cylinder(h=_neck_cut_h + z_fight, r=interface_radius - allowance);
        }
    }

    // Catch pockets (holes for pliers to grip and rotate)
    if (catch_pockets && _neck_h > 0) {
      for (i = [0:1])
        rotate([0, 0, i * 180])
          translate([interface_radius * 0.8, 0, -z_fight / 2])
            cylinder(h=neck_height / 2, d=2 * interface_radius / 4);
    }

    // Text labels (radius and diameter markings)
    if (text_labels && _neck_h > 0) {

      // Radius and diameter of the center bore, marked on the neck face
      _radString = str("R", center_bore_radius);
      _diaString = str("D", center_bore_radius * 2);

      // Top (+Y) string impression
      translate([0, interface_radius * 0.8, neck_height / 2 - z_fight / 2]) {
        rotate([0, 180, 0])
          linear_extrude(neck_height / 2)
            text(
              _radString, size=interface_radius / 2,
              halign="center", valign="center", font="sans", $fn=32
            );
      }

      // Bottom (-Y) string impression
      translate([0, -interface_radius * 0.8, neck_height / 2 - z_fight / 2]) {
        rotate([0, 180, 0])
          linear_extrude(neck_height / 2)
            text(
              _diaString, size=interface_radius / 2,
              halign="center", valign="center", font="sans", $fn=32
            );
      }
    }
  }
}
