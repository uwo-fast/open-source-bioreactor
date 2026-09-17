/**
 * @file oring.scad
 * @brief Elastomer o-ring, drawn at its free cross section
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Drawn undeformed, so an installed ring overlaps what it seals against by its squeeze - which is
 * how you see a seal is doing something. Pass `id` for a ring stretched onto a groove.
 */

$fn = $preview ? 64 : 128;

function oring_name(type) = type[0]; // catalogue name, e.g. "AS568-252"
function oring_part_number(type) = type[1]; // what to order it by
function oring_inner_diameter(type) = type[2][0]; // free inside diameter
function oring_cross_section(type) = type[2][1]; // cord diameter
function oring_material(type) = type[3]; // elastomer, e.g. "EPDM"
function oring_hardness(type) = type[4]; // shore A
function oring_colour(type) = type[5]; // as supplied

// id is the installed inside diameter; defaults to the free one.
module oring(type, id = undef) {
  _id = is_undef(id) ? oring_inner_diameter(type) : id;
  _cs = oring_cross_section(type);

  color(oring_colour(type))
    rotate_extrude()
      translate([(_id + _cs) / 2, 0])
        circle(d=_cs, $fn=$preview ? 12 : 24);
}
