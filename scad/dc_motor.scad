/**
 * @file dc_motor.scad
 * @brief DC motor and gearbox model
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 */

// ---------------------------------
// Global Parameters
// ---------------------------------
$fn = $preview ? 64 : 128;  // number of fragments for circles, affects render time
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview

module dcmotor(diameter, length, shaft_diameter = undef, shaft_length = undef)
{
    union()
    {
        color([ 0.6, 0.6, 0.6 ]) cylinder(d = diameter, h = length);
        if (!is_undef(shaft_diameter) && !is_undef(shaft_length))
            color([ 0.5, 0.5, 0.5 ]) translate([ 0, 0, length ]) cylinder(d = shaft_diameter, h = shaft_length);
    }
}

module gearbox(diameter, length, output_shaft_diameter, output_shaft_length, input_shaft_diameter, input_shaft_length,
               faceplate_screws_cdist, screw_diameter = 5)
{
    cut_dim = screw_diameter * 1.1;

    union()
    {
        difference()
        {
            // gearbox body
            union()
            {
                color([ 0.3, 0.3, 0.3 ]) cylinder(d = diameter, h = length);
                color([ 0.5, 0.5, 0.5 ]) translate([ 0, 0, length ])
                    cylinder(d = output_shaft_diameter, h = output_shaft_length);
            }

            // remove pocket for input shaft
            if (!is_undef(input_shaft_diameter) && !is_undef(input_shaft_length))
                translate([ 0, 0, -zFite ]) color([ 0.3, 0.4, 0.4 ])
                    cylinder(d = input_shaft_diameter, h = input_shaft_length);

            // remove spot where gearbox screws sit
            for (i = [0:3])
            {
                rotate([ 0, 0, i * 90 + 45 ]) translate([ diameter / 2 - cut_dim / 2, 0, length - cut_dim / 2 + zFite ])
                    color([ 0.3, 0.4, 0.4 ]) cube([ cut_dim, cut_dim, cut_dim ], center = true);
            }

            // remove spot where faceplate screw holes
            for (i = [0:3])
            {
                rotate([ 0, 0, i * 90 ])
                    translate([ faceplate_screws_cdist / 2, 0, length - screw_diameter / 2 + zFite ])
                        color([ 0.3, 0.4, 0.4 ]) cylinder(d = screw_diameter, h = screw_diameter * 2, center = true);
            }
        }
        // add the screws
        for (i = [0:3])
        {
            rotate([ 0, 0, i * 90 + 45 ]) translate([ diameter / 2 - cut_dim / 2, 0, length - cut_dim + zFite ])
                color([ 0.4, 0.4, 0.4 ]) screwhead(screw_diameter);
        }
    }
}

module screwhead(diameter)
{
    union()
    {
        cylinder(d = diameter, h = diameter / 2);
        translate([ 0, 0, diameter / 2 ]) scale([ 1, 1, 0.5 ]) sphere(d = diameter);
    }
}