// bottle holder
// diameter for bottle diameter (assumes bottles could be cylindrical or square to accomadate either)
// bottle height is used with sleeve ratio to determine how far up the bottle holder should go to support the bottles
// two pairs of male-female dove tails located on either side to allow for grid stacking of holders

$fn = $preview ? 48 : 96;
z_fight = $preview ? 0.05 : 0.0;

bottle_diameter = 62.6;
bottle_height = 130;

sleeve_ratio = 0.3;
wall_thickness = 6;
allowance = 0.2;

// Derived

dovetail_height = wall_thickness * 2 / 3;
dovetail_width = bottle_diameter / 2;

difference() {

  union() {
    difference() {
      cube([bottle_diameter + wall_thickness * 2, bottle_diameter + wall_thickness * 2, bottle_height * sleeve_ratio + wall_thickness], center=true);
      translate([0, 0, wall_thickness / 2])
        cube([bottle_diameter + allowance * 2, bottle_diameter + allowance * 2, bottle_height * sleeve_ratio + z_fight], center=true);
    }

    // dovetail trapezoid
    for (i = [0, 1])
      rotate([0, 0, i * 90])
        translate([0, bottle_diameter / 2 + wall_thickness, -(bottle_height * sleeve_ratio) / 2 + allowance])
          linear_extrude(height=bottle_height * sleeve_ratio)
            polygon(points=[[-dovetail_width / 2, dovetail_height], [-dovetail_width / 3, 0], [dovetail_width / 3, 0], [dovetail_width / 2, dovetail_height]], paths=[[0, 1, 2, 3]]);
  }

  // dovetail trapezoid
  for (i = [0, 1])
    rotate([0, 0, i * 90])
      translate([0, -bottle_diameter / 2 - wall_thickness, -(bottle_height * sleeve_ratio) / 2])
        linear_extrude(height=bottle_height * sleeve_ratio * 2)
          polygon(points=[[-dovetail_width / 2, dovetail_height], [-dovetail_width / 3, 0], [dovetail_width / 3, 0], [dovetail_width / 2, dovetail_height]], paths=[[0, 1, 2, 3]]);
}
