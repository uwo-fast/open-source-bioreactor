/**
 * @file heat_pad.scad
 * @brief A silicone heating pad, drawn flat: length along x, height along z, centred on both, its
 * glass-side face on y = 0 and its thickness toward +y
 * @author Cameron K. Brooks
 * @copyright 2026
 */

function heat_pad_name(type) = type[0];
function heat_pad_part_number(type) = type[1];
function heat_pad_length(type) = type[2][0];
function heat_pad_height(type) = type[2][1];
function heat_pad_thickness(type) = type[2][2];
function heat_pad_volts(type) = type[3][0];
function heat_pad_watts(type) = type[3][1];
function heat_pad_resistance(type) = type[4];
function heat_pad_lead_length(type) = type[5];

/**
 * @brief Draws a registered heating pad (see heat_pads.scad)
 * @param type Registered parameter set
 */
module heat_pad(type) {
  color("firebrick")
    translate([-heat_pad_length(type) / 2, 0, -heat_pad_height(type) / 2])
      cube([heat_pad_length(type), heat_pad_thickness(type), heat_pad_height(type)]);
}
