/**
 * @file peri_pump.scad
 * @brief Peristaltic dosing pump: the bought head on its registered motor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A vitamin drawn from the head field of the row: the faceplate that the motor screws pass
 * through, the cassette behind its round cover, the tube block with its two barbs, and the
 * latches. Detailed enough to be recognisable in renders and to place correctly, not to make one
 * from. Sets no $fn.
 */

use <dc_motor.scad>

function peri_pump_name(type) = type[0]; // catalogue name
function peri_pump_part_number(type) = type[1]; // part number to order by
function peri_pump_envelope(type) = type[2]; // [length, width, height] bounding box
function peri_pump_length(type) = type[2][0];
function peri_pump_width(type) = type[2][1]; // faceplate width, across the holes
function peri_pump_height(type) = type[2][2]; // faceplate height, perpendicular to the width
function peri_pump_tube_inner_diameter(type) = type[3][0]; // tube bore
function peri_pump_tube_outer_diameter(type) = type[3][1]; // tube OD, which a port has to grip
function peri_pump_motor(type) = type[4]; // motor fitted behind the head, a dc_motors row
function peri_pump_cover_diameter(type) = type[5][0]; // round cover over the rollers
function peri_pump_head_depth(type) = type[5][1]; // faceplate face to top of cover
function peri_pump_plate_thickness(type) = type[5][2]; // thickness of the faceplate under the head
function peri_pump_hole_spacing(type) = type[5][3][0]; // faceplate holes, centre to centre
function peri_pump_hole_diameter(type) = type[5][3][1];
function peri_pump_barb_pitch(type) = type[5][4][0]; // barbs, centre to centre
function peri_pump_barb_diameter(type) = type[5][4][1]; // barb diameter the tube pushes over
function peri_pump_barb_reach(type) = type[5][4][2]; // motor axis to barb tip
// head length, from the back of the faceplate (where the motor meets it) to the top of the cover
function peri_pump_head_length(type) = peri_pump_plate_thickness(type) + peri_pump_head_depth(type);

// Origin is on the motor axis at the faceplate. The head extends up from it, the barbs point
// along +x, and the motor hangs below.
module peri_pump(type) {
  _cover = peri_pump_cover_diameter(type);
  _plate = peri_pump_plate_thickness(type);
  _holes = peri_pump_hole_spacing(type);
  _hole = peri_pump_hole_diameter(type);
  _pitch = peri_pump_barb_pitch(type);
  _barb = peri_pump_barb_diameter(type);
  _reach = peri_pump_barb_reach(type);
  _body = peri_pump_head_depth(type); // the cassette, plate face to cover
  // the plate is full height across the middle and narrows to an ear around each hole; the ears
  // reach the full width
  _ear = (peri_pump_width(type) - _holes) / 2;
  _boss = _barb + 1.5; // boss each barb projects from
  _block = _cover / 2 + 2; // face of the tube block, beyond the cover on +x

  // the faceplate, with its ears along x
  color("#202020")
    linear_extrude(_plate)
      difference() {
        hull() {
          circle(d=peri_pump_height(type), $fn=64);
          for (s = [-1, 1]) translate([s * _holes / 2, 0]) circle(r=_ear, $fn=24);
        }
        for (s = [-1, 1]) translate([s * _holes / 2, 0]) circle(d=_hole, $fn=24);
      }

  color("#1e5bc6")
    translate([0, 0, _plate]) {
      // the cassette behind the round cover
      cylinder(d=_cover, h=_body, $fn=64);
      // the tube block where the tube exits the cassette, and its barbs
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
