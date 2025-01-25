/**
 * @file strip_light.scad
 * @brief Creates a strip grow light for the open-source-bioreactor project
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains the strip light module for the open-source-bioreactor project.
 *
 */

include <_config.scad>;

/**
 * @brief Creates a strip light
 * @param width The width of the strip light
 * @param depth The depth of the strip light
 * @param length The length of the strip light
 * @param radius The radius of the curved front of the strip light
 */
module strip_light(width, depth, length, radius = undef)
{
    union()
    {
        // Create the main body of the strip light
        translate([ -width / 2, 0, 0 ]) color("silver") cube([ width, depth, length ]);

        if (!is_undef(radius)) // If the radius is defined, create a curved front
            color("yellow", alpha = 0.3) resize([ width, radius, length ]) difference()
            {
                cylinder(h = length, d = width);
                translate([ -width / 2, 0, 0 ]) cube([ width, depth, length ]);
            }
    }
}

/**
 * @brief Creates a circular pattern of children around the z-axis
 * @param a Angle between each child
 * @param n Number of children
 * @param r Radius of the circle
 * @param offset Offset of the first child
 */
module circular_pattern(a, n, r, offset, center = false)
{
    c = center ? -a / n : 0;
    for (i = [0:n - 1])
    {
        rotate([ 0, 0, i * a / n + offset + c ])
        {
            translate([ 0, r, 0 ]) children();
        }
    }
}

/**
 * @brief Circular pattern of lights
 * @param light_dims dimensions of the light module [width, depth, length, radius]
 * @param a angle to occupy
 * @param n number of lights to place
 * @param r radius of the circular placement
 * @param offset angular offset of the first module
 * @param center angular centering of the modules
 */
module surround_lights(light_dims, angle, n, r, offset, center)
{
    circular_pattern(a = angle, n = n, r = r, offset = offset, center = center)
        strip_light(width = light_dims[0], depth = light_dims[1], length = light_dims[2], radius = light_dims[3]);
}