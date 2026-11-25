/**
 * @file support/accessories.scad
 * @brief Print list for the bench equipment around one reactor, excluding the reactor itself
 *
 * The reactor's printed parts are head_print_parts() and frame_print_parts(). Bench equipment
 * beside the reactor prints from separate files, each a single part rather than a subassembly, so
 * its list is kept here as [file, name, quantity, flags that render that part alone]. `just
 * export-accessories` reads it.
 *
 * The cart has no printed parts and has not been built; see dev/future-work.md.
 */

function accessory_print_parts() = [
  // one sleeve per dosing pump bottle, at the file default of an 86.1 mm round bottle
  ["scad/support/bottle_holder.scad", "bottle_holder", 3, ""],
  ["scad/support/estop_box.scad", "estop_box_base", 1, "-D part=\"base\""],
  ["scad/support/estop_box.scad", "estop_box_lid", 1, "-D part=\"lid\""],
  // the stand's 3D corner, printed in place of NopSCADlib's bought bracket
  ["scad/support/electronics_stand.scad", "stand_corner", 1, "-D print_corner=true"],
];
