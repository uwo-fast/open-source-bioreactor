// lid for jar to sit in

zFite = $preview ? 0.1 : 0; // z-fighting avoidance

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