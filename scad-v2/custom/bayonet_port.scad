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

zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

_ex_part = "pin"; // Part type: "pin" or "lock"
_ex_inner_radius = 7; // Inner radius of the bayonet
_ex_shell_thickness = 2.5; // Thickness of the bayonet shell
_ex_part_height = 10; // Height of the bayonet part
_ex_neck_height = 5; // Height of the neck (0 for no neck)
_ex_pin_radius = 1.5; // Radius of the locking pins
_ex_center_bore_radius = 3; // Radius of the center bore (0 for no bore)
_ex_oring_height = 1.6; // Height of the o-ring (0 to disable)
_ex_oring_interference = 0.1; // Compression of the o-ring (0

// Example usage 
bayonet_port(
  part=_ex_part,
  inner_radius=_ex_inner_radius,
  shell_thickness=_ex_shell_thickness,
  part_height=_ex_part_height,
  neck_height=_ex_neck_height,
  pin_radius=_ex_pin_radius,
  center_bore_radius=_ex_center_bore_radius,
  oring_height=_ex_oring_height,
  oring_interference=_ex_oring_interference,
  text_labels=true
);

module bayonet_port(
  part,
  inner_radius,
  shell_thickness,
  part_height,
  neck_height,
  pin_radius,
  center_bore_radius,
  allowance = 0.2,
  number_of_pins = 3,
  sweep_angle = 30,
  pin_direction = "outer",
  turn_direction = "CW",
  entry_depth = undef,
  oring_height = undef,
  oring_interference = undef,
  catch_pockets = true,
  text_labels = false,
  text_radius_override = undef,
  text_diameter_override = undef
) {

  // Validation
  assert(
    part == "pin" || part == "lock",
    str("bayonet_port: part must be 'pin' or 'lock', got: ", part)
  );
  assert(
    (is_undef(oring_height) && is_undef(oring_interference)) || (!is_undef(oring_height) && !is_undef(oring_interference)),
    "bayonet_port: oring_height and oring_interference must both be specified or both be undefined"
  );
  assert(
    !text_labels || is_undef(text_radius_override) || is_undef(text_diameter_override) || text_labels,
    "bayonet_port: text_radius_override and text_diameter_override require text_labels=true"
  );

  // Auto-calculate entry_depth if not specified (50% of part_height)
  _entry_depth = is_undef(entry_depth) ? part_height * 0.5 : entry_depth;

  // O-ring enabled if both parameters are defined
  _oring_enabled = !is_undef(oring_height) && !is_undef(oring_interference);
  _oring_cut_height = _oring_enabled ? oring_height - oring_interference : 0;

  // Conditional parameters based on part type
  _neck_h = (part == "lock") ? 0 : neck_height;
  _neck_cut_h = (part == "lock" || !_oring_enabled) ? 0 : _oring_cut_height;
  _neck_r_allow = (part == "lock") ? 0 : allowance;
  _inner_r_fill = (part == "lock") ? 0 : center_bore_radius;
  _inner_h_fill = (part == "lock") ? 0 : _neck_h + part_height;

  // Calculate outer radius from shell_thickness
  _outer_radius = inner_radius + 2 * shell_thickness;

  difference() {
    union() {
      // Core bayonet with optional neck
      if (_neck_h > 0) {
        bayonet_neck(_neck_h, inner_radius, _outer_radius)
          bayonet(
            half=part,
            inner_radius=inner_radius,
            shell_thickness=shell_thickness,
            allowance=allowance,
            part_height=part_height,
            entry_depth=_entry_depth,
            number_of_pins=number_of_pins,
            pin_radius=pin_radius,
            sweep_angle=sweep_angle,
            pin_direction=pin_direction,
            turn_direction=turn_direction
          );
      } else {
        bayonet(
          half=part,
          inner_radius=inner_radius,
          shell_thickness=shell_thickness,
          allowance=allowance,
          part_height=part_height,
          entry_depth=_entry_depth,
          number_of_pins=number_of_pins,
          pin_radius=pin_radius,
          sweep_angle=sweep_angle,
          pin_direction=pin_direction,
          turn_direction=turn_direction
        );
      }

      // Inner fill cylinder (creates sealing surface)
      if (_inner_r_fill > 0) {
        tube(h=_inner_h_fill, r_outer=inner_radius + allowance, r_inner=_inner_r_fill);
      }
    }

    // O-ring groove (cut from +Z face of neck)
    if (_oring_enabled && _neck_h > 0) {
      _mid_radius = inner_radius + shell_thickness - allowance;
      translate([0, 0, neck_height - _neck_cut_h])
        tube(h=_neck_cut_h * 1.1, r_outer=_outer_radius * 1.1, r_inner=_mid_radius);
    }

    // Outer allowance on neck (for easier insertion)
    if (_neck_h > 0 && _neck_r_allow > 0) {
      translate([0, 0, -zFite / 2])
        tube(h=neck_height, r_outer=_outer_radius * 1.1, r_inner=_outer_radius - _neck_r_allow);
    }

    // Catch pockets (holes for pliers to grip and rotate)
    if (catch_pockets && _neck_h > 0) {
      for (i = [0:1])
        rotate([0, 0, i * 180])
          translate([inner_radius, 0, -zFite / 2])
            cylinder(h=neck_height / 2, d=2 * shell_thickness);
    }

    // Text labels (radius and diameter markings)
    if (text_labels && _neck_h > 0) {
      _radString =
        is_undef(text_radius_override) ? str("R", center_bore_radius)
        : text_radius_override;
      _diaString =
        is_undef(text_diameter_override) ? str("D", center_bore_radius * 2)
        : text_diameter_override;

      translate([0, inner_radius, neck_height / 2 - zFite / 2]) {
        rotate([0, 180, 0])
          linear_extrude(neck_height / 2)
            text(
              _radString, size=2 * shell_thickness,
              halign="center", valign="center", font="sans", $fn=32
            );
      }
      translate([0, -inner_radius, neck_height / 2 - zFite / 2]) {
        rotate([0, 180, 0])
          linear_extrude(neck_height / 2)
            text(
              _diaString, size=2 * shell_thickness,
              halign="center", valign="center", font="sans", $fn=32
            );
      }
    }
  }
}
