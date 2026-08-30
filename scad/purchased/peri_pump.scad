/**
 * @file peri_pump.scad
 * @brief Peristaltic dosing pump, drawn at the envelope the catalogue gives
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A vitamin, the same as the bearing or the probes: bought, not designed, and drawn so the
 * assembly can see where it is and what it is in the way of. The body is a box because a box is
 * what is known - the catalogue gives an outside and nothing else, and a modelled curve would be a
 * guess with the authority of geometry.
 *
 * The printed head that might one day replace it is custom/peri_pump_head.scad.
 *
 * Sets no $fn: there is nothing round here to resolve.
 */

function peri_pump_name(type) = type[0]; // catalogue name
function peri_pump_part_number(type) = type[1]; // what to order it by
function peri_pump_envelope(type) = type[2]; // [length, width, height], the box it fits in
function peri_pump_length(type) = type[2][0];
function peri_pump_width(type) = type[2][1];
function peri_pump_height(type) = type[2][2];
function peri_pump_tube_inner_diameter(type) = type[3][0]; // the bore it pumps
function peri_pump_tube_outer_diameter(type) = type[3][1]; // what a port has to grip

/**
 * @brief Draw the pump at its envelope.
 *
 * Origin at the CENTRE OF ITS FOOTPRINT, on the face it stands on, so a caller places it by the
 * face it is mounted against rather than by a corner nobody can find on the real part.
 *
 * @param type Registered parameter set (see peri_pumps.scad)
 */
module peri_pump(type) {
  color("dimgrey")
    translate([0, 0, peri_pump_height(type) / 2])
      cube([peri_pump_length(type), peri_pump_width(type), peri_pump_height(type)], center=true);
}
