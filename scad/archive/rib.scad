module rib(inner_diameter, height, wall_thickness, rod_hole_diameter, light_depth, light_width, light_allow, rods = undef)
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
                        cube([ light_depth * 2 + light_allow, light_width + light_allow, height + zFite ], center = true);
                }
            }
        }
    }
}