/**
 * @file probe_mount.scad
 * @brief Probe mount for any kind of long cylindrical sensor
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 */

// -----------------
// Global variables
// -----------------
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview
$fn = $preview ? 32 : 128;

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