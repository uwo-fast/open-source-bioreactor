/**
 * @file peri_pump.scad
 * @brief Peristaltic dosing pump, drawn at the envelope the catalogue gives
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A vitamin, drawn as the box the catalogue gives because that is all that is known. Sets no $fn.
 */

function peri_pump_name(type) = type[0]; // catalogue name
function peri_pump_part_number(type) = type[1]; // what to order it by
function peri_pump_envelope(type) = type[2]; // [length, width, height], the box it fits in
function peri_pump_length(type) = type[2][0];
function peri_pump_width(type) = type[2][1];
function peri_pump_height(type) = type[2][2];
function peri_pump_tube_inner_diameter(type) = type[3][0]; // the bore it pumps
function peri_pump_tube_outer_diameter(type) = type[3][1]; // what a port has to grip

// Origin at the centre of its footprint, on the face it stands on.
module peri_pump(type) {
  color("dimgrey")
    translate([0, 0, peri_pump_height(type) / 2])
      cube([peri_pump_length(type), peri_pump_width(type), peri_pump_height(type)], center=true);
}
