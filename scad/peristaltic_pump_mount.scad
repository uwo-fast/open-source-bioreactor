/**
 * @file peristaltic_pump_mount.scad
 * @brief Peristaltic pump mount
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains a mount for holding and fixing a peristaltic pump in place by its base. The mount is
 * derived/inspired by a model found on printables.com: https://www.printables.com/model/857120-peristaltic-pump-mount.
 * Notable changes include the addition of a z-fighting avoidance, modularization, documentation/readability, and a
 * reduction in the number of parameters.
 */

// -----------------
// Global variables
// -----------------
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview
$fn = $preview ? 32 : 128;

module peri_mount(inner_diameter, outer_diameter, body_height, base_mount_height, base_mount_scale, pump_mount_height,
                  pump_mount_scale, mount_width, base_bore_distance, pump_thread_diameter, pump_bore_diatance,
                  base_thread_diameter, base_head_diameter, body_opening = undef)
{
    body_opening = is_undef(body_opening) ? [ inner_diameter, inner_diameter, outer_diameter ] : body_opening;
    difference()
    {
        union()
        {
            // body
            cylinder(d = outer_diameter, h = body_height);

            // pump mounts
            translate([ 0, 0, body_height ]) rotate([ 0, 180, 0 ])
                mounts(pump_mount_height, pump_thread_diameter, pump_thread_diameter, pump_bore_diatance, mount_width,
                       pump_mount_scale);
            // base mounts
            rotate([ 0, 0, 45 ])
            {
                mounts(base_mount_height, base_thread_diameter, base_head_diameter, base_bore_distance, mount_width,
                       base_mount_scale);
            }
            rotate([ 0, 0, -45 ])
            {
                mounts(base_mount_height, base_thread_diameter, base_head_diameter, base_bore_distance, mount_width,
                       base_mount_scale);
            }
        }

        // body_opening in the middle
        translate([ 0, 0, -zFite / 2 ]) cylinder(d = inner_diameter, h = body_height + zFite);

        // body_opening on the sides
        rotate([ 0, 90, 0 ]) resize(body_opening)
        {
            cylinder(d = body_opening, h = outer_diameter, center = true);
        }
        rotate([ 0, 90, 90 ]) resize(body_opening)
        {
            cylinder(d = body_opening, h = outer_diameter, center = true);
        }
    }
}

module mounts(mount_height, bore1, bore2, base_bore_distance, mount_width, scale = 1)
{
    bore2Ratio = -0.45 * scale + 0.95;
    difference()
    {
        // mounts
        linear_extrude(height = mount_height, scale = scale) union()
        {
            translate([ base_bore_distance / 2, 0, 0 ]) circle(d = mount_width);
            translate([ -base_bore_distance / 2, 0, 0 ]) circle(d = mount_width);
            square([ base_bore_distance, mount_width ], center = true);
        }

        // bore holes
        for (i = [0:1])
        {
            mirror([ i, 0, 0 ]) translate([ base_bore_distance / 2, 0, -zFite / 2 ]) union()
            {
                cylinder(d = bore1, h = mount_height + zFite);
                translate([ 0, 0, mount_height * bore2Ratio + zFite ])
                {
                    cylinder(d = bore2, h = mount_height * bore2Ratio + zFite);
                }
            }
        }
    }
}

// ------------------------
// User defined parameters
// ------------------------

body_thickness = 3; // thickness of the body; this is largely arbitrary just dont make it too thin or it will be weak
// and too thick and it will be heavy/wasteful
body_height = 50; // height of the body; this is the motor body length measured from the faceplate to base with some
// extra to let terminals out
inner_diameter = 30; // inner diameter of the body; this is the measurement of your pumps diameter
outer_diameter =
    inner_diameter + body_thickness; // outer diameter of the body; this is the outside diameter of the body

// based on the desired attachment point of the pump
base_mount_height = 5;         // height of the base mount
base_screw_distance = 45;      // distance between the screw holes on the base of the pump
base_screwhead_diameter = 5.4; // diameter of the screw head on the base of the pump
base_thread_diameter = 3.5;    // diameter of the screw thread on the base of the pump
base_mount_taper_scale = 0.95; // 1 is no taper (square edges), 0 is a lot of taper (fully smoothed); this is
// superficial and can be changed to your liking

// based on the faceplate of the pump
faceplate_mount_height = 20; // height of the faceplate mount
faceplate_screw_distance = 47.5;
faceplate_thread_diameter = 3;
faceplate_mount_taper_scale =
    0.50; // for printing keep 0.5 - 1 as 0.5 results in 45 degree taper, 1 results in no taper

mounts_width =
    base_screwhead_diameter *
    2; // width of the mounting bars; largely arbitrary, must be greater than mounting holes, ideally 2*screwhead

// -----------------
// Calculated values
// -----------------
// TODO: should really be changed to a function of the pump ID
body_opening_dim = (inner_diameter) / 2;
body_opening = [ body_opening_dim * 4, body_opening_dim, outer_diameter ];

peri_mount(inner_diameter = inner_diameter, outer_diameter = outer_diameter, body_height = body_height,
           base_mount_height = base_mount_height, base_mount_scale = base_mount_taper_scale,
           pump_mount_height = faceplate_mount_height, pump_mount_scale = faceplate_mount_taper_scale,
           mount_width = mounts_width, base_bore_distance = base_screw_distance,
           pump_thread_diameter = faceplate_thread_diameter, pump_bore_diatance = faceplate_screw_distance,
           base_thread_diameter = base_thread_diameter, base_head_diameter = base_screwhead_diameter,
           body_opening = body_opening);

// cube([outer_diameter, outer_diameter, body_height], center = true);