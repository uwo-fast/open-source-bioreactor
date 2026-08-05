/**
 * @file motor_mount.scad
 * @brief Three-part telescoping motor mount
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * For standard cylindrical electrical motors which have a circular faceplate with 4 screws
 * in a square pattern, and a central shaft. Built as two identical male end caps joined by a
 * female middle tube, so the standoff height is set by one parameter; part_to_render selects
 * one part for printing or "all" for the assembled view.
 */

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// Function to check if the body diameter is large enough such that the screws do not intersect with the bearing. 
function check_body_diameter(body_diameter, screws_diameter, bearing_diameter, motor_screw_distance) = ( ( (bearing_diameter + (screws_diameter * 2) * 4) > body_diameter) && ( (motor_screw_distance + screws_diameter * 2) > body_diameter)) ? true : false;

// Function to get the (centered) distance between the base holes
function get_base_screw_separation_radius(body_diameter, screws_diameter) = (body_diameter - screws_diameter * 3) / 2;

module motor_mount(
  height,
  body_diameter,
  wall_thickness,
  screws_diameter,
  shaft_diameter,
  motor_faceplate_screws_separation,
  motor_boss_diameter,
  coupling_allowance,
  vertical_hole_allowance = 1.1,
  horizontal_hole_allowance = 0.1,
  facets = 20,
  part_render = "all"
) {

  // ----- derived params -----

  base_screw_diameter = screws_diameter + vertical_hole_allowance;

  coupling_screw_diameter = screws_diameter + horizontal_hole_allowance;

  motor_screw_diameter = screws_diameter + vertical_hole_allowance;

  raised_face_height = wall_thickness;

  flange_height = wall_thickness;

  base_screw_separation_radius = get_base_screw_separation_radius(body_diameter, screws_diameter);

  middle_height = height - flange_height * 2;

  middle_inner_diameter = body_diameter - wall_thickness + coupling_allowance;

  // ----- assertions -----

  // facets must be divisible by 4 (screws are placed every 90°) while providing rough 
  // poly such that the parts cannot concentrically rotate relatively to each other
  assert(facets % 4 == 0, "facets must be divisible by 4 for screw holes to be properly placed");

  // ----- build -----

  // The base plate side
  if (part_render == "all" || part_render == "base_plate") {
    male_end(
      center_hole_diameter=shaft_diameter * 1.5,
      vertical_hole_separation_radius=base_screw_separation_radius,
      vertical_hole_diameter=base_screw_diameter,
      flange_height=flange_height,
      raised_face_height=raised_face_height,
      body_diameter=body_diameter,
      wall_thickness=wall_thickness,
      coupling_screw_diameter=coupling_screw_diameter,
      motor_screw_diameter=motor_screw_diameter,
      facets=facets
    );
  }

  // Motor interface side
  if (part_render == "all" || part_render == "face_plate") {
    translate([0, 0, middle_height + flange_height * 2 + z_fight / 2])
      rotate([0, 180, 0])
        male_end(
          center_hole_diameter=motor_boss_diameter,
          vertical_hole_separation_radius=motor_faceplate_screws_separation / 2,
          vertical_hole_diameter=motor_screw_diameter,
          flange_height=flange_height,
          raised_face_height=raised_face_height,
          body_diameter=body_diameter,
          wall_thickness=wall_thickness,
          coupling_screw_diameter=coupling_screw_diameter,
          motor_screw_diameter=motor_screw_diameter,
          facets=facets
        );
  }

  if (part_render == "all" || part_render == "middle_stand") {
    translate([0, 0, flange_height + z_fight])
      middle_pipe(
        pipe_height=middle_height,
        inner_diameter=middle_inner_diameter,
        interface_hole_separation_radius=base_screw_separation_radius,
        interface_hole_diameter=base_screw_diameter * 2,
        flange_height=flange_height,
        raised_face_height=raised_face_height,
        body_diameter=body_diameter,
        coupling_screw_diameter=coupling_screw_diameter,
        facets=facets
      );
  }
}

module male_end(
  center_hole_diameter,
  vertical_hole_separation_radius,
  vertical_hole_diameter,
  flange_height,
  raised_face_height,
  body_diameter,
  wall_thickness,
  coupling_screw_diameter,
  motor_screw_diameter,
  facets
) {
  counterbore_diameter = motor_screw_diameter * 2;

  difference() {
    union() {
      cylinder(h=flange_height, d=body_diameter, $fn=facets);
      translate([0, 0, flange_height]) cylinder(h=raised_face_height, d=body_diameter - wall_thickness, $fn=facets);
    }

    // Center hole for the motor shaft / boss
    translate([0, 0, -z_fight / 2])
      cylinder(h=raised_face_height + flange_height + z_fight, d=center_hole_diameter, $fn=facets);

    // Vertical holes
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([vertical_hole_separation_radius, 0, -z_fight / 2])
          cylinder(h=flange_height + raised_face_height + z_fight, d=vertical_hole_diameter, $fn=16);

    // Vertical counterbores
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([vertical_hole_separation_radius, 0, flange_height / 2])
          cylinder(h=raised_face_height + flange_height, d=counterbore_diameter, $fn=16);

    // Horizontal holes for screws to fix the female middle tube to each male end
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([0, 0, flange_height + raised_face_height / 2])
          rotate([0, 90, 0])
            cylinder(h=body_diameter, d=coupling_screw_diameter, $fn=16);
  }
}

module middle_pipe(
  pipe_height,
  inner_diameter,
  body_diameter,
  interface_hole_separation_radius,
  interface_hole_diameter,
  flange_height,
  raised_face_height,
  coupling_screw_diameter,
  facets
) {

  difference() {
    cylinder(h=pipe_height, d=body_diameter, $fn=facets);
    translate([0, 0, -z_fight / 2])
      cylinder(h=pipe_height + z_fight, d=inner_diameter, $fn=facets);

    // Horizontal holes for screws to fix the female middle tube to the lower base
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([0, 0, raised_face_height / 2])
          rotate([0, 90, 0])
            cylinder(h=body_diameter, d=coupling_screw_diameter, $fn=16);

    // Horizontal holes for screws to fix the female middle tube to the upper top
    for (i = [0:3])
      rotate([0, 0, i * 90 + 45])
        translate([0, 0, pipe_height - raised_face_height / 2])
          rotate([0, 90, 0])
            cylinder(h=body_diameter, d=coupling_screw_diameter, $fn=16);

    // Cut out 4 windows for access to the screws that fix the top to the motor faceplate
    for (i = [0:3])
      rotate([0, 0, i * 90])
        translate([0, 0, pipe_height / 2])
          rotate([-90, 0, 0])
            linear_extrude(height=body_diameter)
              resize([body_diameter * 0.40, pipe_height * 0.80])
                circle(d=1, $fn=100);
  }
}

// ----- hardware params -----

_mm_screws_diameter = 3;

_mm_shaft_diameter = 8.0;

_mm_motor_faceplate_screws_separation = 27.6;

_mm_motor_boss_diameter = 22.0;

// ----- design selections -----

_mm_body_diameter = 56.0;

_mm_wall_thickness = 10.0;

_mm_height = 141;

_mm_allowance_fit = 0.2; // clearance for printed parts

_mm_part_to_render = "all"; // ["all", "base_plate", "face_plate", "middle_stand"]

motor_mount(
  height=_mm_height,
  body_diameter=_mm_body_diameter,
  wall_thickness=_mm_wall_thickness,
  screws_diameter=_mm_screws_diameter,
  shaft_diameter=_mm_shaft_diameter,
  motor_faceplate_screws_separation=_mm_motor_faceplate_screws_separation,
  motor_boss_diameter=_mm_motor_boss_diameter,
  coupling_allowance=_mm_allowance_fit,
  part_render=_mm_part_to_render
);
