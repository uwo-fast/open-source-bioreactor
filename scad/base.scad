/**
 * @file base.scad
 * @brief Base for holding a jar or other cylindrical object
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains the base for holding a jar or other cylindrical object.
 *
 */

// ---------------------------------
// Global Parameters
// ---------------------------------
$fn = $preview ? 32 : 128;  // number of fragments for circles, affects render time
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview

// a:angle, d:diameter, h:height, center: center

/**
 * @brief Generates a "3D pie slice" shape, better thought of as a cylinder with an adjustable angle.
 *
 * @param a The angle of the pie slice.
 * @param d The diameter of the pie slice.
 * @param h The height of the pie slice.
 * @param center Whether the pie slice should be centered.
 */
module pieSlice(a, d, h, center = false)
{
    translate([ 0, 0, (center ? -h / 2 : 0) ]) rotate_extrude(angle = min(a, 360)) square([ d / 2, h ]);
}

/**
 * @brief Generates a base for holding a jar or other cylindrical object.
 *
 * @param inner_diameter The inner diameter of the base.
 * @param height The height of the base.
 * @param wall_thickness The thickness of the base walls.
 * @param floor_height The height of the base floor.
 * @param rod_hole_diameter The diameter of the hole for rods.
 * @param nut_dia The diameter of the nuts.
 * @param nut_h The height of the nuts.
 * @param rods The number of rods [2:4]; if not defined, 4 rods are rendered and the final quadrant closed.
 */
module base(inner_diameter, height, wall_thickness, floor_height, rod_hole_diameter, nut_dia = undef, nut_h = undef,
            rods = undef)
{
    rod_holder_dia = rod_hole_diameter * 4;

    extra_angle = 0*atan((rod_holder_dia / 2) / (inner_diameter + wall_thickness * 3));
    n_rods = is_undef(rods) ? 4 : rods;
    angle = is_undef(rods) ? 360 : (n_rods - 1) * 90 + 2 * extra_angle;
    assert(!(n_rods < 2 || n_rods > 4), "Invalid number of rods. Must be between 2 and 4.");

    difference()
    {
        union()
        {

            // Generate the base
            rotate([ 0, 0, -extra_angle ]) pieSlice(a = angle, d = inner_diameter + wall_thickness, h = height);

            // Generate the rod supports
            for (i = [0:n_rods - 1])
            {
                rotate([ 0, 0, i * 90 ])
                {
                    translate([ inner_diameter / 2, 0, height / 2 ])
                    {
                        cylinder(d = rod_holder_dia, h = height, center = true);
                    }
                }
            }
        }

        // Generate the rod holes
        for (i = [0:n_rods - 1])
        {
            rotate([ 0, 0, i * 90 ])
            {
                translate([ inner_diameter / 2, 0, height / 2 ])
                {
                    translate([ rod_hole_diameter, 0, 0 ])
                    {
                        cylinder(d = rod_hole_diameter, h = height + zFite, center = true);
                    }
                    if (!is_undef(nut_dia) && !is_undef(nut_h))
                    {
                        translate([ rod_hole_diameter, 0, -height / 2 - zFite ])
                        {
                            rotate([ 0, 0, 30 ]) cylinder(d = nut_dia, h = nut_h + zFite, $fn = 6);
                        }
                    }
                }
            }
        }

        // Cut out spot for the jar
        translate([ 0, 0, floor_height ])
        {
            cylinder(d = inner_diameter, h = height - floor_height + zFite);
        }

        // Cut out spot for the floor
        translate([ 0, 0, -zFite / 2 ])
        {
            cylinder(d = inner_diameter - wall_thickness * 2, h = height + zFite);
        }
    }
}

module rib(inner_diameter, height, wall_thickness, rod_hole_diameter, light_depth, light_width, light_tol, rods = undef)
{

    difference()
    {
        f_height = -zFite;
        base(inner_diameter = inner_diameter, height = height, wall_thickness = wall_thickness, floor_height = f_height,
             rod_hole_diameter = rod_hole_diameter, rods = rods);

        for (i = [1:rods - 1])
        {
            rotate([ 0, 0, (i - 1) * 90 ])

                for (j = [1:3])
            {
                rotate([ 0, 0, j * 90 / 4 ])
                {
                    translate([ inner_diameter / 2, 0, height / 2 ]) 
                        cube([ light_depth * 2 + light_tol, light_width + light_tol, height + zFite ], center = true);
                }
            }
        }
    }
}