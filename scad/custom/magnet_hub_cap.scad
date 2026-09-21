/**
 * @file magnet_hub_cap.scad
 * @brief The cap on a fan's hub that carries the two magnets of a magnetic stirrer
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A disc the diameter of the hub, glued to its face, with two pockets on a diameter for the
 * magnets, opposite poles up and as far apart as the hub allows. A skirt over the hub would foul
 * the blade roots, so it is a disc and an adhesive. This file's render is a preview.
 */

include <../purchased/fans.scad>; // fan_hub() of the preview's fan
include <../purchased/magnets.scad>; // the magnet rows, and magnet() to draw them

z_fight = $preview ? 0.05 : 0;
$fn = $preview ? 64 : 128;

/* [Preview] */

// The fan the preview caps
cap_fan_name = "fan80x25"; // [fan80x25, fan80x38, fan60x25, fan60x15, fan40x11, fan30x10]
// The magnets, two of them
cap_magnet_name = "MAG5x8"; // [MAG5x8, MAGRE6x2p5, MAG8x4x4p2, MAG484]

/* [Cap] */

// wall left outside each magnet pocket, at the rim
hub_cap_rim = 2;
// floor under the magnets, which is what the glue holds
hub_cap_floor = 1;
// allowance on the pocket diameter, a press fit
hub_cap_magnet_allow = 0.2;
// Show the magnets in their pockets
render_magnets = true;

/* [Hidden] */
_cap_fan = fan_by_name(cap_fan_name);
_cap_magnet = magnet_by_name(cap_magnet_name);

module dummy() {
  // stop the customizer detection from here onwards
}

// Centre to centre of the two magnets: the hub less a pocket and a rim each side. The defaults
// are this file's parameters, so a caller states only the hub and the magnet.
function hub_cap_pitch(hub_diameter, magnet, rim = hub_cap_rim) = hub_diameter - magnet_od(magnet) - 2 * rim;
function hub_cap_height(magnet, floor = hub_cap_floor) = floor + magnet_h(magnet);

/**
 * @brief The cap, base on z = 0, pockets open at the top
 * @param hub_diameter The fan hub it sits on, and so its own diameter
 * @param magnet Registered magnet row (NopSCADlib), one in each pocket
 * @param rim Wall outside each pocket
 * @param floor Under the pockets
 * @param magnet_allow Diametral allowance on the pocket
 * @param cap Draw the printed disc
 * @param magnets Draw the magnets in place, a vitamin
 */
module magnet_hub_cap(hub_diameter, magnet, rim = hub_cap_rim, floor = hub_cap_floor, magnet_allow = hub_cap_magnet_allow, cap = true, magnets = false) {
  _pitch = hub_cap_pitch(hub_diameter, magnet, rim);
  _height = hub_cap_height(magnet, floor);

  assert(
    _pitch > magnet_od(magnet),
    str("magnet_hub_cap: a ", hub_diameter, " mm hub cannot hold two ", magnet_od(magnet), " mm magnets ", rim, " mm in from its edge.")
  );

  if (cap)
    difference() {
      cylinder(d=hub_diameter, h=_height);
      for (s = [-1, 1])
        translate([s * _pitch / 2, 0, floor])
          cylinder(d=magnet_od(magnet) + magnet_allow, h=magnet_h(magnet) + z_fight);
    }

  if (magnets)
    for (s = [-1, 1])
      translate([s * _pitch / 2, 0, floor])
        magnet(magnet);
}

magnet_hub_cap(fan_hub(_cap_fan), _cap_magnet, magnets=render_magnets);
