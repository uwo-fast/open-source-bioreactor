// Impeller Module
// Inspired by: https://infinityplays.com/3d-part-design-with-openscad-57-a-universal-propeller-impeller-design-module/
// Redone and optimized by: Cameron K. Brooks 2024

/**
 * Module: impeller
 *
 * Generates a 3D impeller model with customizable parameters.
 *
 * Parameters:
 *   radius (float): The radius of the impeller.
 *   fins (int): The number of fins on the impeller.
 *   twist (float): The twist angle of each fin.
 *   fin_scale (vector, default=[1,2,0.2]): Scale factors for the fins.
 *   fin_rotate (vector, default=[0,0,120]): Rotation angles for the fins.
 *   fin_blade_width (float, default=1): The width of each fin blade.
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
module impeller(radius, height_impeller, fins, twist, fin_scale = [ 1, 2, 0.2 ], fin_rotate = [ 0, 0, 120 ], fin_blade_width = 1,
                round = false, center_hub_radius = 25, center_hub_type = "sphere", center_hole_size = 5,
                hub_scale = [ 1, 1, 1 ], hub_fn = $fn)
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
                    scale(fin_scale) resize([ radius, radius, height_impeller ]) intersection()
                {
                    translate([ 0, 0, -radius / 2 ]) linear_extrude(radius, twist = twist, slices = 360, convexity = 10)
                        rotate(fin_rotate) square([ radius, fin_blade_width ], center = false);
                    if (round)
                        sphere(d = radius, $fn = 100);
                }
            }
            // Create the center hub
            scale(hub_scale)
            {
                if (center_hub_type == "cylinder")
                    resize([ center_hub_radius * 2, center_hub_radius * 2, height_impeller ])
                        cylinder(r = center_hub_radius, h = radius, center = true, $fn = hub_fn);
                else if (center_hub_type == "sphere")
                    scale([ 1, 1, radius / (center_hub_radius) ]) sphere(r = center_hub_radius, $fn = hub_fn);
                else
                    echo("Invalid center_hub_type: ", center_hub_type);
            }
        }
        // Subtract the center hole
        cylinder(r = center_hole_size, h = height_impeller * 2, center = true);
    }
}

// Example call to the impeller module with required parameters and some default values
// impeller(radius = 80, fins = 6, twist = 90);

// Example call to the impeller module with all parameters specified
// impeller(radius = 80, fins = 6, twist = 120, fin_scale = [1, 1.88, 0.17], fin_rotate = [0, 66.15, 123.39],
//        fin_blade_width = 1, center_hub_radius = 22.26, center_hole_size = 5,
//        hub_scale = [1, 1, 1.25], hub_fn = 8);

$fn = $preview ? 16 : 64;

zFite = $preview ? 0.1 : 0; // z-fighting avoidance

// Design parameter guidelines for impeller:
// - The impeller radius (radius) should be 1/3 to 1/2 of the tank radius for bioreactors
// - The number of fins (fins) and their twist angle (twist) influence mixing efficiency, flow patterns, and shear forces. 
//   More fins generally increase turbulence and mixing but may require higher power input. 
//   Twist angle adjusts the direction and intensity of flow, with higher angles promoting axial flow and lower angles favoring radial flow.
//   Choose values based on the viscosity of the fluid, required mixing intensity, and sensitivity of the culture to shear forces.


tank_diameter = 220 - 2 * 5;
impeller_DT_factor = 0.45;
impeller_diameter = tank_diameter * impeller_DT_factor;
impeller_radius = impeller_diameter / 2;

echo("Impeller radius: ", impeller_radius);

n_fins = 4;
twist_ang = 55;
blade_wid = 4;

height_impeller = 60;

scale_fins = [ 1, 1, 1 ];
scale_hub = [ 1, 1, 1 ];
rotate_fins = [ 0, 0, 0 ];

hub_rad = 7.5;
hole_rad = 4.3;
hub_type = "cylinder";

round_fins = false;

translate([ 0, 0, height_impeller / 2 ]) union()
{
    impeller(radius = impeller_radius, height_impeller = height_impeller, fins = n_fins, twist = twist_ang, fin_scale = scale_fins,
             fin_rotate = rotate_fins, fin_blade_width = blade_wid, round = round_fins, center_hub_radius = hub_rad,
             center_hub_type = hub_type, center_hole_size = hole_rad, hub_scale = scale_hub, hub_fn = 32);

    translate([ 0, 0, height_impeller / 2 - blade_wid / 2 ]) linear_extrude(blade_wid, center = true) difference()
    {
        circle(r = impeller_radius + blade_wid, $fn = 64);
        circle(r = impeller_radius , $fn = 64);
    }
}