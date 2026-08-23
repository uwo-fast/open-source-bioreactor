/**
 * @file thermocouple_probe.scad
 * @brief Metal-body threaded thermocouple probe
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Stacked from the cable end up: a cable stub, a tapered neck, a hex across the flats, a
 * threaded body (drawn plain unless show_threads is set) and the sensing tip.
 */

use <threads-scad/threads.scad>;

$fn = $preview ? 64 : 128;

include <../utils/npt_threads.scad>

function thermocouple_probe_part_number(type) = type[1]; // what to order it by
function thermocouple_probe_thread(type) = type[2]; // registered NPT thread it screws in on
function thermocouple_probe_neck_dia(type) = type[3][0]; // diameter of the neck
function thermocouple_probe_neck_height(type) = type[3][1]; // height of the neck
function thermocouple_probe_flats_height(type) = type[3][2]; // height of the hex flats
function thermocouple_probe_body_height(type) = type[3][3]; // height of the body
function thermocouple_probe_tip_dia(type) = type[3][4]; // diameter of the sensing tip
function thermocouple_probe_tip_height(type) = type[3][5]; // immersion depth
function thermocouple_probe_wire_dia(type) = type[3][6]; // diameter of the wire
function thermocouple_probe_wire_height(type) = type[3][7]; // height of the wire stub

// Both follow from the thread, so they are read off it rather than registered twice.
function thermocouple_probe_flats_dia(type) = npt_thread_hex_across_flats(thermocouple_probe_thread(type));
function thermocouple_probe_body_dia(type) = npt_thread_major_diameter(thermocouple_probe_thread(type));

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
