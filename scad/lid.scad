// lid for jar to sit in

// ---------------------------------
// Global Parameters
// ---------------------------------
$fn = $preview ? 32 : 128;  // number of fragments for circles, affects render time
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview

module lid(outer_diameter, inner_diameter, height, tolerance, rod_hole_diameter, nut_dia, nut_h)
{
    difference()
    {

        union()
        {

            cylinder(d = outer_diameter, h = height);
            translate([ 0, 0, height ])
            {
                cylinder(d = inner_diameter - tolerance, h = height);
            }
        }
    }
}