// ----- modules only -----

module male_end(
  center_hole_diameter,
  vertical_hole_radius,
  vertical_hole_diameter,
  vertical_hole_depth,
  flange_height,
  raised_face_height,
  outer_diameter,
  wall_thickness,
  tube_screw_diameter,
  face_screw_diameter,
  facets,
  fit
) {
  counterbore_radius = vertical_hole_radius;
  counterbore_diameter = face_screw_diameter * 1.5;
  counterbore_depth = raised_face_height + fit;

  difference() {
    union() {
      cylinder(h=flange_height, d=outer_diameter, $fn=facets);
      translate([0, 0, flange_height]) cylinder(h=raised_face_height, d=outer_diameter - wall_thickness, $fn=facets);
    }

    // Center hole for the motor shaft / boss
    translate([0, 0, -fit / 2])
      cylinder(h=raised_face_height + flange_height + fit, d=center_hole_diameter, $fn=facets);

    // Vertical holes
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([vertical_hole_radius, 0, -fit / 2])
          cylinder(h=vertical_hole_depth, d=vertical_hole_diameter, $fn=16);

    // Vertical counterbores
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([counterbore_radius, 0, flange_height - fit / 2])
          cylinder(h=counterbore_depth, d=counterbore_diameter, $fn=16);

    // Horizontal holes for screws to fix the female middle tube to each male end
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([0, 0, flange_height + raised_face_height / 2])
          rotate([0, 90, 0])
            cylinder(h=outer_diameter, d=tube_screw_diameter, $fn=16);

  }
}

module middle_pipe(
  pipe_height,
  inner_diameter,
  interface_hole_radius,
  interface_hole_diameter,
  interface_hole_depth,
  flange_height,
  raised_face_height,
  outer_diameter,
  tube_screw_diameter,
  facets,
  fit
) {
  difference() {
    cylinder(h=pipe_height, d=outer_diameter, $fn=facets);
    translate([0, 0, -fit / 2])
      cylinder(h=pipe_height + fit, d=inner_diameter, $fn=facets);

    // Vertical holes for screws to fix the base to the world (in this case, the jar lid)
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([interface_hole_radius, 0, -fit / 2])
          cylinder(h=interface_hole_depth, d=interface_hole_diameter, $fn=16);

    // Vertical holes for screws to fix the top to the motor faceplate
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([interface_hole_radius, 0, pipe_height - flange_height])
          cylinder(h=interface_hole_depth, d=interface_hole_diameter, $fn=16);

    // Horizontal holes for screws to fix the female middle tube to the lower base
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([0, 0, raised_face_height / 2])
          rotate([0, 90, 0])
            cylinder(h=outer_diameter, d=tube_screw_diameter, $fn=16);

    // Horizontal holes for screws to fix the female middle tube to the upper top
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([0, 0, pipe_height - raised_face_height / 2])
          rotate([0, 90, 0])
            cylinder(h=outer_diameter, d=tube_screw_diameter, $fn=16);

    // Cut out 4 windows for access to the screws that fix the top to the motor faceplate
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([0, 0, pipe_height / 2])
          rotate([-90, 0, 0])
            linear_extrude(height=outer_diameter)
              resize([outer_diameter * 0.40, pipe_height * 0.80])
                circle(d=1, $fn=100);
  }
}
