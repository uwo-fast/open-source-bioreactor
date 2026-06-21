/**
 * @file strip_light.scad
 * @brief Creates a strip grow light for the open-source-bioreactor project
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * This file contains the strip light module for the open-source-bioreactor project.
 *
 */

z_fight = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

function strip_light_width(type) = type[1][0];  // width of the strip light
function strip_light_depth(type) = type[1][1];  // depth of the strip light
function strip_light_length(type) = type[1][2]; // length of the strip light
function strip_light_radius(type) = type[1][3]; // radius of the curved front, optional

/**
 * @brief Creates a strip light from a registered type
 * @param type Registered parameter set (see strip_lights.scad)
 */
module strip_light(type) {
  width = strip_light_width(type);
  depth = strip_light_depth(type);
  length = strip_light_length(type);
  radius = strip_light_radius(type);

  union() {
    // Create the main body of the strip light
    translate([-width / 2, 0, 0]) color("silver") cube([width, depth, length]);

    if (!is_undef(radius)) // If the radius is defined, create a curved front
    color("yellow", alpha=0.3) resize([width, radius, length]) difference() {
          cylinder(h=length, d=width);
          translate([-width / 2, 0, 0]) cube([width, depth, length]);
        }
  }
}
