// bottle holder
// diameter for bottle diameter (assumes bottles could be cylindrical or square to accomadate either)
// bottle height is used with sleeve ratio to determine how far up the bottle holder should go to support the bottles
// two pairs of male-female dove tails located on either side to allow for grid stacking of holders

use <utils/dovetail.scad>;

$fn = $preview ? 48 : 96;
z_fight = $preview ? 0.05 : 0.0;

bottle_diameter = 86.1; // square bottle is 62.6mm, round bottle is 86.1
bottle_height = 130;

sleeve_ratio = 0.3;
wall_thickness = 6;
allowance = 0.2;

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
