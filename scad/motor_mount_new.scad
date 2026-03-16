include <_config.scad>;

// TODO: integrate into assembly.scad and remove redundant params

// ------------------
// Dev controls
// ------------------

show_bottom = true;
show_middle = true;
show_top = true;
separate_objects = 25;

// ------------------
// Hardware params
// ------------------

base_screw_diameter = 3.1;
tube_screw_diameter = 3.1;
face_screw_diameter = 4.2;

bearing_diameter = 22.6;
shaft_diameter = 8.0;

motor_faceplate_diameter = 36.0;
motor_faceplate_screws_separation = 27.6;
motor_boss_diameter = 22.0;

nut_width = 2.5;
nut_dim = 8.0;

// ------------------
// Design selections
// ------------------

allowance_fit = 0.2; // clearance for printed parts

base_height = 4;

top_height = 6;

temp_derived_height = 125;

middle_height = 125 - base_height - top_height;

// ------------------
// Derived params
// ------------------

base_dia = bearing_diameter + (base_screw_diameter * 1.5) * 4;

wall_thickness = (base_dia - motor_boss_diameter) / 2;

collar_height = 10;

facets = 20;

// ------------------
// build
// ------------------

// male base
if (show_bottom) {
  difference() {
    union() {
      cylinder(h=base_height, d=base_dia, $fn=facets);
      translate([0, 0, base_height]) cylinder(h=collar_height, d=base_dia - wall_thickness, $fn=facets);
    }

    // Center hole for the motor shaft, but smaller than bearing such that it retains the bearing in place
    translate([0, 0, -zFite / 2])
      cylinder(h=collar_height + base_height + zFite, d=shaft_diameter * 1.5, $fn=facets);

    // Vertical holes for screws to fix the base to the world (in this case, the jar lid)
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([(base_dia - wall_thickness / 2) / 2, 0, 0])
          cylinder(h=base_height + zFite, d=base_screw_diameter, $fn=16);

    // Horizontal holes for screws to fix the female middle tube to the lower base
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([0, 0, base_height + collar_height / 2])
          rotate([0, 90, 0])
            cylinder(h=base_dia, d=tube_screw_diameter, $fn=16);

    // Horizontal nut traps for screws
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([(base_dia - wall_thickness / 2) / 2 - wall_thickness / 2, 0, nut_dim / 2 + base_height + collar_height / 2])
          cube([nut_width, nut_dim, nut_dim + nut_dim], center=true);
  }
}

// female to female pipe
if (show_middle) {
  translate([0, 0, separate_objects * 0.85]) {
    difference() {
      cylinder(h=middle_height, d=base_dia, $fn=facets);
      translate([0, 0, -zFite / 2])
        cylinder(h=middle_height + zFite, d=base_dia - wall_thickness + allowance_fit, $fn=facets);

      // Vertical holes for screws to fix the base to the world (in this case, the jar lid)
      for (i = [0:3])
        rotate([0, 0, i * 90])
          translate([(base_dia - wall_thickness / 2) / 2, 0, 0])
            cylinder(h=base_height + zFite, d=base_screw_diameter * 2, $fn=16);
      // expand holes so the screw heads have a place to sit

      // Vertical holes for screws to fix the top to the motor faceplate
      for (i = [0:3])
        rotate([0, 0, i * 90])
          translate([(base_dia - wall_thickness / 2) / 2, 0, middle_height - base_height])
            cylinder(h=base_height + zFite, d=base_screw_diameter * 2, $fn=16);
      // expand holes so the screw heads have a place to sit

      // Horizontal holes for screws to fix the female middle tube to the lower base
      for (i = [0:3])
        rotate([0, 0, i * 90 + 45])
          translate([0, 0, collar_height / 2])
            rotate([0, 90, 0])
              cylinder(h=base_dia, d=tube_screw_diameter, $fn=16);

      // Horzontal holes for screws to fix the female middle tube to the upper top
      for (i = [0:3])
        rotate([0, 0, i * 90 + 45])
          translate([0, 0, middle_height - collar_height / 2])
            rotate([0, 90, 0])
              cylinder(h=base_dia, d=tube_screw_diameter, $fn=16);

      // Cut out 4 windows for access to the screws that fix the top to the motor faceplate
      for (i = [0:3])
        rotate([0, 0, i * 90])
          translate([0, 0, middle_height / 2])
            rotate([-90, 0, 0])
              linear_extrude(height=base_dia)
                resize([base_dia * 0.40, middle_height * 0.80])
                  circle(d=1, $fn=100);
    }
  }
}

// male top (same as the base, but upside down)
if (show_top) {
  translate([0, 0, base_height + middle_height + separate_objects]) {

    difference() {

      union() {
        translate([0, 0, collar_height]) cylinder(h=top_height, d=base_dia, $fn=facets);
        cylinder(h=collar_height, d=base_dia - wall_thickness, $fn=facets);
      }

      cylinder(h=collar_height + top_height + zFite, d=motor_boss_diameter, $fn=facets);

      // Vertical holes for screws to fix the top to the motor faceplate
      for (i = [0:3])
        rotate([0, 0, i * 90])
          translate([motor_faceplate_screws_separation / 2, 0, 0])
            cylinder(h=top_height + collar_height + zFite, d=face_screw_diameter, $fn=16);

      // Vertical holes for screws to fix the top to the motor faceplate
      for (i = [0:3])
        rotate([0, 0, i * 90])
          translate([motor_faceplate_screws_separation / 2, 0, 0])
            cylinder(h=collar_height + zFite, d=face_screw_diameter * 1.5, $fn=16);

      // Horizontal holes for screws to fix the female middle tube to the top
      for (i = [0:3])
        rotate([0, 0, i * 90 + 45])
          translate([0, 0, collar_height / 2])
            rotate([0, 90, 0])
              cylinder(h=base_dia, d=tube_screw_diameter, $fn=16);

      for (i = [0:3])
        rotate([0, 0, i * 90 + 45])
          translate([(base_dia - wall_thickness / 2) / 2 - wall_thickness / 2, 0, nut_dim / 2])
            cube([nut_width, nut_dim, nut_dim + nut_dim], center=true);
    }
  }
}
