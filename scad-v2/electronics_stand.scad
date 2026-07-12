/**
 * @file electronics-stand.scad
 * @brief Electronics stand subassembly for the open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A simple stand built from NopSCADlib aluminium extrusions: one beam along
 * each of the +X, +Y and +Z axes from the origin, joined by a 3D corner
 * bracket (which carries its own grub screws). No electronics mounted yet.
 */

include <NopSCADlib/core.scad>; // core utils (also silences the inch() warning)
include <NopSCADlib/vitamins/extrusions.scad>; // extrusion types + extrusion()
include <NopSCADlib/vitamins/extrusion_brackets.scad>; // 3D corner bracket + screws

$fn = $preview ? 64 : 128;

/* [Stand Parameters] */

// length of the beam along the +X axis
beam_x = 200;
// length of the beam along the +Y axis
beam_y = 200;
// length of the beam along the +Z axis
beam_z = 200;

// Render bracket for printing
print_corner = false;

module dummy() {
  // stop the customizer detection from here onwards
}

// extrusion profile and matching 3D corner bracket (must be the same size)
stand_extrusion = E2020;
stand_bracket = extrusion_corner_bracket_3D_2020;

module electronics_stand() {

  // corner bracket at the origin, with grub screws
  color("peachpuff", 0.5)
    extrusion_corner_bracket_3D(stand_bracket, grub_screws=true);

  // +Z beam (vertical)
  translate([0, 0, beam_z / 2])
    extrusion(stand_extrusion, beam_z);

  // +Y beam
  translate(extrusion_corner_bracket_3D_get_y_offset(stand_bracket))
    rotate(extrusion_corner_bracket_3D_get_y_rot(stand_bracket))
      translate([0, 0, beam_y / 2])
        extrusion(stand_extrusion, beam_y);

  // +X beam
  translate(extrusion_corner_bracket_3D_get_x_offset(stand_bracket))
    rotate(extrusion_corner_bracket_3D_get_x_rot(stand_bracket))
      translate([0, 0, beam_x / 2])
        extrusion(stand_extrusion, beam_x);
}

if (print_corner) {
  // Render the corner bracket for printing
  color("peachpuff")
    extrusion_corner_bracket_3D(stand_bracket, grub_screws=false);
} else {
  // Render the stand for previewing
  electronics_stand();
}
