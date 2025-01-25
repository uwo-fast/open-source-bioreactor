/**
 * @file impeller.scad
 * @brief Highly customizable impeller module
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains a customizable impeller module, it was inspired by the following article:
 * https://infinityplays.com/3d-part-design-with-openscad-57-a-universal-propeller-impeller-design-module/.
 *
 *
 */

include <_config.scad>;

/**
 * Module: impeller
 *
 * Generates a 3D impeller model with customizable parameters.
 *
 * Parameters:
 *   radius (float): The radius of the impeller.
 *   height (float): The height of the impeller.
 *   fins (int): The number of fins on the impeller.
 *   twist (float): The twist angle of each fin.
 *   fin_scale (vector, default=[1,2,0.2]): Scale factors for the fins.
 *   fin_rotate (vector, default=[0,0,120]): Rotation angles for the fins.
 *   fin_width (float, default=1): The width of each fin blade.
 *   center_hub_radius (float, default=25): The size of the center hub.
 *   center_hub_type (string, default="sphere"): Type of the center hub (sphere or cylinder).
 *   center_hole_size (float, default=5): The size of the center hole.
 *   hub_scale (vector, default=[1,1,1]): Scale factors for the center hub.
 *   hub_fn (int, default=$fn): The number of facets for the center hub.
 *
 * Description:
 *   This module generates a 3D impeller model with customizable parameters.
 *   The impeller is composed of multiple fins, a center hub, and a center hole.
 *   Each fin is twisted and scaled according to the provided parameters.
 *   The center hub is scaled and positioned at the center of the impeller.
 *   The center hole is subtracted from the impeller to create a hollow effect.
 */
module impeller(radius, height, fins, twist, fin_width = 1, center_hub_radius = 25, center_hole_size = 5,
                center_hub_type = "cylinder", fin_scale = [ 1, 1, 1 ], fin_rotate = [ 0, 0, 0 ],
                hub_scale = [ 1, 1, 1 ], round = false, hub_fn = 64)
{
    difference()
    {
        union()
        {
            // Loop through each fin
            for (i = [1:fins])
            {
                rotate([ 0, 0, (360 / fins) * i ])
                    // Scale and extrude the fin blade
                    scale(fin_scale) resize([ radius, radius, height ]) intersection()
                {
                    translate([ 0, 0, -radius / 2 ]) linear_extrude(radius, twist = twist, slices = 360, convexity = 10)
                        rotate(fin_rotate) square([ radius, fin_width ], center = false);
                    if (round)
                        sphere(d = radius, $fn = 128);
                }
            }
            // Create the center hub
            scale(hub_scale)
            {
                if (center_hub_type == "cylinder")
                    resize([ center_hub_radius * 2, center_hub_radius * 2, height ])
                        cylinder(r = center_hub_radius, h = radius, center = true, $fn = hub_fn);
                else if (center_hub_type == "sphere")
                    scale([ 1, 1, radius / (center_hub_radius) ]) sphere(r = center_hub_radius, $fn = hub_fn);
                else
                    echo("Invalid center_hub_type: ", center_hub_type);
            }
        }
        // Subtract the center hole
        cylinder(r = center_hole_size, h = height * 2, center = true);
    }
}

// Example call to the impeller module with required parameters and some default values
// impeller(radius = 80, height = 50, fins = 6, twist = 90, fin_width = 1, center_hub_radius = 20);

// Example call to the impeller module with all parameters specified
impeller(radius = 80, height = 50, fins = 6, twist = 90, fin_width = 1, center_hub_radius = 10, center_hole_size = 5,
         center_hub_type = "cylinder", fin_scale = [ 1, 1, 1 ], fin_rotate = [ 0, 0, 120 ], hub_scale = [ 1, 1, 1 ],
         round = false, hub_fn = 128);