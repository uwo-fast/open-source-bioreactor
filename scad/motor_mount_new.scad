include <_config.scad>;

// ------------------
// Dev controls
// ------------------

show_bottom = true;
show_middle = true;
show_top = true;

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

flange_height = 8;

raised_face_height = 10;

middle_height = 125;

facets = 20;

// ------------------
// Derived params
// ------------------

outer_diameter = bearing_diameter + (base_screw_diameter * 2) * 4;

wall_thickness = (outer_diameter - motor_boss_diameter) / 2;

// ------------------
// build
// ------------------

// male base
if (show_bottom) {

  center_hole_diameter = shaft_diameter * 1.5; // smaller than the bearing diameter to retain the bearing in place


  translate([0, 0, 0])
    color("slategrey")
      rotate([0, 0, 0])
        difference() {

          union() {
            cylinder(h=flange_height, d=outer_diameter, $fn=facets);
            translate([0, 0, flange_height]) cylinder(h=raised_face_height, d=outer_diameter - wall_thickness, $fn=facets);
          }

          // Center hole for the motor shaft
          translate([0, 0, -zFite / 2])
            cylinder(h=raised_face_height + flange_height + zFite, d=center_hole_diameter, $fn=facets);

          // Vertical holes for screws to fix
          for (i = [0:3])
            rotate([0, 0, i * 90])
              translate([(outer_diameter - wall_thickness / 2) / 2, 0, -zFite / 2])
                cylinder(h=flange_height + zFite, d=base_screw_diameter, $fn=16);

          // Vertical counterbores for screws to fix
          for (i = [0:3])
            rotate([0, 0, i * 90])
              translate([(outer_diameter - wall_thickness / 2) / 2, 0, flange_height - zFite / 2])
                cylinder(h=raised_face_height + zFite, d=face_screw_diameter * 1.5, $fn=16);


          // Horizontal holes for screws to fix the female middle tube to the lower base
          for (i = [0:3])
            rotate([0, 0, i * 90 + 45])
              translate([0, 0, flange_height + raised_face_height / 2])
                rotate([0, 90, 0])
                  cylinder(h=outer_diameter, d=tube_screw_diameter, $fn=16);

          // Horizontal nut traps for screws
          for (i = [0:3])
            rotate([0, 0, i * 90 + 45])
              translate([(outer_diameter - wall_thickness / 2) / 2 - wall_thickness / 2, 0, nut_dim / 2 + flange_height + raised_face_height / 2])
                cube([nut_width, nut_dim, nut_dim + nut_dim], center=true);
        }
}

// female to female pipe
if (show_middle) {
  color("slateblue") translate([0, 0, flange_height]) {
      difference() {
        cylinder(h=middle_height, d=outer_diameter, $fn=facets);
        translate([0, 0, -zFite / 2])
          cylinder(h=middle_height + zFite, d=outer_diameter - wall_thickness + allowance_fit, $fn=facets);

        // Vertical holes for screws to fix the base to the world (in this case, the jar lid)
        for (i = [0:3])
          rotate([0, 0, i * 90])
            translate([(outer_diameter - wall_thickness / 2) / 2, 0, -zFite / 2])
              cylinder(h=flange_height + zFite, d=base_screw_diameter * 2, $fn=16);
        // expand holes so the screw heads have a place to sit

        // Vertical holes for screws to fix the top to the motor faceplate
        for (i = [0:3])
          rotate([0, 0, i * 90])
            translate([(outer_diameter - wall_thickness / 2) / 2, 0, middle_height - flange_height])
              cylinder(h=flange_height + zFite, d=base_screw_diameter * 2, $fn=16);
        // expand holes so the screw heads have a place to sit

        // Horizontal holes for screws to fix the female middle tube to the lower base
        for (i = [0:3])
          rotate([0, 0, i * 90 + 45])
            translate([0, 0, raised_face_height / 2])
              rotate([0, 90, 0])
                cylinder(h=outer_diameter, d=tube_screw_diameter, $fn=16);

        // Horzontal holes for screws to fix the female middle tube to the upper top
        for (i = [0:3])
          rotate([0, 0, i * 90 + 45])
            translate([0, 0, middle_height - raised_face_height / 2])
              rotate([0, 90, 0])
                cylinder(h=outer_diameter, d=tube_screw_diameter, $fn=16);

        // Cut out 4 windows for access to the screws that fix the top to the motor faceplate
        for (i = [0:3])
          rotate([0, 0, i * 90])
            translate([0, 0, middle_height / 2])
              rotate([-90, 0, 0])
                linear_extrude(height=outer_diameter)
                  resize([outer_diameter * 0.40, middle_height * 0.80])
                    circle(d=1, $fn=100);
      }
    }
}

// male top (same as the base, but upside down)
if (show_top) {
  translate([0, 0, middle_height + flange_height * 2])
    color("grey")
      rotate([0, 180, 0]) {
        difference() {

          union() {
            cylinder(h=flange_height, d=outer_diameter, $fn=facets);
            translate([0, 0, flange_height]) cylinder(h=raised_face_height, d=outer_diameter - wall_thickness, $fn=facets);
          }

          // Center hole for the motor shaft
          translate([0, 0, -zFite / 2])
            cylinder(h=raised_face_height + flange_height + zFite, d=motor_boss_diameter, $fn=facets);

          // Vertical holes for screws to fix
          for (i = [0:3])
            rotate([0, 0, i * 90])
              translate([motor_faceplate_screws_separation / 2, 0, -zFite / 2])
                cylinder(h=flange_height + raised_face_height + zFite, d=face_screw_diameter, $fn=16);

          // Vertical counterbores for screws to fix
          for (i = [0:3])
            rotate([0, 0, i * 90])
              translate([motor_faceplate_screws_separation / 2, 0, flange_height - zFite / 2])
                cylinder(h=raised_face_height + zFite, d=face_screw_diameter * 1.5, $fn=16);

          // Horizontal holes for screws to fix the female middle tube to the lower base
          for (i = [0:3])
            rotate([0, 0, i * 90 + 45])
              translate([0, 0, flange_height + raised_face_height / 2])
                rotate([0, 90, 0])
                  cylinder(h=outer_diameter, d=tube_screw_diameter, $fn=16);

          // Horizontal nut traps for screws
          for (i = [0:3])
            rotate([0, 0, i * 90 + 45])
              translate([(outer_diameter - wall_thickness / 2) / 2 - wall_thickness / 2, 0, nut_dim / 2 + flange_height + raised_face_height / 2])
                cube([nut_width, nut_dim, nut_dim + nut_dim], center=true);
        }
      }
}
