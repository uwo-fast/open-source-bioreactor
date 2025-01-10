// base for jar to sit in

zFite = $preview ? 0.1 : 0; // z-fighting avoidance

module base(inner_diameter, height, wall_thickness, floor_height, rod_hole_diameter, nut_dia, nut_h)
{

    difference()
    {

        union()
        {

            cylinder(d = inner_diameter + wall_thickness, h = height);

            for (i = [0:3])
            {
                rotate([ 0, 0, i * 90 ])
                {
                    translate([ inner_diameter / 2, 0, height / 2 ])
                    {
                        cylinder(d = rod_hole_diameter * 4, h = height, center = true);
                    }
                }
            }
        }
        for (i = [0:3])
        {
            rotate([ 0, 0, i * 90 ])
            {
                translate([ inner_diameter / 2, 0, height / 2 ])
                {
                    translate([ rod_hole_diameter, 0, 0 ])
                    {
                        cylinder(d = rod_hole_diameter, h = height + zFite, center = true);
                    }
                    translate([ rod_hole_diameter, 0, -height / 2 - zFite ])
                    {
                        cylinder(d = nut_dia, h = nut_h + zFite, $fn = 6);
                    }
                }
            }
        }
        translate([ 0, 0, floor_height ])
        {
            cylinder(d = inner_diameter, h = height - floor_height + zFite);
        }
        translate([ 0, 0, -zFite / 2 ])
        {
            cylinder(d = inner_diameter - 20, h = height + zFite);
        }
    }
}