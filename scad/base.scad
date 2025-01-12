// base for jar to sit in

zFite = $preview ? 0.1 : 0; // z-fighting avoidance
module pieSlice(a, d, h, center = false)
{
    // a:angle, d:diameter, h:height, center: center
    translate([ 0, 0, (center ? -h / 2 : 0) ]) rotate_extrude(angle = min(a, 360)) square([ d / 2, h ]);
}

module base(inner_diameter, height, wall_thickness, floor_height, rod_hole_diameter, nut_dia = undef, nut_h = undef,
            rods = undef)
{
    extra_angle = atan((rod_hole_diameter * 4) / (inner_diameter + wall_thickness));
    n_rods = is_undef(rods) ? 4 : rods;
    angle = is_undef(rods) ? 360 : (n_rods - 1) * 90 + 2 * extra_angle;

    difference()
    {

        union()
        {
            rotate([ 0, 0, -extra_angle ]) pieSlice(a = angle, d = inner_diameter + wall_thickness, h = height);

            for (i = [0:n_rods - 1])
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