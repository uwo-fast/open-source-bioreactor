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

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// The bayonet interface every port mates to, bundled as one vector so it is defined once and
// passed by name. Consumers register their own (see bayonet_std in head.scad); accessors below.
//   ["name" [iface_r, shell_t, pin_r], [part_h, neck_h, neck_r], [oring_cs, oring_intf], allow]
function bayonet_interface_radius(b)   = b[1][0]; // mating surface radius
function bayonet_shell_thickness(b)    = b[1][1]; // annulus thickness either side of the interface
function bayonet_pin_radius(b)         = b[1][2]; // locking pin radius
function bayonet_part_height(b)        = b[2][0]; // height of the bayonet band
function bayonet_neck_height(b)        = b[2][1]; // height of the neck (0 for no neck)
function bayonet_neck_radius(b)        = b[2][2]; // neck flange radius
function bayonet_oring_cs_diameter(b)  = b[3][0]; // o-ring cross section (undef to disable groove)
function bayonet_oring_interference(b) = b[3][1]; // o-ring squeeze; groove depth is cs - this
function bayonet_allowance(b)          = b[4];    // fit clearance between mating halves

// Example usage (open this file directly to preview)
_bl_bayonet = ["std", [9.5, 2.5, 1.5], [10, 5, 15], [1.6, 0.1], 0.2];
bayonet_port(_bl_bayonet, part="pin", center_bore_radius=3, text_labels=true);

module bayonet_port(
  bayonet,
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
  interface_radius = bayonet_interface_radius(bayonet);
  shell_thickness = bayonet_shell_thickness(bayonet);
  pin_radius = bayonet_pin_radius(bayonet);
  part_height = bayonet_part_height(bayonet);
  neck_height = bayonet_neck_height(bayonet);
  neck_radius = bayonet_neck_radius(bayonet);
  allowance = bayonet_allowance(bayonet);
  oring_cs_diameter = bayonet_oring_cs_diameter(bayonet);
  oring_interference = bayonet_oring_interference(bayonet);

  // Validation
  assert(
    part == "pin" || part == "lock",
    str("bayonet_port: part must be 'pin' or 'lock', got: ", part)
  );
  assert(
    oring_cs_diameter == undef || oring_cs_diameter > 0,
    "bayonet_port: oring_cs_diameter must be > 0 when specified"
  );
  assert(
    oring_cs_diameter == undef || oring_interference < oring_cs_diameter,
    "bayonet_port: oring_interference must be < oring_cs_diameter (the groove would have no depth)"
  );

  // Auto-calculate entry_depth if not specified (50% of part_height)
  _entry_depth = is_undef(entry_depth) ? part_height * 0.5 : entry_depth;

  // Shell thickness of the bayonet annulus, measured either side of the interface radius.
  // Left undef, the library falls back to pin_radius * 2.
  _shell_thickness = is_undef(shell_thickness) ? pin_radius * 2 : shell_thickness;

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
          shell_thickness=_shell_thickness,
          allowance=allowance,
          part_height=part_height,
          entry_depth=_entry_depth,
          number_of_pins=number_of_pins,
          pin_radius=pin_radius,
          sweep_angle=sweep_angle,
          pin_direction=pin_direction,
          turn_direction=turn_direction
        );

      // Fill middle with center bore when set to pins
      if (part == "pin") {
        if (center_bore_radius > 0) {
          _tube(h=part_height + _neck_h, r_outer=interface_radius - pin_radius, r_inner=center_bore_radius);
        } else {
          cylinder(h=part_height + _neck_h, r=interface_radius - pin_radius);
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

// Hollow cylindrical tube primitive consisting of an outer shell minus thru-bore.
// The bore is triple-height and centered to avoid z-fighting on both faces.
module _tube(h, r_outer, r_inner) {
  difference() {

    cylinder(h=h, r=r_outer);

    if (r_inner > 0)
      cylinder(h=h * 3, r=r_inner, center=true);
  }
}
