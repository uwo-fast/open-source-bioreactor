// Three-part motor mount for standard cylindrical electrical motors which have
// a circular faceplate with 4 screws in a square pattern, and a central shaft.

zFite = $preview ? 0.01 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// ----- render controls -----

render_base_plate = true;
render_middle_stand = true;
render_face_plate = true;

// ----- hardware params -----

base_screw_diameter = 3.1;

tube_screw_diameter = 3.1;

face_screw_diameter = 4.2;

bearing_diameter = 22.6;

shaft_diameter = 8.0;

motor_faceplate_diameter = 36.0;

motor_faceplate_screws_separation = 27.6;

motor_boss_diameter = 22.0;

// ----- design selections -----

allowance_fit = 0.2; // clearance for printed parts

raised_face_height = 10;

flange_height = 8;

middle_height = 125;

// divisible by 4 (screws are placed every 90°) while providing rough poly 
// such that the parts cannot concentrically rotate relatively to each other
facets = 20; // number of facets for all cylindrical bodies

part_to_render = "all"; // ["all", "base_plate", "face_plate", "middle_stand"]

motor_mount(
  base_screw_diameter=base_screw_diameter,
  tube_screw_diameter=tube_screw_diameter,
  face_screw_diameter=face_screw_diameter,
  bearing_diameter=bearing_diameter,
  shaft_diameter=shaft_diameter,
  motor_faceplate_diameter=motor_faceplate_diameter,
  motor_faceplate_screws_separation=motor_faceplate_screws_separation,
  motor_boss_diameter=motor_boss_diameter,
  flange_height=flange_height,
  raised_face_height=raised_face_height,
  middle_height=middle_height,
  facets=facets
);

module motor_mount(
  base_screw_diameter,
  tube_screw_diameter,
  face_screw_diameter,
  bearing_diameter,
  shaft_diameter,
  motor_faceplate_diameter,
  motor_faceplate_screws_separation,
  motor_boss_diameter,
  flange_height,
  raised_face_height,
  middle_height,
  facets,
  render = part_to_render
) {

  // ----- derived params -----

  outer_diameter = bearing_diameter + (base_screw_diameter * 2) * 4;

  wall_thickness = (outer_diameter - motor_boss_diameter) / 2;

  bottom_top_hole_radius = (outer_diameter - wall_thickness / 2) / 2;

  bottom_center_hole_diameter = shaft_diameter * 1.5;

  middle_inner_diameter = outer_diameter - wall_thickness + allowance_fit;

  middle_interface_hole_radius = bottom_top_hole_radius;

  middle_interface_hole_diameter = base_screw_diameter * 2;

  middle_interface_hole_depth = flange_height;

  top_vertical_hole_depth = flange_height + raised_face_height;

  bottom_vertical_hole_depth = flange_height;

  // ----- build -----

  if (render == "all" || render == "base_plate") {
    translate([0, 0, 0])
      color("slategrey")
        male_end(
          center_hole_diameter=bottom_center_hole_diameter,
          vertical_hole_radius=bottom_top_hole_radius,
          vertical_hole_diameter=base_screw_diameter,
          vertical_hole_depth=bottom_vertical_hole_depth,
          flange_height=flange_height,
          raised_face_height=raised_face_height,
          outer_diameter=outer_diameter,
          wall_thickness=wall_thickness,
          tube_screw_diameter=tube_screw_diameter,
          face_screw_diameter=face_screw_diameter,
          facets=facets
        );
  }

  if (render == "all" || render == "face_plate") {
    translate([0, 0, middle_height + flange_height * 2])
      color("grey")
        rotate([0, 180, 0])
          male_end(
            center_hole_diameter=motor_boss_diameter,
            vertical_hole_radius=motor_faceplate_screws_separation / 2,
            vertical_hole_diameter=face_screw_diameter,
            vertical_hole_depth=top_vertical_hole_depth,
            flange_height=flange_height,
            raised_face_height=raised_face_height,
            outer_diameter=outer_diameter,
            wall_thickness=wall_thickness,
            tube_screw_diameter=tube_screw_diameter,
            face_screw_diameter=face_screw_diameter,
            facets=facets
          );
  }

  if (render == "all" || render == "middle_stand") {
    color("slateblue")
      translate([0, 0, flange_height])
        middle_pipe(
          pipe_height=middle_height,
          inner_diameter=middle_inner_diameter,
          interface_hole_radius=middle_interface_hole_radius,
          interface_hole_diameter=middle_interface_hole_diameter,
          interface_hole_depth=middle_interface_hole_depth,
          flange_height=flange_height,
          raised_face_height=raised_face_height,
          outer_diameter=outer_diameter,
          tube_screw_diameter=tube_screw_diameter,
          facets=facets
        );
  }
}

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
  facets
) {
  counterbore_radius = vertical_hole_radius;
  counterbore_diameter = face_screw_diameter * 1.5;
  counterbore_depth = raised_face_height + zFite;

  difference() {
    union() {
      cylinder(h=flange_height, d=outer_diameter, $fn=facets);
      translate([0, 0, flange_height]) cylinder(h=raised_face_height, d=outer_diameter - wall_thickness, $fn=facets);
    }

    // Center hole for the motor shaft / boss
    translate([0, 0, -zFite / 2])
      cylinder(h=raised_face_height + flange_height + zFite, d=center_hole_diameter, $fn=facets);

    // Vertical holes
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([vertical_hole_radius, 0, -zFite / 2])
          cylinder(h=vertical_hole_depth + zFite, d=vertical_hole_diameter, $fn=16);

    // Vertical counterbores
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([counterbore_radius, 0, flange_height - zFite / 2])
          cylinder(h=counterbore_depth + zFite, d=counterbore_diameter, $fn=16);

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
  facets
) {
  difference() {
    cylinder(h=pipe_height, d=outer_diameter, $fn=facets);
    translate([0, 0, -zFite / 2])
      cylinder(h=pipe_height + zFite, d=inner_diameter, $fn=facets);

    // Vertical holes for screws to fix the base to the world (in this case, the jar lid)
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([interface_hole_radius, 0, -zFite / 2])
          cylinder(h=interface_hole_depth + zFite, d=interface_hole_diameter, $fn=16);

    // Vertical holes for screws to fix the top to the motor faceplate
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([interface_hole_radius, 0, pipe_height - flange_height])
          cylinder(h=interface_hole_depth + zFite, d=interface_hole_diameter, $fn=16);

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
