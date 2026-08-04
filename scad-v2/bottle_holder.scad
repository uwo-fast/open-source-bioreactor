/**
 * @file bottle_holder.scad
 * @brief Stackable holder sleeve for media bottles
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The sleeve is square, so it takes either a cylindrical or a square bottle of the given
 * diameter. sleeve_ratio sets how far up the bottle the sleeve reaches. Two pairs of
 * male-female dovetails on opposing faces let holders be stacked into a grid.
 */

use <utils/dovetail.scad>;

$fn = $preview ? 48 : 96;
z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview

bottle_diameter = 86.1; // square bottle is 62.6mm, round bottle is 86.1
bottle_height = 130;

sleeve_ratio = 0.3;
wall_thickness = 6;
allowance = 0.2;

module dummy() {
  // stop the customizer detection from here onwards
}

// Derived

sleeve_height = bottle_height * sleeve_ratio;
outer_width = bottle_diameter + wall_thickness * 2;

dovetail_height = wall_thickness * 2 / 3;
dovetail_width = bottle_diameter / 2;

difference() {

  union() {
    // sleeve
    difference() {
      cube([outer_width, outer_width, sleeve_height + wall_thickness], center=true);
      translate([0, 0, wall_thickness / 2])
        cube([bottle_diameter + allowance * 2, bottle_diameter + allowance * 2, sleeve_height + z_fight], center=true);
    }

    // tails, on the +x and +y faces
    for (i = [0, 1])
      rotate([0, 0, i * 90])
        translate([0, outer_width / 2, -sleeve_height / 2 + allowance])
          dovetail(dovetail_width, dovetail_height, sleeve_height);
  }

  // sockets, on the -x and -y faces; grown by the allowance so a tail slides in
  for (i = [0, 1])
    rotate([0, 0, i * 90])
      translate([0, -outer_width / 2, -sleeve_height / 2])
        dovetail(dovetail_width, dovetail_height, sleeve_height * 2, allowance=allowance);
}
