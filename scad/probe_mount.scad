/**
 * @file probe_mount.scad
 * @brief Probe mount for any kind of long cylindrical sensor
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 */

include <_config.scad>;

/**
 * @brief Create a probe mount for a long cylindrical sensor
 * @param diameter The diameter of the sensor
 * @param width The width of the mount
 * @param height The height of the mount
 * @param hole_diameter The diameter of the hole for the sensor
 * @param tolerance The tolerance for the sensor hole
 * @param screw_hole_diameter The diameter of the screw holes
 * @param cut_height The height of the cutout for the sensor
 */
module probe_mount(diameter, width, height, hole_diameter, tolerance, screw_hole_diameter, cut_height)
{
    difference()
    {
        // create mount base
        linear_extrude(height = height) resize([ width, width ]) minkowski()
        {
            square([ width, width ], center = true);
            circle(d = width / 2, $fn = 64);
        }

        // cut mounting hole
        translate([ 0, 0, height - cut_height ]) cylinder(d = diameter + tolerance, h = cut_height + zFite);

        // cut entry hole
        translate([ 0, 0, height / 2 ])
        {
            cylinder(d = hole_diameter + tolerance, h = height + zFite, center = true);
        }

        // cut screw holes
        for (i = [0:3])
        {
            rotate([ 0, 0, i * 90 ])
                translate([ width / 2 - screw_hole_diameter, width / 2 - screw_hole_diameter, height / 2 ])
            {
                cylinder(d = screw_hole_diameter + tolerance, h = height + zFite, center = true);
            }
        }
    }
}