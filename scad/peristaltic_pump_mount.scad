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

/**
 * @brief Generates a mount for holding and fixing a peristaltic pump in place by its base.
 *
 * @param inner_diameter The inner diameter of the body.
 * @param outer_diameter The outer diameter of the body.
 * @param body_height The height of the body.
 * @param base_mount_height The height of the base mount.
 * @param base_mount_scale The scale of the base mount taper.
 * @param pump_mount_height The height of the pump mount.
 * @param pump_mount_scale The scale of the pump mount taper.
 * @param mount_width The width of the mounting bars.
 * @param base_bore_distance The distance between the screw holes on the base of the pump.
 * @param pump_thread_diameter The diameter of the screw thread on the base of the pump.
 * @param pump_bore_diatance The distance between the screw holes on the faceplate of the pump.
 * @param base_thread_diameter The diameter of the screw thread on the base of the pump.
 * @param base_head_diameter The diameter of the screw head on the base of the pump.
 * @param body_opening The opening of the body.
 */
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

/**
 * @brief Generates a mount for holding and fixing the pump to the holder and the holder to the mount surface.
 *
 * @param mount_height The height of the mount.
 * @param bore1 The diameter of the first bore hole.
 * @param bore2 The diameter of the second bore hole.
 * @param base_bore_distance The distance between the bore holes.
 * @param mount_width The width of the mounting bars.
 * @param scale The scale of the mount taper.
 */
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
