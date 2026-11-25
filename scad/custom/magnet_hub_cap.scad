/**
 * @file magnet_hub_cap.scad
 * @brief Cap on a fan hub that holds the two magnets of a magnetic stirrer
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A disc the same diameter as the hub, glued or taped to its face. Two pockets on a diameter hold
 * the magnets, opposite poles up and as far apart as the hub allows. A skirt over the hub would
 * foul the blade roots, so the cap is a flat disc fixed with adhesive or double-sided tape. The
 * render in this file is a preview.
 */

include <../purchased/fans.scad>; // fan_hub() of the preview fan
include <../purchased/magnets.scad>; // the magnet rows, and magnet() to draw them

z_fight = $preview ? 0.05 : 0;
$fn = $preview ? 64 : 128;

/* [Preview] */

// Fan used in the preview
cap_fan_name = "fan80x25"; // [fan80x25, fan80x38, fan60x25, fan60x15, fan40x11, fan30x10]
// Magnet type (two are used)
cap_magnet_name = "MAG5x8"; // [MAG5x8, MAGRE6x2p5, MAG8x4x4p2, MAG484]

/* [Cap] */

// wall outside each magnet pocket, at the rim
hub_cap_rim = 2;
// floor under the magnets, the surface that is glued
hub_cap_floor = 1;
// allowance on the pocket diameter for a press fit
hub_cap_magnet_allow = 0.2;
// Show the magnets in their pockets
render_magnets = true;

/* [Hidden] */
_cap_fan = fan_by_name(cap_fan_name);
_cap_magnet = magnet_by_name(cap_magnet_name);

module dummy() {
  // stop the customizer detection from here onwards
}

// Centre-to-centre distance of the two magnets: the hub diameter less one pocket and a rim on
// each side. The defaults are the parameters in this file, so a caller passes only the hub and
// the magnet.
function hub_cap_pitch(hub_diameter, magnet, rim = hub_cap_rim) = hub_diameter - magnet_od(magnet) - 2 * rim;
function hub_cap_height(magnet, floor = hub_cap_floor) = floor + magnet_h(magnet);
// Smallest hub that can hold the pair: two magnets plus a rim on each side.
function hub_cap_min_hub(magnet, rim = hub_cap_rim) = 2 * magnet_od(magnet) + 2 * rim;

/**
 * @brief The cap, base on z = 0, pockets open at the top
 * @param hub_diameter Diameter of the fan hub, which is also the cap diameter
 * @param magnet Registered magnet row (NopSCADlib), one in each pocket
 * @param rim Wall outside each pocket
 * @param floor Floor under the pockets
 * @param pedestal Extra height under the floor, where the fan is recessed and the cap makes up
 *                 the height
 * @param magnet_allow Diametral allowance on the pocket
 * @param cap Draw the printed disc
 * @param magnets Draw the magnets in place (purchased part)
 */
module magnet_hub_cap(hub_diameter, magnet, rim = hub_cap_rim, floor = hub_cap_floor, magnet_allow = hub_cap_magnet_allow, pedestal = 0, cap = true, magnets = false) {
  _pitch = hub_cap_pitch(hub_diameter, magnet, rim);
  _floor = floor + pedestal;
  _height = hub_cap_height(magnet, _floor);

  assert(
    _pitch > magnet_od(magnet),
    str("magnet_hub_cap: a ", hub_diameter, " mm hub cannot hold two ", magnet_od(magnet), " mm magnets ", rim, " mm in from its edge.")
  );

  if (cap)
    difference() {
      cylinder(d=hub_diameter, h=_height);
      for (s = [-1, 1])
        translate([s * _pitch / 2, 0, _floor])
          cylinder(d=magnet_od(magnet) + magnet_allow, h=magnet_h(magnet) + z_fight);
    }

  if (magnets)
    for (s = [-1, 1])
      translate([s * _pitch / 2, 0, _floor])
        magnet(magnet);
}

magnet_hub_cap(fan_hub(_cap_fan), _cap_magnet, magnets=render_magnets);
