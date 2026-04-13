// This is meant to model a metal-body threaded thermocouple probe
// Atlas probe geometry: medium tip cylinder, larger body cylinder.
// Tapered neck cylinder leading to a small cable cylinder.

use <../utils/trapezium.scad>;
use <threads-scad/threads.scad>;

zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

threaded_thermocouple();

// Creates a probe with customizable dimensions and colors
module threaded_thermocouple(
  neck_d = 10,
  neck_h = 12,
  flats_d = 26,
  flats_h = 5,
  body_d = 21,
  body_h = 20,
  tip_d = 3.5,
  tip_h = 115,
  wire_d = 3,
  wire_h = 10,
  colors = ["Olive", "Silver", "DarkGrey", "Grey", "Silver"],
  show_threads = false,
  position_base = false
) {
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
