use <base.scad>;
use <jar.scad>;

use <threads-scad/threads.scad>;

// vars for jar
jar_height = 305;
jar_diameter = 220;
jar_thickness = 5;

jar_upper_corner_radius = 25;
jar_corner_radius_base = 12.5;

jar_neck_height = 25;
jar_neck_corner_radius = 12.5;

jar_punt_height = 5;
jar_punt_width = 30;

jar_rim_rad = 2;

corner_Fn = 64;
rot_Extrude_Fn = 64;

// ECHO: "opening_diameter: ", 145
opening_diameter = 145;

$fn = 64;

// vars for base
base_jar_fit_tol = 0.4;
base_cut_diameter = jar_diameter + base_jar_fit_tol;
base_height = 20;
base_wall_thickness = 8;
base_floor_height = 5;

// vars for threaded rods
threaded_rod_diameter = 8.5;
threaded_rod_hole_tolerance = 0.2;
threaded_rod_hole_diameter = threaded_rod_diameter + threaded_rod_hole_tolerance;
// size 6 nut is 14.5mm
nut_diameter = threaded_rod_diameter * 1.7; // typically: diameter * [1.4:1.8]
nut_height = 5;
show_threads = false;

translate([ 0, 0, base_floor_height ])

    jar(jar_height, jar_diameter, jar_thickness, jar_upper_corner_radius, jar_corner_radius_base, jar_neck_height,
        jar_neck_corner_radius, jar_punt_height, jar_punt_width, jar_rim_rad, corner_Fn, rot_Extrude_Fn);

color("DarkViolet") base(inner_diameter = base_cut_diameter, height = base_height, wall_thickness = base_wall_thickness,
                         floor_height = base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter,
                         nut_dia = nut_diameter, nut_h = nut_height);

top_base_height = base_height / 2;
top_base_floor_height = base_floor_height;

translate([ 0, 0, jar_height + base_floor_height + top_base_height ]) rotate([ 0, 180, 0 ]) color("DarkViolet")
    base(inner_diameter = base_cut_diameter, height = top_base_height, wall_thickness = base_wall_thickness,
         floor_height = top_base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter, nut_dia = 1,
         nut_h = nut_height);

rod_length = jar_height + base_floor_height + top_base_height + nut_height;

// threaded rods
for (i = [0:3])
{
    rotate([ 0, 0, i * 90 ])
    {
        translate([ base_cut_diameter / 2 + threaded_rod_hole_diameter, 0, 0 ])
        {
            if (show_threads)
            {
                color("grey") ScrewThread(outer_diam = threaded_rod_diameter, height = rod_length);
            }
            else
            {
                color("grey") cylinder(d = threaded_rod_diameter, h = rod_length);
            }
        }
    }
}