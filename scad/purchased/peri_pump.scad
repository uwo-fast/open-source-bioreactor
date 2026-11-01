/**
 * @file peri_pump.scad
 * @brief Peristaltic dosing pump, drawn at the envelope the catalogue gives
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A vitamin: the head drawn as the box the catalogue gives, because that is all that is known of it,
 * on its registered motor. Sets no $fn.
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

// Origin on the motor's axis, at the faceplate: the head stands up from it in the envelope's width
// (x) and height (y), the motor hangs below it.
module peri_pump(type) {
  color("dimgrey")
    translate([0, 0, peri_pump_head_length(type) / 2])
      cube([peri_pump_width(type), peri_pump_height(type), peri_pump_head_length(type)], center=true);
  translate([0, 0, -dc_motor_length(peri_pump_motor(type))])
    dc_motor(peri_pump_motor(type));
}
