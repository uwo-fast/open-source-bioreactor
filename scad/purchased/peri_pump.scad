/**
 * @file peri_pump.scad
 * @brief Peristaltic dosing pump: the bought head on its registered motor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A vitamin, drawn from the row's head field: the faceplate the motor's screws pass through, the
 * cassette behind its round cover, the block the tube leaves through and its two barbs, and the
 * latches. Enough to read as the pump in a picture and to sit where it sits; not a drawing to make
 * one from. Sets no $fn.
 */

use <dc_motor.scad>

function peri_pump_name(type) = type[0]; // catalogue name
function peri_pump_part_number(type) = type[1]; // what to order it by
function peri_pump_envelope(type) = type[2]; // [length, width, height], the box it fits in
function peri_pump_length(type) = type[2][0];
function peri_pump_width(type) = type[2][1];
function peri_pump_height(type) = type[2][2];
function peri_pump_tube_inner_diameter(type) = type[3][0]; // the bore it pumps
function peri_pump_tube_outer_diameter(type) = type[3][1]; // what a port has to grip
function peri_pump_motor(type) = type[4]; // the motor fitted behind the head, a dc_motors row
// the head, above the faceplate: what the envelope's length leaves past the motor
function peri_pump_head_length(type) = peri_pump_length(type) - dc_motor_length(peri_pump_motor(type));
function peri_pump_cover_diameter(type) = type[5][0]; // the round cover over the rollers
function peri_pump_plate_thickness(type) = type[5][1]; // the faceplate the head stands on
function peri_pump_hole_spacing(type) = type[5][2][0]; // the faceplate's two holes, centre to centre
function peri_pump_hole_diameter(type) = type[5][2][1];
function peri_pump_barb_pitch(type) = type[5][3][0]; // the two barbs, centre to centre
function peri_pump_barb_diameter(type) = type[5][3][1]; // what the tube pushes over
function peri_pump_barb_reach(type) = type[5][3][2]; // from the motor's axis to a barb's tip

// Origin on the motor's axis, at the faceplate: the head stands up from it, the barbs point along
// +x, and the motor hangs below it.
module peri_pump(type) {
  _cover = peri_pump_cover_diameter(type);
  _plate = peri_pump_plate_thickness(type);
  _holes = peri_pump_hole_spacing(type);
  _hole = peri_pump_hole_diameter(type);
  _pitch = peri_pump_barb_pitch(type);
  _barb = peri_pump_barb_diameter(type);
  _reach = peri_pump_barb_reach(type);
  _body = peri_pump_head_length(type) - _plate; // the cassette, plate face to cover
  _ear = _hole / 2 + 2; // the plate's wall round each hole
  _boss = _barb + 1.5; // what each barb stands out of
  _block = _cover / 2 + 2; // the tube block's face, past the cover on +x

  // the faceplate, its ears out along x
  color("#202020")
    linear_extrude(_plate)
      difference() {
        hull() {
          circle(d=_cover + 2, $fn=48);
          for (s = [-1, 1]) translate([s * _holes / 2, 0]) circle(r=_ear, $fn=24);
        }
        for (s = [-1, 1]) translate([s * _holes / 2, 0]) circle(d=_hole, $fn=24);
      }

  color("#1e5bc6")
    translate([0, 0, _plate]) {
      // the cassette behind the round cover
      cylinder(d=_cover, h=_body, $fn=64);
      // the block the tube leaves the cassette through, and the barbs out of it
      translate([0, -(_pitch + _boss) / 2, 0])
        cube([_block, _pitch + _boss, _body]);
      for (s = [-1, 1])
        translate([0, s * _pitch / 2, _body / 2])
          rotate([0, 90, 0]) {
            cylinder(d=_boss, h=_block + 1, $fn=24);
            cylinder(d=_barb, h=_reach, $fn=24);
          }
      // the latches holding the cover, top and bottom
      for (s = [-1, 1])
        translate([-3, s > 0 ? _cover / 2 - 1 : -_cover / 2 - 1.5, _body - 6])
          cube([6, 2.5, 6]);
    }

  translate([0, 0, -dc_motor_length(peri_pump_motor(type))])
    dc_motor(peri_pump_motor(type));
}
