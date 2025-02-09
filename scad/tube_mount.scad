/**
 * @file tube_mount.scad
 * @brief tube_mount for any kind of long cylindrical sensor
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 */

include <_config.scad>;

/**
 * @brief Create a tube_mount for a long cylindrical sensor
 * @param diameter The diameter of the sensor
 * @param width The width of the mount base
 * @param height The height of the mount base
 * @param hole_diameter The diameter of the hole for the sensor
 * @param allowance The allowance for the sensor hole
 * @param screw_hole_diameter The diameter of the screw holes
 * @param cut_height The height of the cutout for the sensor
 */
module tube_mount(diameter, width, height, hole_diameter, allowance, screw_hole_diameter, cut_height)
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
        translate([ 0, 0, height - cut_height ]) cylinder(d = diameter + allowance, h = cut_height + zFite);

        // cut entry hole
        translate([ 0, 0, height / 2 ])
        {
            cylinder(d = hole_diameter + allowance, h = height + zFite, center = true);
        }

        // cut screw holes
        for (i = [0:3])
        {
            rotate([ 0, 0, i * 90 ])
                translate([ width / 2 - screw_hole_diameter, width / 2 - screw_hole_diameter, height / 2 ])
            {
                cylinder(d = screw_hole_diameter + allowance, h = height + zFite, center = true);
            }
        }
    }
}

example_outer_diamter = 10;
example_inner_diameter = 5;
example_width = 12;
example_height = 10;
example_hole_diameter = 2;
example_allowance = 0.1;
example_screw_hole_diameter = 1;
example_cut_height = 5;

tube_mount(diameter = example_inner_diameter, width = example_width, height = example_height,
           hole_diameter = example_hole_diameter, allowance = example_allowance,
           screw_hole_diameter = example_screw_hole_diameter, cut_height = example_cut_height);