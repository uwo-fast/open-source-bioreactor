// base for jar to sit in

module base(inner_diameter, base_height, base_wall_thickness, floor_height, rod_diameter, nut_diameter, nut_height)
{

    difference()
    {

        union()
        {

            cylinder(d = jar_diameter + base_wall_thickness, h = base_height);

            for (i = [0:3])
            {
                rotate([ 0, 0, i * 90 ])
                {
                    translate([ jar_diameter / 2, 0, base_height / 2 ])
                    {
                        difference()
                        {

                            cylinder(d = rod_diameter * 4, h = base_height, center = true);

                            translate([ rod_diameter, 0, 0 ])
                            {
                                cylinder(d = rod_diameter, h = base_height + zFite, center = true);
                            }
                            translate([ rod_diameter, 0, -(base_height + zFite - nut_height) ])
                            {
                                cylinder(d = nut_diameter, h = nut_height + zFite, $fn = 6);
                            }
                        }
                    }
                }
            }
        }
        translate([ 0, 0, floor_height ])
        {
            cylinder(d = jar_diameter, h = base_height - floor_height + zFite);
        }
        translate([ 0, 0, -zFite / 2 ])
        {
            cylinder(d = jar_diameter - 20, h = base_height + zFite);
        }
    }
}

$fn = 64;

zFite = 0.1; // z-fighting avoidance

jar_diameter = 300;
height = 20;
wall_thickness = 8;
floor_h = 5;
rod_dia = 10;
nut_dia = rod_dia * 1.5;
nut_h = 5;

base(inner_diameter = jar_diameter, base_height = height, base_wall_thickness = wall_thickness, floor_height = floor_h,
     rod_diameter = rod_dia, nut_diameter = nut_dia, nut_height = nut_h);