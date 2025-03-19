/**
 * @file tube_mount.scad
 * @brief tube_mount for any kind of long cylindrical sensor
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 */

include <_config.scad>;

/**
 * @brief Create a tube_mount for a flexible tube
 * @param width The width of the mount
 * @param height The height of the mount
 * @param hole_diameter The diameter of the hole for the tube
 * @param hole_taper The amount by which the hole diameter is tapers inwards for a snug fit of a tube
 * @param allowance The amount of space to allow for the tube to fit
 * @param screw_hole_diameter The diameter of the screw holes
 */
module tube_mount(width, height, hole_diameter, hole_taper, tube_allowance, screw_hole_diameter, screw_allowance,
                  neck_diameter = undef, neck_height = undef, neck_taper = undef)
{
    difference()
    {
        // create mount base
        union()
        {
            // rounded square, TODO: REMOVE DEPENDENCE ON RESIZE
            linear_extrude(height = height) resize([ width, width ]) minkowski()
            {
                square([ width, width ], center = true);
                circle(d = width / 2, $fn = 64);
            }

            // create optional neck
            if (!is_undef(neck_diameter) && !is_undef(neck_height) && !is_undef(neck_taper))
            {
                translate([ 0, 0, neck_height / 2 + height ])
                    cylinder(d1 = neck_diameter, d2 = neck_diameter - neck_taper, h = neck_height, center = true);
            }
        }

        neck_z_shift = is_undef(neck_height) ? 0 : neck_height;

        // cut center hole
        translate([ 0, 0, height / 2 ])
        {
            cylinder(d2 = hole_diameter + tube_allowance, d1 = hole_diameter + tube_allowance - hole_taper,
                     h = (height + neck_z_shift) * 2, center = true);
        }

        // cut screw holes
        for (i = [0:3])
        {
            rotate([ 0, 0, i * 90 ])
                translate([ width / 2 - screw_hole_diameter * 1.5, width / 2 - screw_hole_diameter * 1.5, height / 2 ])
            {
                cylinder(d = screw_hole_diameter + screw_allowance, h = height + zFite, center = true);
            }
        }
    }
}

// Diameter of the center through hole
example_hole_diameter = 4;

// The amount by which the hole diameter is tapers inwards for a snug fit of a tube
example_hole_hole_taper = 0.2;

// Width of the mount
example_width = 20;

// Height of the mount
example_height = 2;

// Amount of space to allow to create a clearance for the tube
example_tube_allowance = 0.05;

// Diameter of the 4 corner screw holes
example_screw_hole_diameter = 2.2;

//  Amount of space to allow for the screw holes
example_screw_allowance = 0.2;

// Diameter of the neck
example_neck_diameter = 8;

// Height of the neck
example_neck_height = 3;

// Amount by which the neck outer surface tapers
example_neck_taper = 1;

tube_mount(example_width, example_height, example_hole_diameter, example_hole_hole_taper, example_tube_allowance,
           example_screw_hole_diameter, example_screw_allowance, neck_diameter = example_neck_diameter,
           neck_height = example_neck_height, neck_taper = example_neck_taper);