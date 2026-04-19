/**
 * @file bayonet_probe_port.scad
 * @brief Probe port with bayonet lock and flexible pinch clamp
 * @author Cameron K. Brooks
 * @copyright 2026
 */

use <bayonet_port.scad>
use <cylindrical_flex_collet.scad>

zFite = $preview ? 0.01 : 0;
$fn = $preview ? 64 : 128;

// ----- Bayonet parameters -----

_bp_inner_radius = 7; // Inner radius of the bayonet
_bp_bayonet_shell_thickness = 2.5; // Thickness of the bayonet shell
_bp_part_height = 10; // Height of the bayonet part
_bp_neck_height = 5; // Height of the neck
_bp_pin_radius = 1.5; // Radius of the locking pins
_bp_center_bore_radius = 3; // Radius of the center bore
_bp_oring_height = 1.6; // Height of the o-ring
_bp_oring_interference = 0.1; // Compression of the o-ring

// ----- Probe-specific (hardware) parameters -----

probe_body_length = 35.6;
probe_body_diameter = 15.9; // 15.9 on soft backed probe, 16.3 on hard backed probe
tail_major_diameter = 8.7;
tail_minor_diameter = 4.3;
tail_length = 24.5;
connector_part_diameter = 10;

// ----- Design parameters -----

collet_wall_thickness = 1.2;
collet_internal_allowance = 0.6;
collet_tab_gap = 1.0;
collet_tab_internal_deflection = 0.5;
tilt_degrees = 7; // Tilt to avoid bubbles on sensor face
transition_length = 25;

bayonet_probe_port(
  part="pin",
  inner_radius=_bp_inner_radius,
  bayonet_shell_thickness=_bp_bayonet_shell_thickness,
  part_height=_bp_part_height,
  neck_height=_bp_neck_height,
  pin_radius=_bp_pin_radius,
  center_bore_radius=_bp_center_bore_radius,
  oring_height=_bp_oring_height,
  oring_interference=_bp_oring_interference
);

// ----- build -----
module bayonet_probe_port(
  // Bayonet parameters
  part,
  inner_radius,
  bayonet_shell_thickness,
  part_height,
  neck_height,
  pin_radius,
  center_bore_radius,
  oring_height,
  oring_interference
) {

  // Calculate bayonet diameter for transitions
  _bayonet_diameter = 2 * (inner_radius + bayonet_shell_thickness) - 0.2;
  _transition_length = transition_length + probe_body_diameter / sqrt(3);

  union() {

    // Bayonet lock connector
    difference() {
      rotate([0, 180, 0])
        translate([0, 0, -part_height - neck_height])
          bayonet_port(
            part=part,
            inner_radius=inner_radius,
            shell_thickness=bayonet_shell_thickness,
            part_height=part_height,
            neck_height=neck_height,
            pin_radius=pin_radius,
            center_bore_radius=center_bore_radius,
            oring_height=oring_height,
            oring_interference=oring_interference
          );

      // Cut hexagonal hole for connector
      cylinder(h=1000, d=connector_part_diameter + collet_internal_allowance, center=true, $fn=6);
    }

    // Tilt transition wedge
    difference() {
      rotate([-90, 0, 0]) {
        rotate_extrude(angle=tilt_degrees, convexity=10)
          difference() {
            circle(d=_bayonet_diameter);
            translate([-_bayonet_diameter / 2, 0, 0])
              square([_bayonet_diameter, _bayonet_diameter * 2], center=true);
          }
      }
      cylinder(h=1000, d=connector_part_diameter + collet_internal_allowance, center=true, $fn=6);
    }

    // Probe holder with tilt
    rotate([0, tilt_degrees, 0]) {
      difference() {
        union() {
          // Transition segment with larger diameter to mate with bayonet bottom to collet tail
          translate([0, 0, -_transition_length])
            cylinder(
              h=_transition_length,
              d1=probe_body_diameter + collet_wall_thickness * 2,
              d2=_bayonet_diameter
            );

          difference() {
            // Flexible pinch clamp
            translate([0, 0, -_transition_length])
              cylindrical_flex_collet(
                body_length=probe_body_length,
                body_diameter=probe_body_diameter,
                tail_diameter_start=tail_major_diameter,
                tail_diameter_end=tail_minor_diameter,
                tail_len=tail_length,
                end_diameter=connector_part_diameter,
                shell_wall=collet_wall_thickness,
                allowance=collet_internal_allowance,
                flex_tab_clearance=collet_tab_gap,
                flex_tab_offset=collet_tab_internal_deflection
              );
            cylinder(h=probe_body_length + tail_length, d=probe_body_diameter * 2);
          }
        }

        // Cut hexagonal hole for connector
        cylinder(h=1000, d=connector_part_diameter + collet_internal_allowance, center=true, $fn=6);
      }
    }
  }
}
