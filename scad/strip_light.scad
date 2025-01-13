/**
 * @file strip_light.scad
 * @brief Creates a strip grow light for the open-source-bioreactor project
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains the strip light module for the open-source-bioreactor project.
 *
 */

module strip_light(width, depth, length, radius)
{
    union()
    {
        translate([ -width / 2, 0, 0 ]) color("silver") cube([ width, depth, length ]);
        color("yellow", alpha = 0.3) resize([ width, radius, length ]) difference()
        {
            cylinder(h = length, d = width);
            translate([ -width / 2, 0, 0 ]) cube([ width, depth, length ]);
        }
    }
}