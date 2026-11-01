/**
 * @file support/accessories.scad
 * @brief The print list for the bench around one reactor, apart from the reactor's own
 *
 * The reactor's printed parts are head_print_parts() and frame_print_parts(). What stands beside
 * it on the bench prints from files of its own, each a part rather than a subassembly, so its list
 * lives here: [file, name, quantity, the flags that render that part alone]. `just
 * export-accessories` walks it.
 *
 * The cart prints nothing, and is not built; docs/future-work.md has it.
 */

function accessory_print_parts() = [
  // one sleeve per dosing pump's bottle, at the file's own 86.1 mm round bottle
  ["scad/support/bottle_holder.scad", "bottle_holder", 3, ""],
  ["scad/support/estop_box.scad", "estop_box_base", 1, "-D part=\"base\""],
  ["scad/support/estop_box.scad", "estop_box_lid", 1, "-D part=\"lid\""],
  // the stand's 3D corner, printed in place of NopSCADlib's bought bracket
  ["scad/support/electronics_stand.scad", "stand_corner", 1, "-D print_corner=true"],
];
