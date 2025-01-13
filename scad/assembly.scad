/**
 * @file assembly.scad
 * @brief Assembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains the assembly for the open-source-bioreactor project.
 *
 */

// project libs
use <base.scad>;
use <impeller.scad>;
use <jar.scad>;
use <lid.scad>;
use <strip_light.scad>;

// helper libs
use <utils.scad>;

// external libs (must reside in your library path)
use <threads-scad/threads.scad>;

// ---------------------------------
// Global Parameters
// ---------------------------------
$fn = $preview ? 32 : 128;  // number of fragments for circles, affects render time
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview

// ---------------------------------
// Jar Parameters
// ---------------------------------
// body
jar_height = 305;
jar_diameter = 220;
jar_thickness = 5;

// corners
jar_upper_corner_radius = 25;
jar_lower_corner_radius = 12.5;

// neck
jar_neck_height = 25;
jar_neck_corner_radius = 13.5;

// punt
jar_punt_height = 5;
jar_punt_width = 30;

// rim
jar_rim_rad = 2;

// corner and extrude fn (smoothness)
corner_Fn = 64;
rot_Extrude_Fn = 64;

// Real life the opening diameter is 143mm
// ECHO: "jar opening_diameter: ", 143
// Note that for a given jar_diameter, the opening_diameter
// is a function of jar_upper_corner_radius and jar_neck_corner_radius
// these vars can be tweaked to get the desired opening_diameter
// TODO: alter jar.scad so that it accepts a combination of opening_diameter
// and one of jar_upper_corner_radius or jar_neck_corner_radius
opening_diameter = 143;

// ---------------------------------
// Base Parameters
// ---------------------------------
base_jar_fit_tol = 0.4;
base_jar_cut_diameter = jar_diameter + base_jar_fit_tol;
base_wall_thickness = 6;
base_floor_height = base_wall_thickness / 2;
base_height = 25;

top_base_height = base_height / 2;

// ---------------------------------
// But & Rod Parameters
// ---------------------------------
// threaded rod
threaded_rod_diameter = 8.5;
threaded_rod_hole_tolerance = 0.2;
threaded_rod_hole_diameter = threaded_rod_diameter + threaded_rod_hole_tolerance;
// nut is size 6  (d=14.5mm)
nut_diameter = threaded_rod_diameter * 1.8; // typically: diameter * [1.4:1.8]
nut_height = 7;

// ---------------------------------
// Lid Parameters
// ---------------------------------
lid_rad_tol = 0.4;
lid_h_tol = 0.2;
bearing_diameter = 22.6;
bearing_height = 5;

// ---------------------------------
// Light Parameters
// ---------------------------------
// size of the light
light_length = 336;
light_width = 14.1;
light_depth = 9;
light_window_radius = 0.5;

// patterning of lights
number_of_lights = 6;
occupy_angle = 90;

// ---------------------------------
// Motor & Shaft Parameters
// ---------------------------------
shaft_length = 300;
shaft_diameter = 8.0;
motor_diameter = 34.5;
motor_height = 59;

// ---------------------------------
// Impeller Parameters
// ---------------------------------

/** Design guidelines for impeller:
 * - The impeller radius (radius) should be 1/3 to 1/2 of the tank radius for bioreactors
 * - The number of fins (fins) and their twist angle (twist) influence mixing efficiency, flow patterns, and shear
 * forces.
 *   More fins generally increase turbulence and mixing but may require higher power input.
 *   Twist angle adjusts the direction and intensity of flow, with higher angles promoting axial flow and lower angles
 *   favoring radial flow. Choose values based on the viscosity of the fluid, required mixing intensity, and sensitivity
 *   of the culture to shear forces.
 */

impeller_DT_factor = 0.45; // impeller diameter to tank diameter ratio
impeller_diameter = jar_diameter * impeller_DT_factor;
impeller_radius = impeller_diameter / 2; // impeller radius
echo("Impeller radius: ", impeller_radius);
impeller_height = 60;      // impeller height
impeller_n_fins = 4;       // number of fins
impeller_twist_ang = 55;   // twist angle of each fin
impeller_fin_width = 4;    // width of each fin blade
impeller_hub_radius = 7.5; // size of the center hub
impeller_shaft_tol = 0.2;  // tolerance for the shaft hole
impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_tol) / 2;

// ---------------------------------
// Control Parameters
// ---------------------------------
// vizualization control
jar_x_sec = true;
show_threads = false;
// render control
render_jar = true;
render_base = true;
render_top_base = false;
render_rods = false;
render_lid = false;
render_ribs = true;
render_lights = false;
render_motor = false;
render_impeller = false;

// jar
if (render_jar)
{
    translate([ 0, 0, base_floor_height ])
        jar(height = jar_height, diameter = jar_diameter, thickness = jar_thickness,
            corner_radius = jar_upper_corner_radius, corner_radius_base = jar_lower_corner_radius,
            neck = jar_neck_height, neck_corner_radius = jar_neck_corner_radius, punt_height = jar_punt_height,
            punt_width = jar_punt_width, rim_rad = jar_rim_rad, arcFn = corner_Fn, rotExtFn = rot_Extrude_Fn,
            show_pts = false, show_2d = false, show_3d = true, pts_r = 1, angle = (jar_x_sec ? 180 : 360));
}

// base
if (render_base)
{
    color("DarkViolet")
        base(inner_diameter = base_jar_cut_diameter, height = base_height, wall_thickness = base_wall_thickness,
             floor_height = base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter, nut_dia = nut_diameter,
             nut_h = nut_height);
}

// top base
if (render_top_base)
{
    translate([ 0, 0, jar_height + base_floor_height + top_base_height ]) rotate([ 0, 180, 0 ]) color("DarkViolet")
        base(inner_diameter = base_jar_cut_diameter, height = top_base_height, wall_thickness = base_wall_thickness,
             floor_height = base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter);
}

// threaded rods
if (render_rods)
{
    rod_length = jar_height + base_floor_height + top_base_height + nut_height;

    for (i = [0:3])
    {
        rotate([ 0, 0, i * 90 ])
        {
            translate([ base_jar_cut_diameter / 2 + threaded_rod_hole_diameter, 0, 0 ])
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
}

// lid
if (render_lid)
{
    lid_height = top_base_height - base_floor_height - lid_h_tol;
    color("DarkGrey") translate([ 0, 0, jar_height + top_base_height - lid_h_tol ]) rotate([ 0, 180, 0 ])
    {
        difference()
        {
            // MAIN LID
            lid(outer_diameter = jar_diameter, inner_diameter = opening_diameter, height = lid_height,
                tolerance = lid_rad_tol, rod_hole_diameter = threaded_rod_diameter, nut_dia = nut_diameter,
                nut_h = nut_height);

            // BEARING AND ROD HOLE
            translate([ 0, 0, -zFite / 2 ]) union()
            {
                cylinder(d = threaded_rod_diameter, h = lid_height * 2 + zFite);
                translate([ 0, 0, 0 ]) rotate([ 0, 0, 30 ]) cylinder(d = bearing_diameter, h = bearing_height + zFite);
            }
        }
    }
}

// ribs
if (render_ribs)
{
    translate([ 0, 0, (jar_height + base_floor_height + top_base_height) / 2 ]) color("DarkViolet")
        base(inner_diameter = base_jar_cut_diameter, height = top_base_height, wall_thickness = base_wall_thickness,
             floor_height = 0, rod_hole_diameter = threaded_rod_hole_diameter, rods = 2);
}

// lights
if (render_lights)
{

    circular_pattern(a = occupy_angle, n = number_of_lights / 2, r = base_jar_cut_diameter / 2, offset = 0,
                     center = true)
        strip_light(width = light_width, depth = light_depth, length = light_length, radius = light_window_radius);
    if (!jar_x_sec)
        circular_pattern(a = occupy_angle, n = number_of_lights / 2, r = base_jar_cut_diameter / 2, offset = 180)
            strip_light(width = light_width, depth = light_depth, length = light_length, radius = light_window_radius,
                        center = true);
}

motor_impeller_shift = 40; // temp var until the motor has a mount

translate([ 0, 0, motor_impeller_shift ])
{
    // impeller
    if (render_impeller)
    {
        translate([ 0, 0, impeller_height / 2 ]) union()
        {
            impeller(radius = impeller_radius, height = impeller_height, fins = impeller_n_fins,
                     twist = impeller_twist_ang, fin_width = impeller_fin_width,
                     center_hub_radius = impeller_hub_radius, center_hole_size = impeller_shaft_hole_radius);
            translate([ 0, 0, impeller_height / 2 - impeller_fin_width / 2 ])
                linear_extrude(impeller_fin_width, center = true) difference()
            {
                circle(r = impeller_radius + impeller_fin_width, $fn = 64);
                circle(r = impeller_radius, $fn = 64);
            }
        }
    }

    // motor and shaft
    if (render_motor)
    {
        color("grey") cylinder(h = shaft_length, d = shaft_diameter, center = false);
    }
}