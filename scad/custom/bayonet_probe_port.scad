/**
 * @file bayonet_probe_port.scad
 * @brief Probe port with bayonet lock and flexible pinch clamp
 * @author Cameron K. Brooks
 * @copyright 2026
 */

use <bayonet_port.scad>
use <cylindrical_flex_collet.scad>
include <bayonet_interfaces.scad>
include <../purchased/atlas_probes.scad>

$fn = $preview ? 64 : 128;

_bp_center_bore_radius = 3; // Radius of the center bore
_bp_panel_thickness = 18; // Lid thickness at the port, for standalone preview

// ----- Design parameters -----
// Every hardware dimension now comes from the registered probe; what is left here are the
// collet's own design choices.

_bp_collet_wall_thickness = 1.2;
_bp_collet_body_allowance = 0.6; // grip fit; tune this, not the registry, if a cap is tight
_bp_collet_connector_allowance = 0.6;
_bp_collet_tab_gap = 1.0;
_bp_collet_tab_internal_deflection = 0.5;
_bp_tilt_degrees = 7; // Tilt to avoid bubbles on sensor face
_bp_transition_length = 25;

bayonet_probe_port(
  type=bayonet_std,
  probe=ph_lab_g2,
  panel_thickness=_bp_panel_thickness,
  center_bore_radius=_bp_center_bore_radius,
  collet_wall_thickness=_bp_collet_wall_thickness,
  collet_body_allowance=_bp_collet_body_allowance,
  collet_connector_allowance=_bp_collet_connector_allowance,
  collet_tab_gap=_bp_collet_tab_gap,
  collet_tab_internal_deflection=_bp_collet_tab_internal_deflection,
  tilt_degrees=_bp_tilt_degrees,
  transition_length=_bp_transition_length
);

// ----- build -----
// This is a pin half by definition - the lock half is the same for every port, so the lid
// takes it straight from bayonet_port(). Shares bayonet_port's datum: the collet hangs off
// the bottom of the coupling, inside the vessel, and the connector passes up through the bore.
// OpenSCAD has no case conversion, and registry names are lower case; caps read better on a
// 3.6 mm engraved mark.
function _bp_upper(s, i = 0) =
  i >= len(s) ? ""
  : str((ord(s[i]) >= 97 && ord(s[i]) <= 122) ? chr(ord(s[i]) - 32) : s[i], _bp_upper(s, i + 1));

module bayonet_probe_port(
  type,
  probe,
  panel_thickness,
  center_bore_radius,
  collet_wall_thickness,
  collet_body_allowance,
  collet_connector_allowance,
  collet_tab_gap,
  collet_tab_internal_deflection,
  tilt_degrees,
  transition_length
) {

  // Interface scalars this adapter needs for its own placement and taper.
  interface_radius = bayonet_interface_radius(type);
  allowance = bayonet_allowance(type);

  // The collet grips the probe body, so the registered probe sets the bore this port is cut
  // for - and the mark that says which probe it takes.
  probe_body_diameter = atlas_probe_body_dia(probe);
  probe_body_length = atlas_probe_body_height(probe);

  // The collet's neck section houses the probe's strain relief boot, so the boot sizes it.
  boot_cap_diameter = atlas_probe_neck_dia(probe);
  boot_cord_diameter = atlas_probe_neck_taper_dia(probe);
  boot_length = atlas_probe_neck_height(probe);

  // The connector passes up a hex, so size it across the flats to clear a round connector.
  _hex_diameter = (atlas_probe_connector_dia(probe) + collet_connector_allowance) / cos(30);

  // The transitions mate to the bayonet at its interface (mating) surface, less the allowance.
  _bayonet_diameter = 2 * interface_radius - allowance;
  _transition_length = transition_length + probe_body_diameter / sqrt(3);

  union() {

    // Bayonet connector
    difference() {
      bayonet_port(
        type=type,
        part="pin",
        panel_thickness=panel_thickness,
        center_bore_radius=center_bore_radius,
        text_labels=true,
        // Not the bore - the connector hex below opens straight through it. What matters is
        // which probe the collet is cut for, since pH and DO differ by less than a millimetre.
        label=str(_bp_upper(atlas_probe_name(probe)), " Ø", probe_body_diameter)
      );

      // Cut hexagonal hole for connector
      cylinder(h=1000, d=_hex_diameter, center=true, $fn=6);
    }

    translate([0, 0, -panel_thickness]) {

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
      cylinder(h=1000, d=_hex_diameter, center=true, $fn=6);
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
                tail_diameter_start=boot_cap_diameter,
                tail_diameter_end=boot_cord_diameter,
                tail_len=boot_length,
                end_diameter=_hex_diameter,
                shell_wall=collet_wall_thickness,
                allowance=collet_body_allowance,
                flex_tab_clearance=collet_tab_gap,
                flex_tab_offset=collet_tab_internal_deflection
              );
            cylinder(h=probe_body_length + boot_length, d=probe_body_diameter * 2);
          }
        }

        // Cut hexagonal hole for connector
        cylinder(h=1000, d=_hex_diameter, center=true, $fn=6);
      }
    }
    }
  }
}
