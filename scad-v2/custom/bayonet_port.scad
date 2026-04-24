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

_bl_part = "pin"; // Part type: "pin" or "lock"

_bl_interface_radius = 12; // Interface radius of the bayonet
_bl_pin_radius = 1.5; // Radius of the locking pins
_bl_part_height = 10; // Height of the bayonet part
_bl_neck_height = 5; // Height of the neck (0 for no neck)
_bl_neck_radius = 15; // Radius of the neck (only relevant if neck_height > 0)

_bl_center_bore_radius = 3; // Radius of the center bore (0 for no bore)
_bl_oring_cs_diameter = 1.6; // Set to undef to disable o-ring groove

// Example usage (o-ring enabled by specifying oring_cs_diameter)
bayonet_port(
  part=_bl_part,
  interface_radius=_bl_interface_radius,
  pin_radius=_bl_pin_radius,
  part_height=_bl_part_height,
  neck_height=_bl_neck_height,
  neck_radius=_bl_neck_radius,
  oring_cs_diameter=_bl_oring_cs_diameter,
  text_labels=true
);

module bayonet_port(
  part,
  interface_radius,
  pin_radius,
  part_height,
  neck_height,
  neck_radius,
  center_bore_radius = 0,
  allowance = 0.2,
  number_of_pins = 3,
  sweep_angle = 30,
  pin_direction = "outer",
  turn_direction = "CW",
  entry_depth = undef,
  oring_cs_diameter = undef,
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
    oring_cs_diameter == undef || oring_cs_diameter > 0,
    "bayonet_port: oring_cs_diameter must be > 0 when specified"
  );
  assert(
    !text_labels || is_undef(text_radius_override) || is_undef(text_diameter_override) || text_labels,
    "bayonet_port: text_radius_override and text_diameter_override require text_labels=true"
  );

  // Auto-calculate entry_depth if not specified (50% of part_height)
  _entry_depth = is_undef(entry_depth) ? part_height * 0.5 : entry_depth;

  // O-ring enabled when a height is specified
  // interference [to compress the o-ring] defaults to 0.1
  _oring_enabled = !is_undef(oring_cs_diameter);
  _oring_cut_height = _oring_enabled ? oring_cs_diameter : 0;

  // Conditional parameters based on part type
  _neck_h = (part == "lock") ? 0 : neck_height;

  // Calculate outer radius from shell_thickness
  difference() {
    union() {

      // Core bayonet geometry
      translate([0, 0, _neck_h])
        bayonet(
          half=part,
          interface_radius=interface_radius,
          allowance=allowance,
          part_height=part_height,
          entry_depth=_entry_depth,
          number_of_pins=number_of_pins,
          pin_radius=pin_radius,
          sweep_angle=sweep_angle,
          pin_direction=pin_direction,
          turn_direction=turn_direction
        );

      // Fill middle with center bore
      if (center_bore_radius > 0) {
        _tube(h=part_height + _neck_h, r_outer=interface_radius - pin_radius, r_inner=center_bore_radius);
      } else {

        cylinder(h=part_height + _neck_h, r=interface_radius - pin_radius);
      }

      // neck cylinder
      if (_neck_h > 0)
        cylinder(h=_neck_h, r=neck_radius);
    }

    // Catch pockets (holes for pliers to grip and rotate)
    if (catch_pockets && _neck_h > 0) {
      for (i = [0:1])
        rotate([0, 0, i * 180])
          translate([interface_radius * 0.8, 0, -zFite / 2])
            cylinder(h=neck_height / 2, d=2 * interface_radius / 4);
    }

    // Text labels (radius and diameter markings)
    if (text_labels && _neck_h > 0) {

      // Construct label strings with overrides if provided
      _radString =
        is_undef(text_radius_override) ? str("R", center_bore_radius)
        : text_radius_override;
      _diaString =
        is_undef(text_diameter_override) ? str("D", center_bore_radius * 2)
        : text_diameter_override;

      // Top (+Y) string impression
      translate([0, interface_radius * 0.8, neck_height / 2 - zFite / 2]) {
        rotate([0, 180, 0])
          linear_extrude(neck_height / 2)
            text(
              _radString, size=interface_radius / 2,
              halign="center", valign="center", font="sans", $fn=32
            );
      }

      // Bottom (-Y) string impression
      translate([0, -interface_radius * 0.8, neck_height / 2 - zFite / 2]) {
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
