/**
 * @file motor_mount.scad
 * @brief Three-part telescoping motor mount
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * For standard cylindrical electric motors with a circular faceplate, 4 screws in a square
 * pattern and a central shaft. It is built as two identical male end caps joined by a female
 * middle tube, so one parameter sets the standoff height. part_to_render selects one part for
 * printing, or "all" for the assembled view.
 */

z_fight = $preview ? 0.05 : 0; // z-fighting avoidance for preview
$fn = $preview ? 64 : 128;

// Radius of the base holes from the centre. It leaves 1.5 hole diameters from the hole centre to
// the body edge, so the counterbore (one hole diameter in radius) always leaves half a hole
// diameter of wall, at any body size.
function get_base_screw_separation_radius(body_diameter, screws_diameter) = (body_diameter - screws_diameter * 3) / 2;

// Flange thickness under a base screw head. The counterbore floor is halfway down the flange, so
// this is the grip length of the screw before it reaches the part the mount is bolted to.
function motor_mount_base_screw_grip(wall_thickness) = wall_thickness / 2;

module motor_mount(
  height,
  body_diameter,
  wall_thickness,
  screws_diameter,
  base_screw_hole_diameter,
  shaft_diameter,
  motor_faceplate_bolt_circle_dia,
  motor_boss_diameter,
  coupling_allowance,
  vertical_hole_allowance = 1.1,
  horizontal_hole_allowance = 0.1,
  boss_allowance = 0.4,
  facets = 20,
  part_render = "all"
) {

  // ----- derived params -----

  coupling_screw_diameter = screws_diameter + horizontal_hole_allowance;

  motor_screw_diameter = screws_diameter + vertical_hole_allowance;

  // The hole is a polygon with `facets` sides, so the boss must fit its inscribed circle.
  motor_boss_hole_diameter = (motor_boss_diameter + boss_allowance) / cos(180 / facets);

  raised_face_height = wall_thickness;

  flange_height = wall_thickness;

  // The base screws fasten the mount to its support, so that joint sets their size and position,
  // not the gearbox. They are set from the hole diameter instead of a nominal screw size because
  // the caller chooses the screw and knows its actual clearance.
  base_screw_separation_radius = get_base_screw_separation_radius(body_diameter, base_screw_hole_diameter);

  middle_height = height - flange_height * 2;

  middle_inner_diameter = body_diameter - wall_thickness + coupling_allowance;

  // ----- assertions -----

  // facets must be divisible by 4 (screws are placed every 90°), and the polygon must be coarse
  // enough that the parts cannot rotate relative to each other
  assert(facets % 4 == 0, "facets must be divisible by 4 for screw holes to be properly placed");

  // The mount telescopes to reach the shaft, so its height is calculated from the vessel below it
  // and can come out negative for a tall vessel. Nothing downstream detects that, so check it here.
  assert(
    middle_height > 0,
    str("Motor mount is ", height, " mm tall, which leaves ", middle_height, " mm of middle stand between two ", flange_height, " mm flanges.")
  );

  // The body diameter is a free choice and the bolt circle is fixed by the gearbox, so only this
  // check ensures the mount is wide enough for its motor.
  assert(
    motor_faceplate_bolt_circle_dia / 2 + motor_screw_diameter <= body_diameter / 2,
    str(
      "The gearbox's screws counterbore out to r ", motor_faceplate_bolt_circle_dia / 2 + motor_screw_diameter,
      " on a ", body_diameter, " mm body."
    )
  );

  // ----- build -----

  // The base plate side
  if (part_render == "all" || part_render == "base_plate") {
    male_end(
      center_hole_diameter=shaft_diameter * 1.5,
      vertical_hole_separation_radius=base_screw_separation_radius,
      vertical_hole_diameter=base_screw_hole_diameter,
      flange_height=flange_height,
      raised_face_height=raised_face_height,
      body_diameter=body_diameter,
      wall_thickness=wall_thickness,
      coupling_screw_diameter=coupling_screw_diameter,
      facets=facets
    );
  }

  // Motor interface side
  if (part_render == "all" || part_render == "face_plate") {
    translate([0, 0, middle_height + flange_height * 2 + z_fight / 2])
      rotate([0, 180, 0])
        male_end(
          center_hole_diameter=motor_boss_hole_diameter,
          vertical_hole_separation_radius=motor_faceplate_bolt_circle_dia / 2,
          vertical_hole_diameter=motor_screw_diameter,
          flange_height=flange_height,
          raised_face_height=raised_face_height,
          body_diameter=body_diameter,
          wall_thickness=wall_thickness,
          coupling_screw_diameter=coupling_screw_diameter,
          facets=facets
        );
  }

  if (part_render == "all" || part_render == "middle_stand") {
    translate([0, 0, flange_height + z_fight])
      middle_pipe(
        pipe_height=middle_height,
        inner_diameter=middle_inner_diameter,
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
  facets
) {
  // the counterbore is sized from its own hole, so each end plate fits its own screw instead of
  // both ends using the motor screw size
  counterbore_diameter = vertical_hole_diameter * 2;

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

// ----- example values -----
//
// A worked example with M3 screws. The render in this file is a preview.

_mm_screws_diameter = 3;

// clearance hole for the base screws; M3, to match the example above
_mm_base_screw_hole_diameter = 3.4;

_mm_shaft_diameter = 8.0;

_mm_motor_faceplate_bolt_circle_dia = 27.6;

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
  base_screw_hole_diameter=_mm_base_screw_hole_diameter,
  shaft_diameter=_mm_shaft_diameter,
  motor_faceplate_bolt_circle_dia=_mm_motor_faceplate_bolt_circle_dia,
  motor_boss_diameter=_mm_motor_boss_diameter,
  coupling_allowance=_mm_allowance_fit,
  part_render=_mm_part_to_render
);
