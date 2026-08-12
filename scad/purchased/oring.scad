/**
 * @file oring.scad
 * @brief Elastomer o-ring, drawn at its free cross section
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Drawn undeformed. Installed, every one of these is squeezed, so the ring as drawn overlaps
 * whatever it seals against by exactly the squeeze its gland was cut for. That overlap is the
 * point: it is how you see a seal is doing something, and modelling the deformation instead
 * would take hyperelastic FEA to say less.
 *
 * A ring is not always installed on the diameter it is sold at. A gland cut to fit a ring seats
 * it at zero stretch; a groove cut to fit a bore stretches the ring onto it. Pass `id` for the
 * second case - utils/oring_gland.scad has the rule for how much stretch is allowed.
 */

$fn = $preview ? 64 : 128;

function oring_name(type) = type[0]; // catalogue name, e.g. "AS568-160"
function oring_inner_diameter(type) = type[1][0]; // free inside diameter
function oring_cross_section(type) = type[1][1]; // cord diameter
function oring_material(type) = type[2]; // elastomer, e.g. "EPDM"
function oring_hardness(type) = type[3]; // shore A
function oring_colour(type) = type[4]; // as supplied

/**
 * @brief Draw a registered o-ring.
 * @param type Registered parameter set (see orings.scad)
 * @param id   Installed inside diameter; defaults to the free one it is sold at
 */
module oring(type, id = undef) {
  _id = is_undef(id) ? oring_inner_diameter(type) : id;
  _cs = oring_cross_section(type);

  color(oring_colour(type))
    rotate_extrude()
      translate([(_id + _cs) / 2, 0])
        // the cord is a small fraction of the ring, so it needs far fewer facets than the sweep;
        // a dozen of these in one assembly makes that worth splitting
        circle(d=_cs, $fn=$preview ? 12 : 24);
}
