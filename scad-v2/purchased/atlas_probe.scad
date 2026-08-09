/**
 * @file atlas_probe.scad
 * @brief Atlas Scientific EZO-line probe model
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The EZO product line shares a distinctive shape across its variants, which differ in size
 * but largely not in form: a wire stub, a tapered accent neck, a body, and a vented tip.
 */

use <../utils/trapezium.scad>;

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

function atlas_probe_name(type) = type[0]; // registered name, e.g. "ph"
function atlas_probe_neck_dia(type) = type[1][0]; // diameter of the neck base
function atlas_probe_neck_height(type) = type[1][1]; // height of the tapered neck
function atlas_probe_neck_taper_dia(type) = type[1][2]; // diameter of the neck at taper end
function atlas_probe_body_dia(type) = type[2][0]; // diameter of the body
function atlas_probe_body_height(type) = type[2][1]; // height of the body
function atlas_probe_tip_dia(type) = type[3][0]; // diameter of the tip
function atlas_probe_tip_height(type) = type[3][1]; // height of the tip
// The tail group describes the cord end, which atlas_probe() does not draw; it is held for the
// collet in bayonet_probe_port. See the CONFLICT note in atlas_probes.scad - it overlaps neck.
function atlas_probe_tail_major_dia(type) = type[4][0]; // tail diameter at the cap
function atlas_probe_tail_minor_dia(type) = type[4][1]; // tail diameter at the cord
function atlas_probe_tail_length(type) = type[4][2]; // length of the tapered tail
function atlas_probe_connector_dia(type) = type[4][3]; // connector across the hex flats
function atlas_probe_wire_dia(type) = type[5]; // diameter of the wire
function atlas_probe_accent_color(type) = type[6]; // accent color for the neck

/**
 * @brief Creates an Atlas Scientific probe from a registered type
 * @param type Registered parameter set (see atlas_probes.scad)
 * @param wire_h Height of the wire stub (display only; arbitrary length for visualization or difference cuts)
 */
module atlas_probe(type, wire_h = 10) {
  neck_d = atlas_probe_neck_dia(type);
  neck_h = atlas_probe_neck_height(type);
  neck_taper_d = atlas_probe_neck_taper_dia(type);
  body_d = atlas_probe_body_dia(type);
  body_h = atlas_probe_body_height(type);
  tip_d = atlas_probe_tip_dia(type);
  tip_h = atlas_probe_tip_height(type);
  wire_d = atlas_probe_wire_dia(type);
  accent_color = atlas_probe_accent_color(type);

  // None of the atlas probes are pink, so we set this so its obvious
  // that the color is unset and will apply for custom probes by default
  accent_color_eff = is_undef(accent_color) ? "Pink" : accent_color;

  colors = ["Black", accent_color_eff, "Black", "Yellow"];

  union() {
    // Wire
    translate([0, 0, -wire_h]) color(colors[0]) cylinder(h=wire_h, d=wire_d, $fn=64);

    // Neck
    color(colors[1]) cylinder(h=neck_h, d2=neck_d, d1=neck_taper_d, $fn=64);

    // Body
    translate([0, 0, neck_h]) color(colors[2]) cylinder(h=body_h, d=body_d, $fn=64);

    depth = 6;
    thick = 2;
    curve_scale_y = 0.5;
    cut_size = tip_d / 3;
    curve_comp = cut_size * curve_scale_y * 0.5;

    // Sensing Tip
    translate([0, 0, neck_h + body_h]) color(colors[3], alpha=0.5) difference() {
          cylinder(h=tip_h, d=tip_d, $fn=64);

          translate([0, 0, tip_h - depth]) cylinder(h=depth + z_fight, d=tip_d - thick * 2, $fn=64);

          for (i = [0:1])
            rotate([0, 0, 90 * i]) translate([0, tip_d, tip_h - depth + curve_comp + z_fight])
                rotate([90, 0, 0]) linear_extrude(tip_d * 2) union() {

                      trapezium(bottom_width=cut_size, top_width=cut_size - thick / 2, height=depth - curve_comp);
                      scale([1, curve_scale_y, 1]) circle(d=cut_size);
                    }
        }
  }
}
