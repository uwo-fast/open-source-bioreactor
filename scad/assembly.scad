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
use <dc_motor.scad>;
use <impeller.scad>;
use <lid.scad>;
use <motor_mount.scad>;
use <probe_mount.scad>;
use <strip_light.scad>;

// internal libs
use <lib/jar.scad>;

// external libs
include <NopSCADlib/core.scad>
use <NopSCADlib/vitamins/shaft_coupling.scad>
use <threads-scad/threads.scad>;

// ---------------------------------
// Global Parameters
// ---------------------------------
$fn = $preview ? 64 : 128;  // number of fragments for circles, affects render time
zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview

/* [Render Control] */

// Overrides all other render flags
render_all = true; // render all components

// Cuts the jar in half for a cross section view
jar_x_sec = false; // show jar as a cross section, useful during development
// Visualize threads on the rods (slower to render)
show_threads = false; // show threads on rods, slow to render

render_jar = true;
render_base = true;
render_top_base = true;
render_lid = true;
render_ribs = true;

render_rods = true;
render_rodspacers = true;
render_lights = true;

render_motor = false;
render_impeller = false;

render_probemounts = false;

// ------------------------------------
// Commercial-off-the-shelf Constraints
// ------------------------------------

/* [Jar Parameters] */
jar_height = 305;   // height of the jar
jar_diameter = 220; // diameter of the jar
jar_thickness = 5;  // thickness of the jar

jar_upper_corner_radius = 25;   // radius of the shoulder-to-body transition
jar_lower_corner_radius = 12.5; // radius of the body-to-base transition

jar_neck_height = 25;          // height of the neck
jar_neck_corner_radius = 13.5; // radius of the shoulder-to-neck transition

jar_punt_height = 5; // height of the punt from the bottom of the jar
jar_punt_width = 30; // width/diameter of the punt

jar_rim_rad = 2; // radius of the rim

corner_Fn = 64;      // number of fragments for the corners
rot_Extrude_Fn = 64; // number of fragments for the extrusion

// Copy from ECHO: "jar opening_diameter: ", X
opening_diameter = 143;
// Real life the opening diameter is 143mm
// Note that for a given jar_diameter, currently the opening_diameter
// is a function of jar_upper_corner_radius and jar_neck_corner_radius
// these vars can be tweaked to get the desired opening_diameter

/* [Light Parameters] */

light_length = 336;
light_width = 14.1;
light_depth = 9;
light_window_radius = 0.5;
light_tol = 0.4;

// patterning of lights
number_of_lights = 6;
occupy_angle = 90 * 3 / 4;

/* [Nut & Rod Parameters] */
// nut is size 6  (d=14.5mm)

nut_diameter = 15.4;
nut_height = 7;

threaded_rod_diameter = 8.5;
threaded_rod_hole_tolerance = 0.2;
threaded_rod_hole_diameter = threaded_rod_diameter + threaded_rod_hole_tolerance;

/* [Motor & Shaft Parameters] */
shaft_length = 300;
shaft_diameter = 8.0;

motor_diameter = 34;
motor_length = 30;

gearbox_diameter = 36;
gearbox_length = 26;
gearbox_shaft_diameter = 8;
gearbox_shaft_length = 24;

shaft_shaft_coupling_dist = 5;

//                    name              L       D        d1     d2     flex?
// SC_5x8_rigid  = [ "SC_5x8_rigid",    25,     12.5,    5,     8,     false ];
SC_8x8_rigid = [ "SC_5x8_rigid", 25, 12.5, 8, 8, false ];

mmount_height = 50;         // height of the motor mount
mmount_width = 42;          // width of the motor mount
mmount_thickness = 6;       // thickness of the motor mount, must be at least 1.5x the dia of the screws
mmount_motor_diameter = 36; // diameter of the motor

mmount_base_screws_diameter = 3.5; // diameter of the screws that fix the motor mount down at by base
mmount_face_screws_diameter = 4;   // diameter of the screws that connect the motor faceplate to the mount
mmount_base_screws_cdist = 32;     // distance between the base screws
mmount_face_screws_cdist = 31;     // distance between the face screws

mmount_corner_cuts = mmount_width * 0.1; // corner cuts for the motor mount

/*********************************************/
/*         Custom-Design Constraints         */
/*********************************************/

/* [Base Parameters] */

base_jar_fit_tol = 0.4; // tolerance for the jar to fit in the base
base_floor_height = 3;  // height of the floor of the base
lower_base_height = 25; // height of the bottom base (holding jar)
upper_base_height = 10; // height of the top base (holding lid)

// Dependent Parameters
base_wall_thickness = (light_depth * 1.5) * 2;           // thinnest part is 50% thicker than the light depth
base_jar_cut_diameter = jar_diameter + base_jar_fit_tol; // diameter of the cutout for the jar

/* [Lid Parameters] */

lid_rad_tol = 0.4;
lid_h_tol = 0.2;
bearing_diameter = 22.6;
bearing_height = 5;

lid_height = upper_base_height - base_floor_height - lid_h_tol;

/* [Probe Mount Parameters] */

probe_mount_width = 20;
probe_mount_height = 4;
probe_mount_cuts_tol = 0.1;
probe_mount_screw_hole_diameter = 3;

probe1_diameter = 10;
probe1_entry_diameter = 5;
probe1_cut_depth = probe_mount_height * 2 / 3;
probe1_n = 4;

probe2_diameter = 15;
probe2_entry_diameter = 7.5;
probe2_cut_depth = probe_mount_height * 2 / 3;
probe2_n = 4;

probe3_diameter = 25;
probe3_entry_diameter = 20;
probe3_cut_depth = probe_mount_height * 2 / 3;
probe3_n = 2;

probes_tot_n = probe1_n + probe2_n + probe3_n;

/* [Impeller Parameters] */

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
impeller_height = 60;      // impeller height
impeller_n_fins = 4;       // number of fins
impeller_twist_ang = 55;   // twist angle of each fin
impeller_fin_width = 4;    // width of each fin blade
impeller_hub_radius = 7.5; // size of the center hub
impeller_shaft_tol = 0.2;  // tolerance for the shaft hole

// Dependent Parameters
impeller_diameter = jar_diameter * impeller_DT_factor;
impeller_radius = impeller_diameter / 2; // impeller radius
impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_tol) / 2;
echo("impeller radius: ", impeller_radius);

/* [Hidden Parameters] */
charcoal_color = [ 0.2, 0.2, 0.2 ];

total_height = jar_height + base_floor_height + upper_base_height;

/*********************************************/
/*              START ASSEMBLY               */
/*********************************************/

// jar
if (render_jar || render_all)
{
    rotate([ 0, 0, 45 ]) translate([ 0, 0, base_floor_height ])
        jar(height = jar_height, diameter = jar_diameter, thickness = jar_thickness,
            corner_radius = jar_upper_corner_radius, corner_radius_base = jar_lower_corner_radius,
            neck = jar_neck_height, neck_corner_radius = jar_neck_corner_radius, punt_height = jar_punt_height,
            punt_width = jar_punt_width, rim_rad = jar_rim_rad, arcFn = corner_Fn, rotExtFn = rot_Extrude_Fn,
            show_pts = false, show_2d = false, show_3d = true, pts_r = 1, angle = (jar_x_sec ? 180 : 360));
}

rod_shift = base_jar_cut_diameter / 2 + threaded_rod_hole_diameter;
rod_length = total_height + nut_height;

// threaded rods
if (render_rods || render_all)
{

    for (i = [0:3])
    {
        rotate([ 0, 0, i * 90 ])
        {
            translate([ rod_shift, 0, 0 ])
            {
                if (show_threads)
                {
                    color("Grey") ScrewThread(outer_diam = threaded_rod_diameter, height = rod_length);
                }
                else
                {
                    color("Grey") cylinder(d = threaded_rod_diameter, h = rod_length);
                }
            }
        }
    }
}

face_plate_offset = shaft_length + gearbox_shaft_length + shaft_shaft_coupling_dist;

translate([ 0, 0, jar_height + upper_base_height - (face_plate_offset - mmount_height) ])
{
    // impeller
    if (render_impeller || render_all)
    {
        translate([ 0, 0, impeller_height / 2 ]) color(charcoal_color) union()
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
    if (render_motor || render_all)
    {
        // external shaft
        //color("grey") cylinder(h = shaft_length, d = shaft_diameter, center = false);

        // shaft coupling
        //translate([ 0, 0, shaft_length ]) shaft_coupling(type = SC_8x8_rigid, colour = "MediumBlue");

        // motor
        // translate([ 0, 0, face_plate_offset + motor_length + gearbox_length ]) rotate([ 0, 180, 0 ]) union()
        // {
        //     dcmotor(diameter = motor_diameter, length = motor_length);
        //     translate([ 0, 0, motor_length ]) gearbox(
        //         diameter = gearbox_diameter, length = gearbox_length, output_shaft_diameter = gearbox_shaft_diameter,
        //         output_shaft_length = gearbox_shaft_length, faceplate_screws_cdist = mmount_face_screws_cdist);
        // }

        // motor mount
        color("DarkViolet") translate([ 0, 0, face_plate_offset - mmount_height ]) motor_mount(
            height = mmount_height, width = mmount_width, thickness = mmount_thickness,
            motor_diameter = mmount_motor_diameter, corner_cuts = mmount_corner_cuts,
            base_screws_diameter = mmount_base_screws_diameter, base_screws_cdist = mmount_base_screws_cdist,
            face_screws_diameter = mmount_face_screws_diameter, face_screws_cdist = mmount_face_screws_cdist);
    }
}

// put into a module so we can call it to remove from 3DP supporting components
// light_tol is the tolerance between base_jar_cut_diameter and the light front face to create a small gap
// diff_tol is the tolerance applied to the light dimensions to create a toleranced pocket
module lights(light_tol = 0, diff_tol = 0, rad_cut = false)
{
    // Add extra cut depth to prevent material between jar and light when creating pockets with lights
    radial_cut_ext = rad_cut ? light_depth * 0.1 : 0;

    placement_rad = base_jar_cut_diameter / 2 + light_tol - diff_tol / 2 - radial_cut_ext;

    // [width, depth, length, window_radius]
    dims = [
        light_width + diff_tol, light_depth + diff_tol + radial_cut_ext, light_length + diff_tol,
        light_window_radius
    ];

    translate([ 0, 0, base_floor_height ]) rotate([ 0, 0, 45 ])
    {
        surround_lights(light_dims = dims, angle = occupy_angle, n = number_of_lights / 2, r = placement_rad,
                        offset = 0, center = true);

        if (!jar_x_sec)
            surround_lights(light_dims = dims, angle = occupy_angle, n = number_of_lights / 2, r = placement_rad,
                            offset = 180, center = true);
    }
}

// lights
if (render_lights || render_all)
{
    lights(light_tol = light_tol);
}

// base
if (render_base || render_all)
{
    color("DarkViolet") difference()
    {
        // create the base
        base(inner_diameter = base_jar_cut_diameter, height = lower_base_height, wall_thickness = base_wall_thickness,
             floor_height = base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter, nut_dia = nut_diameter,
             nut_h = nut_height);

        // cut out the lights, rad_cut is true to extend the cut inwards to remove material between jar and light
        lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = true);
    }
}

// top base
if (render_top_base || render_all)
{
    difference()
    {
        translate([ 0, 0, total_height ]) rotate([ 0, 180, 0 ]) color("DarkViolet") base(
            inner_diameter = base_jar_cut_diameter, height = upper_base_height, wall_thickness = base_wall_thickness,
            floor_height = base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter);

        // cut out the lights
        lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = false);
    }
}

// ribs
if (render_ribs || render_all)
{
    // Number of rods holders on the ribs
    n_rods_ribs = 2;

    // for exporting
    // export_cut = true; // comment for all ribs, true for one cut, false for one uncut
    lowI = (!is_undef(export_cut) && export_cut) ? 3 : 0;
    echo("lowI: ", lowI);
    highI = (!is_undef(export_cut) && !export_cut) ? 0 : 3;
    echo("highI: ", highI);

    difference()
    {
        // create the ribs
        for (i = [lowI:highI])
        {
            z_shift_factor = (i % 2 == 0) ? 1 / 3 : 2 / 3;
            z_shift = (total_height)*z_shift_factor;
            f_height = -zFite;
            rotate([ 0, 0, i * 90 ]) translate([ 0, 0, z_shift ]) color("DarkViolet")
                base(inner_diameter = base_jar_cut_diameter, height = upper_base_height,
                     wall_thickness = base_wall_thickness, floor_height = f_height,
                     rod_hole_diameter = threaded_rod_hole_diameter, rods = n_rods_ribs);
        }
        // cut out the lights, rad_cut is true to extend the cut inwards to remove material between jar and light
        lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = true);
    }
}

// threaded_rod_hole_diameter
// threaded_rod_diameter
rod_spacer_thickness = 2;
rod_spacer_diameter = threaded_rod_diameter + 2 * rod_spacer_thickness;

// rod rib spacers
if (render_rodspacers || render_all)
{
    spacer_dia_tol = 0.2;
    spacer_z_tol = 0.4;
    color(charcoal_color) // charcoal
        for (i = [0:2])
    {
        for (j = [0:3])
        {
            z_shift_factor = 1 / 3;

            z_shift_factor_height = i * z_shift_factor;

            sec_height = (i == 0) ? lower_base_height : upper_base_height;

            z_shift_comm = (total_height);

            z_shift = z_shift_comm * z_shift_factor_height + sec_height + spacer_z_tol / 2;

            z_gap_height = z_shift_comm * z_shift_factor - sec_height - spacer_z_tol;

            rotate([ 0, 0, j * 90 ]) translate([ rod_shift, 0, z_shift ]) difference()
            {
                cylinder(d = rod_spacer_diameter, h = z_gap_height);
                cylinder(d = threaded_rod_diameter + spacer_dia_tol, h = z_gap_height + zFite);
            }
        }
    }
}

lid_cuts = jar_diameter / 5;

// lid
if (render_lid || render_all)
{
    cut_height = lid_height * 2 * 1.1;

    translate([ 0, 0, jar_height + upper_base_height - lid_h_tol ]) rotate([ 0, 180, 0 ])
    {

        color([ 0.2, 0.2, 0.2 ]) difference()
        {
            // create the lid
            lid(outer_diameter = jar_diameter, inner_diameter = opening_diameter, height = lid_height,
                tolerance = lid_rad_tol, rod_hole_diameter = threaded_rod_diameter, nut_dia = nut_diameter,
                nut_h = nut_height);

            // cut out the bearing and shaft hole
            translate([ 0, 0, -zFite / 2 ]) union()
            {
                cylinder(d = threaded_rod_diameter, h = lid_height * 2 + zFite);
                rotate([ 0, 0, 30 ]) cylinder(d = bearing_diameter, h = bearing_height + zFite);
            }

            // flat cuts to reduce material and allow space for lights
            translate([ 0, 0, lid_height ]) rotate([ 0, 0, 45 ]) difference()
            {
                cube([ jar_diameter * 1.1, jar_diameter * 1.1, cut_height ], center = true);
                cube([ jar_diameter - lid_cuts, jar_diameter - lid_cuts, cut_height * 1.1 ], center = true);
            }

            // cut out probe holes
            // turn this into a reusable module to be used for placement too!!
            angular_sift = 360 / probes_tot_n;
            for (i = [0:probe1_n - 1])
            {
                rotate([ 0, 0, i * angular_sift ]) translate([ jar_diameter / 4, 0, lid_height ])
                {
                    cylinder(d = probe1_entry_diameter, h = cut_height, center = true);
                }
            }
            for (i = [0:probe2_n - 1])
            {
                rotate([ 0, 0, (i + probe1_n) * angular_sift ]) translate([ jar_diameter / 4, 0, lid_height ])
                {
                    cylinder(d = probe2_entry_diameter, h = cut_height, center = true);
                }
            }
            for (i = [0:probe3_n - 1])
            {
                rotate([ 0, 0, (i + probe1_n + probe2_n) * angular_sift ])
                    translate([ jar_diameter / 4, 0, lid_height ])
                {
                    cylinder(d = probe3_entry_diameter, h = cut_height, center = true);
                }
            }
        }
    }
}

// probe mounts
if (render_probemounts || render_all)
{
    translate([ jar_diameter / 4, 0, total_height ]) color("DarkViolet")
        probe_mount(diameter = probe1_diameter, hole_diameter = probe1_entry_diameter, cut_height = probe1_cut_depth,
                    width = probe_mount_width, height = probe_mount_height, tolerance = probe_mount_cuts_tol,
                    screw_hole_diameter = probe_mount_screw_hole_diameter);
}