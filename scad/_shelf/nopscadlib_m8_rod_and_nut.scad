/**
 * @file nopscadlib_m8_rod_and_nut.scad
 * @brief Example of using NopSCADlib vitamins to draw an M8 threaded rod and an M8 nut
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Requires NopSCADlib on the OpenSCAD library path (referenced as <NopSCADlib/...>).
 *   - core.scad           core utilities + the fastener helpers used below
 *   - vitamins/nuts.scad  the M8_nut type and the nut() module
 *   - vitamins/rod.scad   studding() (a threaded rod)
 */

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/nuts.scad>
use <NopSCADlib/vitamins/rod.scad>

// Render the real metric thread form instead of plain cylinders.
// $show_threads is a special variable, so it propagates into the vitamins.
$show_threads = true;

rod_diameter = 8; // M8 nominal
rod_length = 100; // mm

// M8 threaded rod, sitting on the XY plane (center = false puts its base at z = 0).
studding(d = rod_diameter, l = rod_length, center = false);

echo("rod thread outer diameter (mm):", rod_diameter);

// M8 nut, threaded partway up the rod.
translate([0, 0, 20])
  nut(M8_nut);

// --- Dimensions pulled from the vitamins ---

// From the nut (M8_nut), via NopSCADlib's nut.scad accessors:
nut_flat_to_flat = 2 * nut_flat_radius(M8_nut); // across-flats (spanner size)
nut_diameter = 2 * nut_radius(M8_nut);          // across-corners (max outer diameter)
nut_height = nut_thickness(M8_nut);             // plain-nut thickness

echo("nut flat-to-flat (mm):", nut_flat_to_flat);
echo("nut diameter across corners (mm):", nut_diameter);
echo("nut height (mm):", nut_height);
