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
use <jar.scad>;
use <lid.scad>;
use <motor_mount.scad>;
use <probe_atlas.scad>;
use <probe_mount.scad>;
use <probe_thermocouple.scad>;
use <strip_light.scad>;

// external libs
include <NopSCADlib/core.scad>
use <NopSCADlib/vitamins/shaft_coupling.scad>
use <threads-scad/threads.scad>; // only if you want to visualize threads

// config for zFite, preview fn,
include <_config.scad>;

/* [Render Control] */

// Overrides all other render flags
render_all = false; // render all components

// Cuts the jar in half for a cross section view
jar_x_sec = false; // show jar as a cross section, useful during development
// Visualize threads on the rods (slower to render)
show_threads = false; // show threads on rods, slow to render

render_jar = false;

render_base = false;
render_upper_base = false;
render_lid = false;
render_ribs = false;

render_rods = false;
render_rodspacers = false;
render_lights = false;

render_probes = false;

render_motor = false;
render_mmount = false;
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
light_depth = 7.6;
light_window_radius = 0.5;
light_tol = 0.2;

// patterning of lights
number_of_lights = 6;
occupy_angle = 90 * 3 / 4;

/* [Nut & Rod Parameters] */
// nut is size 6  (d=14.5mm)

nut_diameter = 15.4;
nut_height = 6.4;

threaded_rod_diameter = 8.5;
threaded_rod_hole_tolerance = 0.6;
threaded_rod_hole_diameter = threaded_rod_diameter + threaded_rod_hole_tolerance;

/* [Motor & Shaft Parameters] */

motor_diameter = 34;
motor_length = 30;

gearbox_diameter = 36;
gearbox_length = 26;
gearbox_shaft_diameter = 8;
gearbox_shaft_length = 24;

shaft_length = 300;
shaft_diameter = 8.0;
shaft_protrusion = gearbox_shaft_length;

shaft_shaft_coupling_dist = 5;

// reference, length, diameter, input diameter, output diameter, flex?
shaft_coupler_8x8_rigid = [ "SC_8x8_rigid", 25, 12.5, 8, 8, false ];

motor_req_height = gearbox_shaft_length + shaft_protrusion + shaft_shaft_coupling_dist;
mmount_height = motor_req_height;  // height of the motor mount
mmount_width = 42;                 // width of the motor mount
mmount_thickness = 8;              // wall_thickness of the motor mount, must be at least 1.5x the dia of the screws
mmount_floor_thickness = 4;        // thickness of the floor of the motor mount
mmount_inner_diameter = 22;        // inner diameter of the motor mount, set based on diameter of motor mounting boss
mmount_base_screws_diameter = 3.5; // diameter of the screws that fix the motor mount down at by base
mmount_face_screws_diameter = 4;   // diameter of the screws that connect the motor faceplate to the mount
mmount_base_screws_cdist = 32;     // distance between the base screws
mmount_face_screws_cdist = 27.6;     // distance between the face screws

mmount_pillar_width = 7; // width of the pillars that support the motor mount

/* [Probe Parameters] */

ph_probe_neck_diameter = 10;                             // Diameter of the neck
ph_probe_neck_height = 26;                               // Height of the neck
ph_probe_neck_taper_diameter = 5;                        // Tapered diameter of the neck
ph_probe_body_diameter = 15.6;                             // Diameter of the body
ph_probe_body_height = 35;                               // Height of the body
ph_probe_tip_diameter = 12;                              // Diameter of the sensing tip
ph_probe_tip_height = 115;                               // Height of the sensing tip
ph_probe_wire_diameter = 3;                              // Diameter of the wire
ph_probe_wire_height = 50;                               // Height of the wire
ph_probe_colors = [ "Black", "Red", "Black", "Yellow" ]; // Colors of the probe
ph_probe_orient_base = true;                             // Whether to orient the probe to the base

do_probe_neck_diameter = 10;                                   // Diameter of the neck
do_probe_neck_height = 26;                                     // Height of the neck
do_probe_neck_taper_diameter = 5;                              // Tapered diameter of the neck
do_probe_body_diameter = 16;                                   // Diameter of the body
do_probe_body_height = 35;                                     // Height of the body
do_probe_tip_diameter = 12;                                    // Diameter of the sensing tip
do_probe_tip_height = 115;                                     // Height of the sensing tip
do_probe_wire_diameter = 3;                                    // Diameter of the wire
do_probe_wire_height = 50;                                     // Height of the wire
do_probe_colors = [ "Black", "Goldenrod", "Black", "Yellow" ]; // Colors of the probe
do_probe_orient_base = true;                                   // Whether to orient the probe to the base

thermocouple_probe_neck_diameter = 10;  // Diameter of the neck
thermocouple_probe_neck_height = 12;    // Height of the neck
thermocouple_probe_flats_diameter = 26; // Diameter of the flats
thermocouple_probe_flats_height = 5;    // Height of the flats
thermocouple_probe_body_diameter = 21;  // Diameter of the body
thermocouple_probe_body_height = 20;    // Height of the body
thermocouple_probe_tip_diameter = 3.5;  // Diameter of the sensing tip
thermocouple_probe_tip_height = 115;    // Height of the sensing tip
thermocouple_probe_wire_diameter = 3;   // Diameter of the wire
thermocouple_probe_wire_height = 100;   // Height of the wire
thermocouple_probe_orient_base = true;  // Whether to orient the probe to the base

/*********************************************/
/*         Custom-Design Constraints         */
/*********************************************/

/* [Base Parameters] */

base_jar_fit_tol = 0.4; // tolerance for the jar to fit in the base
base_floor_height = 3;  // height of the floor of the base
lower_base_height = 25; // height of the bottom base (holding jar)
upper_base_height = 10; // height of the top base (holding lid)
rib_base_height = 10;   // height of the rib base

// Driven Parameters
total_height = jar_height + base_floor_height + upper_base_height;
base_wall_thickness = (light_depth * 1.5) * 2;           // thinnest part is 50% thicker than the light depth
base_jar_cut_diameter = jar_diameter + base_jar_fit_tol; // diameter of the cutout for the jar

/* [Lid Parameters] */

lid_rad_tol = 0.4;
lid_h_tol = 0.2;
bearing_diameter = 22.6;
bearing_height = 7.5;

// Driven Parameters
lid_height = upper_base_height - base_floor_height - lid_h_tol;
lid_cuts = jar_diameter / 5;
lid_z_pos = jar_height + upper_base_height - lid_h_tol;

/* [Rod Spacer Parameters] */

rod_spacer_thickness = 2;
spacer_dia_tol = 0.2;
spacer_z_tol = 0.4;

// Driven Parameters
rod_shift = base_jar_cut_diameter / 2 + threaded_rod_hole_diameter;
rod_length = total_height + nut_height;
echo("rod length: ", rod_length / 10, " cm");

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

// Driven Parameters
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

// Driven Parameters
impeller_diameter = jar_diameter * impeller_DT_factor;
impeller_radius = impeller_diameter / 2; // impeller radius
impeller_shaft_hole_radius = (shaft_diameter + impeller_shaft_tol) / 2;

/* [Color Parameters] */
prints1_color = "DarkSlateGray";
prints2_color = "SlateBlue";

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

// threaded rods
if (render_rods || render_all)
{
    threads_tol = 0.15;
    for (i = [0:3])
    {
        rotate([ 0, 0, i * 90 ])
        {
            translate([ rod_shift, 0, -zFite ])
            {
                if (show_threads)
                {
                    color("Grey") ScrewThread(outer_diam = threaded_rod_diameter, height = rod_length);
                }
                else
                {
                    color("Grey") cylinder(d = threaded_rod_diameter, h = rod_length);
                }

                // Nuts bottom base
                translate([ 0, 0, -zFite ]) color("DimGray") difference()
                {
                    rotate([ 0, 0, 30 ]) translate([ 0, 0, 0 ])
                        cylinder(d = nut_diameter - threads_tol, h = nut_height, $fn = 6);
                    rotate([ 0, 0, 30 ]) translate([ 0, 0, -zFite / 2 ])
                        cylinder(d = threaded_rod_diameter + threads_tol, h = nut_height + zFite);
                }

                // Nuts top of base
                translate([ 0, 0, lower_base_height + zFite * 2 ]) color("DimGray") difference()
                {
                    rotate([ 0, 0, 30 ]) translate([ 0, 0, 0 ])
                        cylinder(d = nut_diameter - threads_tol, h = nut_height, $fn = 6);
                    rotate([ 0, 0, 30 ]) translate([ 0, 0, -zFite / 2 ])
                        cylinder(d = threaded_rod_diameter + threads_tol, h = nut_height + zFite);
                }
            }
        }
    }
}

// impeller
if (render_impeller || render_all)
{
    translate([ 0, 0, impeller_height / 2 ]) color(prints2_color) union()
    {
        impeller(radius = impeller_radius, height = impeller_height, fins = impeller_n_fins, twist = impeller_twist_ang,
                 fin_width = impeller_fin_width, center_hub_radius = impeller_hub_radius,
                 center_hole_size = impeller_shaft_hole_radius);
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
    color("grey") translate([ 0, 0, lid_z_pos - shaft_length + shaft_protrusion ])
        cylinder(h = shaft_length, d = shaft_diameter, center = false);

    // shaft coupling
    translate(
        [ 0, 0, shaft_length + mmount_height / 2 + shaft_coupler_8x8_rigid[1] / 2 + shaft_shaft_coupling_dist / 2 ])
        shaft_coupling(type = shaft_coupler_8x8_rigid, colour = "MediumBlue");

    // motor
    translate([ 0, 0, lid_z_pos + mmount_height + motor_length + gearbox_length ]) rotate([ 0, 180, 0 ]) union()
    {
        dcmotor(diameter = motor_diameter, length = motor_length);
        translate([ 0, 0, motor_length ]) gearbox(
            diameter = gearbox_diameter, length = gearbox_length, output_shaft_diameter = gearbox_shaft_diameter,
            output_shaft_length = gearbox_shaft_length, faceplate_screws_cdist = mmount_face_screws_cdist);
    }
}

// motor mount
if (render_mmount || render_all)
{
    // motor mount
    color(prints1_color) translate([ 0, 0, lid_z_pos ]) motor_mount(
        height = mmount_height, width = mmount_width, wall_thickness = mmount_thickness,
        floor_thickness = mmount_floor_thickness, inner_dia = mmount_inner_diameter, pillar_width = mmount_pillar_width,
        base_screws_diameter = mmount_base_screws_diameter, base_screws_cdist = mmount_base_screws_cdist,
        face_screws_diameter = mmount_face_screws_diameter, face_screws_cdist = mmount_face_screws_cdist);
}

if (render_probes)
{
    // ph probe
    translate([ jar_diameter / 4, 0, lid_z_pos ]) atlas_probe(
        neck_d = ph_probe_neck_diameter, neck_h = ph_probe_neck_height, neck_taper_d = ph_probe_neck_taper_diameter,
        body_d = ph_probe_body_diameter, body_h = ph_probe_body_height, tip_d = ph_probe_tip_diameter,
        tip_h = ph_probe_tip_height, wire_d = ph_probe_wire_diameter, wire_h = ph_probe_wire_height,
        colors = ph_probe_colors, position_base = ph_probe_orient_base);

    // do probe
    translate([ -jar_diameter / 4, 0, lid_z_pos ]) atlas_probe(
        neck_d = do_probe_neck_diameter, neck_h = do_probe_neck_height, neck_taper_d = do_probe_neck_taper_diameter,
        body_d = do_probe_body_diameter, body_h = do_probe_body_height, tip_d = do_probe_tip_diameter,
        tip_h = do_probe_tip_height, wire_d = do_probe_wire_diameter, wire_h = do_probe_wire_height,
        colors = do_probe_colors, position_base = do_probe_orient_base);

    // thermocouple probe
    translate([ 0, -jar_diameter / 4, lid_z_pos ])
        threaded_thermocouple(neck_d = thermocouple_probe_neck_diameter, neck_h = thermocouple_probe_neck_height,
                              flats_d = thermocouple_probe_flats_diameter, flats_h = thermocouple_probe_flats_height,
                              body_d = thermocouple_probe_body_diameter, body_h = thermocouple_probe_body_height,
                              tip_d = thermocouple_probe_tip_diameter, tip_h = thermocouple_probe_tip_height,
                              wire_d = thermocouple_probe_wire_diameter, wire_h = thermocouple_probe_wire_height,
                              show_threads = show_threads, position_base = thermocouple_probe_orient_base);
}
// lights
if (render_lights || render_all)
{
    lights(light_tol = light_tol);
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

// base
if (render_base || render_all)
{
    color(prints1_color) difference()
    {
        // create the base
        base(inner_diameter = base_jar_cut_diameter, height = lower_base_height, wall_thickness = base_wall_thickness,
             floor_height = base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter, nut_dia = nut_diameter,
             nut_h = nut_height);

        // cut out the lights, rad_cut is true to extend the cut inwards to remove material between jar and light
        lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = true);

        // cut out a second time shifted by 180 for symmetry and to allow more alternative config of the lights
        // this should be handled more elegantly in the future once the first iteration has been printed
        rotate([ 0, 0, 90 ]) lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = true);
    }
}

// top base
if (render_upper_base || render_all)
{
    difference()
    {
        translate([ 0, 0, total_height ]) rotate([ 0, 180, 0 ]) color(prints1_color) base(
            inner_diameter = base_jar_cut_diameter, height = upper_base_height, wall_thickness = base_wall_thickness,
            floor_height = base_floor_height, rod_hole_diameter = threaded_rod_hole_diameter);

        // cut out the lights
        lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = false);

        // cut out a second time shifted by 180 for symmetry and to allow more alternative config of the lights
        // this should be handled more elegantly in the future once the first iteration has been printed
        rotate([ 0, 0, 90 ]) lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = true);
    }
}

// ribs
if (render_ribs || render_all)
{
    // Number of rods holders on the ribs
    n_rods_ribs = 2;

    spacer_dia_tol = 0.2;
    spacer_z_tol = 0.4;
    z_shift_factor = 1 / 3;

    // create the ribs
    for (i = [1:1])
    {

        spacers_total_height =
            total_height - base_floor_height * 2 - upper_base_height - lower_base_height - rib_base_height * 2;

        z_shift = spacers_total_height * i * z_shift_factor;

        spacer_pos = lower_base_height + nut_height + z_shift + rib_base_height * (i - 1);

        f_height = -zFite;

        for (j = [1:1])
        {
            rotate([ 0, 0, j * 180 ]) rotate([ 0, 0, i * 90 ]) difference()
            {
                translate([ 0, 0, spacer_pos ]) color(prints1_color)
                    base(inner_diameter = base_jar_cut_diameter, height = rib_base_height,
                         wall_thickness = base_wall_thickness, floor_height = f_height,
                         rod_hole_diameter = threaded_rod_hole_diameter, rods = n_rods_ribs);

                // cut out the lights, rad_cut is true to extend the cut inwards to remove material between jar and
                // light this is done for all ribs to allow flexibility, again this should be handled more elegantly in
                // the future
                rotate([ 0, 0, 90 ]) lights(light_tol = light_tol, diff_tol = light_tol, rad_cut = true);
            }
        }
    }
}

// rod rib spacers
if (render_rodspacers || render_all)
{
    rod_spacer_diameter = threaded_rod_diameter + 2 * rod_spacer_thickness;
    z_shift_factor = 1 / 3;

    color(prints2_color) for (i = [0:2])
    {
        for (j = [0:3])
        {

            spacers_total_height =
                total_height - base_floor_height * 2 - upper_base_height - lower_base_height - rib_base_height * 2;

            z_shift = spacers_total_height * i * z_shift_factor;

            spacer_pos = lower_base_height + nut_height + z_shift + spacer_z_tol / 2 + rib_base_height * i;

            spacer_height = spacers_total_height * z_shift_factor - spacer_z_tol * 2;

            rotate([ 0, 0, j * 90 ]) translate([ rod_shift, 0, spacer_pos ]) difference()
            {
                cylinder(d = rod_spacer_diameter, h = spacer_height);
                cylinder(d = threaded_rod_diameter + spacer_dia_tol, h = spacer_height + zFite);
            }
        }
    }
}

// lid
if (render_lid || render_all)
{
    cut_height = lid_height * 2 * 1.1;

    translate([ 0, 0, lid_z_pos ]) rotate([ 0, 180, 0 ])
    {

        color(prints2_color) difference()
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
    translate([ jar_diameter / 4, 0, total_height ]) color(prints1_color)
        probe_mount(diameter = probe1_diameter, hole_diameter = probe1_entry_diameter, cut_height = probe1_cut_depth,
                    width = probe_mount_width, height = probe_mount_height, tolerance = probe_mount_cuts_tol,
                    screw_hole_diameter = probe_mount_screw_hole_diameter);
}