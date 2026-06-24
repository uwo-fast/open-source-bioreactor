// This is meant to model a metal-body threaded thermocouple probe
// Atlas probe geometry: medium tip cylinder, larger body cylinder.
// Tapered neck cylinder leading to a small cable cylinder.

use <threads-scad/threads.scad>;

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

function thermocouple_probe_neck_dia(type) = type[1][0]; // diameter of the neck
function thermocouple_probe_neck_height(type) = type[1][1]; // height of the neck
function thermocouple_probe_flats_dia(type) = type[1][2]; // across-flats diameter of the hex
function thermocouple_probe_flats_height(type) = type[1][3]; // height of the hex flats
function thermocouple_probe_body_dia(type) = type[1][4]; // diameter of the body
function thermocouple_probe_body_height(type) = type[1][5]; // height of the body
function thermocouple_probe_tip_dia(type) = type[1][6]; // diameter of the sensing tip
function thermocouple_probe_tip_height(type) = type[1][7]; // height of the sensing tip
function thermocouple_probe_wire_dia(type) = type[1][8]; // diameter of the wire
function thermocouple_probe_wire_height(type) = type[1][9]; // height of the wire stub

// Creates a probe from a registered type (see thermocouple_probes.scad)
module thermocouple_probe(
  type,
  colors = ["Olive", "Silver", "DarkGrey", "Grey", "Silver"],
  show_threads = false,
  position_base = false
) {
  neck_d = thermocouple_probe_neck_dia(type);
  neck_h = thermocouple_probe_neck_height(type);
  flats_d = thermocouple_probe_flats_dia(type);
  flats_h = thermocouple_probe_flats_height(type);
  body_d = thermocouple_probe_body_dia(type);
  body_h = thermocouple_probe_body_height(type);
  tip_d = thermocouple_probe_tip_dia(type);
  tip_h = thermocouple_probe_tip_height(type);
  wire_d = thermocouple_probe_wire_dia(type);
  wire_h = thermocouple_probe_wire_height(type);

  position_body(neck_h, flats_h, position_base) union() {
      // Wire
      translate([0, 0, -wire_h]) color(colors[0]) cylinder(h=wire_h, d=wire_d, $fn=64);

      // Neck
      color(colors[1]) cylinder(h=neck_h, d=neck_d, $fn=64);

      // Flats
      translate([0, 0, neck_h]) color(colors[2]) cylinder(h=flats_h, d=flats_d, $fn=6);

      // Body
      translate([0, 0, neck_h + flats_h]) color(colors[3]) if (show_threads) {
          // Threaded body
          ScrewThread(
            outer_diam=body_d, height=body_h,
            pitch=25.4 / 14
          ); // 14 threads per inch for 1/2 NPT; TODO: parameterize
        } else {
          // Non-threaded body
          cylinder(d=body_d, h=body_h);
        }

      // Sensing Tip
      translate([0, 0, neck_h + body_h + flats_h]) color(colors[4]) union() {
            cylinder(h=tip_h, d=tip_d, $fn=64);
            translate([0, 0, tip_h]) sphere(d=tip_d, $fn=64);
          }
    }
}

module position_body(neck, flats, position_base = false) {
  if (position_base)
    translate([0, 0, neck + flats]) rotate([0, 180, 0]) children();
  else
    children();
}
